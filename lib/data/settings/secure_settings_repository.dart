import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSettingsRepository {
  static const String logName = "SecureSettingsRepository";

  static const String _syncPasswordKey = "syncPassword";

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
  );

  Future<void> setSyncPassword(String password) async {
    log("Saving sync password", name: logName);
    await _storage.write(key: _syncPasswordKey, value: password);
  }

  Future<String> getSyncPassword() async {
    final String? password = await _storage.read(key: _syncPasswordKey);
    log("Loading sync password", name: logName);
    return password ?? '';
  }

  Future<void> clearSyncPassword() async {
    log("Clearing sync password", name: logName);
    await _storage.delete(key: _syncPasswordKey);
  }

  Future<void> clearAll() async {
    log("Clearing all secure settings", name: logName);
    await _storage.deleteAll();
  }
}
