import 'package:flutter/widgets.dart';

class SyncSetupProvider extends ChangeNotifier {
  String _server;
  String _username;
  String _password;
  String _deviceName;
  bool _showPassword;

  SyncSetupProvider({
    String? initialServer,
    String? initialUsername,
    String? initialDeviceName,
  })  : _server = initialServer ?? '',
        _username = initialUsername ?? '',
        _password = '',
        _deviceName = initialDeviceName ?? 'Poddr',
        _showPassword = false;

  String get server => _server;
  String get username => _username;
  String get password => _password;
  String get deviceName => _deviceName;
  bool get showPassword => _showPassword;

  void updateServer(String value) {
    _server = value;
    notifyListeners();
  }

  void updateUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    notifyListeners();
  }

  void updateDeviceName(String value) {
    _deviceName = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }
}
