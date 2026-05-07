import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';

class PoddrHttpClient extends http.BaseClient {
  static const String _appName = 'Poddr';
  static const String _appVersion = '3.0.0+1';
  static String get userAgent =>
      '$_appName/$_appVersion (${Platform.operatingSystem})';

  final http.Client _inner = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _defaultCacheTtl = Duration(hours: 1);

  final Map<String, _CacheEntry> _cache = {};
  final Duration _cacheTtl;
  int _currentCacheSize = 0;

  static const int _maxCacheEntries = 200;
  static const int _maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB

  PoddrHttpClient({Duration? cacheTtl}) : _cacheTtl = cacheTtl ?? _defaultCacheTtl;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = userAgent;
    return _inner.send(request).timeout(
          _defaultTimeout,
          onTimeout: () => throw TimeoutException('Request timed out'),
        );
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers, bool skipCache = false}) async {
    final urlKey = url.toString();

    if (skipCache) {
      final response = await super.get(url, headers: headers);
      return response;
    }

    _CacheEntry? cached = _cache[urlKey];
    if (cached != null && cached.isExpired(_cacheTtl)) {
      _cache.remove(urlKey);
      cached = null;
    }

    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final requestHeaders = <String, String>{...?headers};

        if (cached != null) {
          if (cached.etag != null) {
            requestHeaders['If-None-Match'] = cached.etag!;
          }
          if (cached.lastModified != null) {
            requestHeaders['If-Modified-Since'] = cached.lastModified!;
          }
        }

        final response = await super.get(url, headers: requestHeaders);

        if (response.statusCode == 304 && cached != null) {
          return http.Response(
            cached.body,
            cached.statusCode,
            headers: cached.headers,
            request: response.request,
          );
        }

        if (response.statusCode == 200) {
          final entry = _CacheEntry.fromResponse(response);
          _cache[urlKey] = entry;
          _currentCacheSize += entry.body.length;

          while ((_cache.length > _maxCacheEntries ||
                  _currentCacheSize > _maxCacheSizeBytes) &&
              _cache.isNotEmpty) {
            final oldestKey = _cache.keys.reduce((a, b) =>
                _cache[a]!.timestamp.isBefore(_cache[b]!.timestamp)
                    ? a
                    : b);
            _currentCacheSize -= _cache[oldestKey]!.body.length;
            _cache.remove(oldestKey);
          }
        }

        if (response.statusCode >= 500 && attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }

        return response;
      } on TimeoutException {
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        throw NetworkException('Request timed out');
      } on http.ClientException catch (e) {
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        throw NetworkException(e.message);
      } catch (e) {
        if (e is ApiException) rethrow;
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        error('Unexpected error in GET $url: $e', name: 'PoddrHttpClient');
        throw ApiException('Network error occurred');
      }
    }
    throw NetworkException('Max retries exceeded for GET $url');
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await super.head(url, headers: headers);
        if (response.statusCode >= 500 && attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        return response;
      } on TimeoutException {
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        throw NetworkException('Request timed out');
      } on http.ClientException catch (e) {
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        throw NetworkException(e.message);
      } catch (e) {
        if (e is ApiException) rethrow;
        if (attempt < _maxRetries - 1) {
          attempt++;
          continue;
        }
        throw ApiException('Unexpected error: $e');
      }
    }
    throw NetworkException('Max retries exceeded for HEAD $url');
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
