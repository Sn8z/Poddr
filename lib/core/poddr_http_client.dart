import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:poddr/core/exceptions.dart';

class PoddrHttpClient extends http.BaseClient {
  static const String _appName = 'Poddr';
  static const String _appVersion = '3.0.0+1'; // Sync with pubspec.yaml version
  static String get userAgent => '$_appName/$_appVersion (${Platform.operatingSystem})';

  final http.Client _inner = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = userAgent;
    return _inner.send(request).timeout(
      _defaultTimeout,
      onTimeout: () => throw TimeoutException('Request timed out'),
    );
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await super.get(url, headers: headers);
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
