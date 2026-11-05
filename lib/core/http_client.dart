import 'dart:io' show Platform;
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';

class PoddrHttpClient extends http.BaseClient {
  static const String _appName = 'Poddr';
  static const String _appVersion = '3.0.0+1';
  static String get userAgent {
    if (kIsWeb) {
      return '$_appName/$_appVersion (Web)';
    }
    return '$_appName/$_appVersion (${Platform.operatingSystem})';
  }

  final http.Client _inner = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _defaultStreamIdleTimeout = Duration(seconds: 30);
  static const int _maxAttempts = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 400);
  static const int _maxRetryDelayMs = 4000;
  static const Duration _defaultCacheTtl = Duration(hours: 1);

  final Map<String, _CacheEntry> _cache = {};
  final Duration _cacheTtl;
  final Duration _streamIdleTimeout;
  int _currentCacheSize = 0;

  static const int _maxCacheEntries = 200;
  static const int _maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB

  PoddrHttpClient({
    Duration? cacheTtl,
    Duration streamIdleTimeout = _defaultStreamIdleTimeout,
  })  : _cacheTtl = cacheTtl ?? _defaultCacheTtl,
        _streamIdleTimeout = streamIdleTimeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] = userAgent;
    final response = await _inner.send(request).timeout(
          _defaultTimeout,
          onTimeout: () => throw TimeoutException('Request timed out'),
        );

    return http.StreamedResponse(
      response.stream.timeout(_streamIdleTimeout),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// Performs a GET request.
  ///
  /// [skipCache] bypasses both cache reads and cache writes. [maxBytes] limits
  /// the buffered response body and does not affect caching; success responses
  /// over the limit throw, while error responses keep their status code and
  /// return an empty body.
  @override
  Future<http.Response> get(Uri url,
      {Map<String, String>? headers,
      bool skipCache = false,
      int? maxBytes}) async {
    if (maxBytes != null && maxBytes <= 0) {
      throw ArgumentError.value(maxBytes, 'maxBytes', 'Must be positive');
    }

    final urlKey = url.toString();
    final useCache = !skipCache;

    _CacheEntry? cached;
    if (useCache) {
      cached = _cache[urlKey];
      if (cached != null && cached.isExpired(_cacheTtl)) {
        _removeCached(urlKey);
        cached = null;
      }
    }

    final requestHeaders = <String, String>{...?headers};
    if (cached != null) {
      if (cached.etag != null) {
        requestHeaders['If-None-Match'] = cached.etag!;
      }
      if (cached.lastModified != null) {
        requestHeaders['If-Modified-Since'] = cached.lastModified!;
      }
    }

    final response = await _sendWithRetry(
      () => _bufferedGet(url, requestHeaders, maxBytes),
      method: 'GET',
      url: url,
    );

    if (useCache && cached != null && response.statusCode == 304) {
      return http.Response(
        cached.body,
        cached.statusCode,
        headers: cached.headers,
        request: response.request,
      );
    }

    if (useCache && response.statusCode == 200) {
      final entry = _CacheEntry.fromResponse(response);
      _removeCached(urlKey);
      _cache[urlKey] = entry;
      _currentCacheSize += entry.body.length;

      while ((_cache.length > _maxCacheEntries ||
              _currentCacheSize > _maxCacheSizeBytes) &&
          _cache.isNotEmpty) {
        final oldestKey = _cache.keys.reduce((a, b) =>
            _cache[a]!.timestamp.isBefore(_cache[b]!.timestamp) ? a : b);
        _removeCached(oldestKey);
      }
    }

    return response;
  }

  Future<http.Response> _bufferedGet(
    Uri url,
    Map<String, String> headers,
    int? maxBytes,
  ) async {
    final request = http.Request('GET', url)..headers.addAll(headers);
    final response = await send(request);
    return _readBody(response, maxBytes: maxBytes);
  }

  /// Buffers a streamed response as the single conversion point from a
  /// [http.StreamedResponse] to an [http.Response].
  ///
  /// Status codes take precedence over [maxBytes]: oversized error responses
  /// are returned with their status and an empty body instead of throwing.
  Future<http.Response> _readBody(
    http.StreamedResponse response, {
    int? maxBytes,
  }) async {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (maxBytes != null &&
        response.contentLength != null &&
        response.contentLength! > maxBytes) {
      await _discardStream(response.stream);
      if (isSuccess) throw _tooLarge(maxBytes);
      return _toResponse(response, Uint8List(0));
    }

    final bytes = BytesBuilder(copy: false);
    var totalBytes = 0;
    await for (final chunk in response.stream) {
      totalBytes += chunk.length;
      if (maxBytes != null && totalBytes > maxBytes) {
        if (isSuccess) throw _tooLarge(maxBytes);
        return _toResponse(response, Uint8List(0));
      }
      bytes.add(chunk);
    }

    return _toResponse(response, bytes.takeBytes());
  }

  http.Response _toResponse(
    http.StreamedResponse response,
    Uint8List bodyBytes,
  ) {
    return http.Response.bytes(
      bodyBytes,
      response.statusCode,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<void> _discardStream(http.ByteStream stream) async {
    await stream.listen(null).cancel();
  }

  ApiException _tooLarge(int maxBytes) {
    return ApiException(
      'Response exceeds the $maxBytes byte limit',
      userMessage: 'This content is too large to load.',
    );
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return _sendWithRetry(
      () => super.head(url, headers: headers),
      method: 'HEAD',
      url: url,
    );
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() send, {
    required String method,
    required Uri url,
  }) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final isLastAttempt = attempt == _maxAttempts - 1;

      try {
        final response = await send();
        if (!_isTransientStatus(response.statusCode) || isLastAttempt) {
          return response;
        }

        debug(
          '$method $url returned ${response.statusCode}, '
          'retrying (${attempt + 1}/$_maxAttempts)',
          name: 'PoddrHttpClient',
        );
        await _waitBeforeRetry(attempt, response);
      } on TimeoutException {
        if (isLastAttempt) {
          throw NetworkException('Request timed out');
        }
        debug(
          '$method $url timed out, retrying (${attempt + 1}/$_maxAttempts)',
          name: 'PoddrHttpClient',
        );
        await _waitBeforeRetry(attempt, null);
      } on http.ClientException catch (e) {
        if (isLastAttempt) {
          throw NetworkException(e.message);
        }
        debug(
          '$method $url failed (${e.message}), '
          'retrying (${attempt + 1}/$_maxAttempts)',
          name: 'PoddrHttpClient',
        );
        await _waitBeforeRetry(attempt, null);
      } catch (e) {
        if (e is PoddrException) rethrow;
        throw ApiException('Unexpected network error: $e');
      }
    }

    throw NetworkException('Max retries exceeded for $method $url');
  }

  bool _isTransientStatus(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  Future<void> _waitBeforeRetry(int attempt, http.Response? response) async {
    final retryAfter = response?.headers['retry-after'];
    final retryAfterSeconds =
        retryAfter == null ? null : int.tryParse(retryAfter.trim());

    if (retryAfterSeconds != null) {
      final seconds = retryAfterSeconds.clamp(1, 10);
      await Future.delayed(Duration(seconds: seconds));
      return;
    }

    final backoffMs = _baseRetryDelay.inMilliseconds * (1 << attempt);
    final jitterMs = Random().nextInt(250);
    final delayMs = (backoffMs + jitterMs).clamp(0, _maxRetryDelayMs);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  void _removeCached(String key) {
    final entry = _cache.remove(key);
    if (entry == null) return;
    _currentCacheSize -= entry.body.length;
    if (_currentCacheSize < 0) _currentCacheSize = 0;
  }

  @override
  void close() => _inner.close();
}

class _CacheEntry {
  final String body;
  final int statusCode;
  final Map<String, String> headers;
  final DateTime timestamp;
  final String? etag;
  final String? lastModified;

  _CacheEntry({
    required this.body,
    required this.statusCode,
    required this.headers,
    required this.timestamp,
    this.etag,
    this.lastModified,
  });

  factory _CacheEntry.fromResponse(http.Response response) {
    return _CacheEntry(
      body: response.body,
      statusCode: response.statusCode,
      headers: Map<String, String>.from(response.headers),
      timestamp: DateTime.now(),
      etag: response.headers['etag'],
      lastModified: response.headers['last-modified'],
    );
  }

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) >= ttl;
  }
}
