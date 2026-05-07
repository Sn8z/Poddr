import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:poddr/core/log.dart';

class SecureSettingsRepository {
  static const String logName = "SecureSettingsRepository";

  static const String _syncPasswordKey = "syncPassword";
  static const String _syncServerUrlKey = "syncServerUrl";
  static const String _syncUsernameKey = "syncUsername";

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
  );

  Future<void> setSyncPassword(String password) async {
    debug("Saving sync password", name: logName);
    await _storage.write(key: _syncPasswordKey, value: password);
  }

  Future<String> getSyncPassword() async {
    final String? password = await _storage.read(key: _syncPasswordKey);
    debug("Loading sync password", name: logName);
    return password ?? '';
  }

  Future<void> clearSyncPassword() async {
    debug("Clearing sync password", name: logName);
    await _storage.delete(key: _syncPasswordKey);
  }

  Future<void> clearAll() async {
    debug("Clearing all secure settings", name: logName);
    await _storage.deleteAll();
  }

  Future<void> setSyncServerUrl(String url) async {
    debug("Saving sync server URL to secure storage", name: logName);
    await _storage.write(key: _syncServerUrlKey, value: url);
  }

  Future<String> getSyncServerUrl() async {
    final url = await _storage.read(key: _syncServerUrlKey);
    debug("Loading sync server URL from secure storage", name: logName);
    return url ?? '';
  }

  Future<void> setSyncUsername(String username) async {
    debug("Saving sync username to secure storage", name: logName);
    await _storage.write(key: _syncUsernameKey, value: username);
  }

  Future<String> getSyncUsername() async {
    final username = await _storage.read(key: _syncUsernameKey);
    debug("Loading sync username from secure storage", name: logName);
    return username ?? '';
  }
}
