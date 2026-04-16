import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:poddr/data/exceptions.dart';

class GpodderClient {
  // Constants
  static const String logName = "gPodderClient";
  static const Duration _timeout = Duration(seconds: 30);

  // Fields
  String _serverUrl;
  String _username;
  String _password;
  String _deviceId;
  String _deviceName;
  String? _sessionId;

  final http.Client _httpClient;

  String get _baseUrl => _serverUrl;

  String get _encodedUsername => Uri.encodeComponent(_username);

  Map<String, String> get _authHeaders => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$_username:$_password'))}',
        'Content-Type': 'application/json',
      };

  Map<String, String> get _authHeadersWithCookie => {
        ..._authHeaders,
        if (_sessionId != null) 'Cookie': 'sessionid=$_sessionId',
      };

  Future<dynamic> _sendRequest(
    String method,
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
    bool useCookie = true,
  }) async {
    final uri =
        Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

    final headers = useCookie ? _authHeadersWithCookie : _authHeaders;
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await _httpClient.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _httpClient
              .put(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'DELETE':
          response =
              await _httpClient.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      final res = response.body;
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        if (res.isEmpty) return null;
        return jsonDecode(res);
      }

      if (statusCode == 401) {
        throw UnauthorizedException();
      } else if (statusCode == 404) {
        throw NotFoundException();
      } else if (statusCode >= 500) {
        throw ServerErrorException(statusCode);
      } else {
        throw ApiException('HTTP request failed with status $statusCode: $res');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  GpodderClient({
    required String serverUrl,
    required String username,
    required String password,
    required String deviceId,
    required String deviceName,
    http.Client? httpClient,
  })  : _serverUrl = serverUrl.endsWith('/')
            ? serverUrl.substring(0, serverUrl.length - 1)
            : serverUrl,
        _username = username,
        _password = password,
        _deviceId = deviceId,
        _deviceName = deviceName,
        _httpClient = httpClient ?? http.Client();

  void updateCredentials({
    String? serverUrl,
    String? username,
    String? password,
    String? deviceId,
    String? deviceName,
  }) {
    if (serverUrl != null) {
      _serverUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;
    }

    _username = username ?? _username;
    _password = password ?? _password;
    _deviceId = deviceId ?? _deviceId;
    _deviceName = deviceName ?? _deviceName;
    _sessionId = null;
  }

  Future<bool> login() async {
    try {
      log("Attempting login to $_serverUrl", name: logName);

      final String url = '$_baseUrl/api/2/auth/$_encodedUsername/login.json';
      final res = await _httpClient
          .post(Uri.parse(url), headers: _authHeaders)
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final cookies = res.headers['set-cookie'];
        if (cookies != null) {
          final sessionMatch = RegExp(r'sessionid=([^;]+)').firstMatch(cookies);
          if (sessionMatch != null) {
            _sessionId = sessionMatch.group(1);
            log("Login successful, session ID: ${_sessionId!.substring(0, 8)}...",
                name: logName);
            return true;
          }
        }
        log("Login successful but no session cookie found", name: logName);
        return true;
      } else if (res.statusCode == 401) {
        log("Login failed: Invalid credentials", name: logName);
        throw UnauthorizedException();
      } else {
        log("Login failed with status: ${res.statusCode}", name: logName);
        return false;
      }
    } catch (e) {
      log("Login error: $e", name: logName);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final path = '/api/2/auth/$_encodedUsername/logout.json';
      await _sendRequest('POST', path);
      _sessionId = null;
      log("Logged out", name: logName);
      return true;
    } catch (e) {
      log("Logout error: $e", name: logName);
      _sessionId = null;
      return false;
    }
  }

  // Subscriptions
  Future<bool> uploadAllSubscriptions(List<String> urls) async {
    log("Uploading all subscriptions: ${urls.length} URLs", name: logName);
    final path = '/subscriptions/$_encodedUsername/$_deviceId.json';
    await _sendRequest('PUT', path, body: urls);
    log("All subscriptions uploaded successfully", name: logName);
    return true;
  }

  Future<Map<String, dynamic>> uploadSubscriptionChanges({
    required List<String> add,
    required List<String> remove,
  }) async {
    log("Uploading subscription changes: add=${add.length}, remove=${remove.length}",
        name: logName);

    if (add.isEmpty && remove.isEmpty) {
      return {
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }

    final path = '/api/2/subscriptions/$_encodedUsername/$_deviceId.json';
    final result =
        await _sendRequest('POST', path, body: {'add': add, 'remove': remove});
    log("Subscription changes uploaded successfully", name: logName);
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSubscriptionChanges({int since = 0}) async {
    log("Fetching subscription changes since $since", name: logName);
    final path = '/api/2/subscriptions/$_encodedUsername/$_deviceId.json';
    final result = await _sendRequest('GET', path,
        queryParams: {'since': since.toString()});
    log("Subscription changes retrieved successfully", name: logName);
    return result as Map<String, dynamic>;
  }

  Future<List<String>> getAllSubscriptions() async {
    log("Fetching all subscriptions from server", name: logName);
    final path = '/subscriptions/$_deviceId.json';
    final result = await _sendRequest('GET', path);
    log("All subscriptions retrieved successfully", name: logName);
    return (result as List).cast<String>().toList();
  }

  // Episode actions
  Future<Map<String, dynamic>> uploadEpisodeActions(
      List<Map<String, dynamic>> actions) async {
    log("Uploading ${actions.length} episode actions", name: logName);

    if (actions.isEmpty) {
      log("No episode actions to upload", name: logName);
      return {
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'update_urls': []
      };
    }

    final formattedActions = actions
        .map((action) => {
              'podcast': action['podcast'],
              'episode': action['episode'],
              'action': action['action'],
              'position': action['position'] ?? 0,
              'timestamp': action['timestamp'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(
                      (action['timestamp'] as int) * 1000,
                    ).toUtc().toIso8601String()
                  : action['timestamp'],
            })
        .toList();

    final path = '/api/2/episodes/$_encodedUsername.json';
    final result = await _sendRequest('POST', path, body: formattedActions);
    log("Episode actions uploaded successfully", name: logName);
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEpisodeActions({int since = 0}) async {
    final path = '/api/2/episodes/$_encodedUsername.json';
    final result = await _sendRequest('GET', path,
        queryParams: {'since': since.toString()});
    log('getEpisodeActions response retrieved', name: logName);
    return result as Map<String, dynamic>;
  }

  // Device management
  Future<Map<String, dynamic>> getDeviceUpdates() async {
    log("Fetching device updates for device ID: $_deviceId", name: logName);
    final path = '/api/2/updates/$_encodedUsername/$_deviceId.json';
    final result = await _sendRequest('GET', path);
    log("Device updates retrieved successfully", name: logName);
    return result as Map<String, dynamic>;
  }

  Future<bool> registerDevice() async {
    log("Registering device with name: $_deviceName at $_baseUrl",
        name: logName);
    final path = '/api/2/devices/$_encodedUsername/$_deviceId.json';
    await _sendRequest('POST', path, body: {'caption': _deviceName});
    log("Device info updated: $_deviceName", name: logName);
    return true;
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    log("Fetching devices for user $_username", name: logName);
    final path = '/api/2/devices/$_encodedUsername.json';
    final result = await _sendRequest('GET', path);
    return (result as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSyncDevices() async {
    log("Fetching sync devices for user $_username", name: logName);
    final path = '/api/2/sync-devices/$_encodedUsername.json';
    final result = await _sendRequest('GET', path);
    return result as Map<String, dynamic>;
  }

  Future<bool> updateSyncDevices({
    required List<List<String>> synchronized,
    required List<String> notSynchronized,
  }) async {
    log("Updating sync devices: ${synchronized.length} synchronized, ${notSynchronized.length} not synchronized",
        name: logName);

    final path = '/api/2/sync-devices/$_encodedUsername.json';
    await _sendRequest('POST', path, body: {
      'synchronize': synchronized,
      'stop-synchronize': notSynchronized,
    });
    log("Sync devices updated successfully", name: logName);
    return true;
  }

  void dispose() {
    _httpClient.close();
  }
}
