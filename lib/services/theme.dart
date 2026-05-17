import 'package:flutter/widgets.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/theme/poddr_theme_data.dart';
import 'package:poddr/core/theme/poddr_theme_mode.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/settings/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  static const String logName = "ThemeProvider";
  final ISettingsRepository _settingsRepository;

  Color _color = const Color.fromRGBO(0xFF, 0xA5, 0x00, 1);
  Color get color => _color;

  PoddrThemeData _lightTheme = PoddrThemeData.light(
    const Color.fromRGBO(0xFF, 0xA5, 0x00, 1),
  );
  PoddrThemeData get lightTheme => _lightTheme;

  PoddrThemeData _darkTheme = PoddrThemeData.dark(
    const Color.fromRGBO(0xFF, 0xA5, 0x00, 1),
  );
  PoddrThemeData get darkTheme => _darkTheme;

  PoddrThemeMode _themeMode = PoddrThemeMode.system;
  PoddrThemeMode get themeMode => _themeMode;

  ThemeProvider({ISettingsRepository? settingsRepository})
      : _settingsRepository =
            settingsRepository ?? SharedPrefSettingsRepository() {
    _loadTheme();
  }

  PoddrThemeData resolveTheme(Brightness systemBrightness) {
    if (_themeMode == PoddrThemeMode.light) return _lightTheme;
    if (_themeMode == PoddrThemeMode.dark) return _darkTheme;
    return systemBrightness == Brightness.dark ? _darkTheme : _lightTheme;
  }

  Future<void> _loadTheme() async {
    debug("Loading theme settings", name: logName);
    _themeMode = await _settingsRepository.getThemeMode();
    _color = await _settingsRepository.getColor();
    debug("Loaded theme: mode=$_themeMode, color=$_color", name: logName);
    _updateThemes();
    notifyListeners();
  }

  void _updateThemes() {
    _lightTheme = PoddrThemeData.light(_color);
    _darkTheme = PoddrThemeData.dark(_color);
  }

  Future<void> setColor(Color color) async {
    debug("Setting color to $color", name: logName);
    _color = color;
    _updateThemes();
    notifyListeners();
    await _settingsRepository.setColor(_color);
    info("Color updated", name: logName);
  }

  Future<void> setThemeMode(PoddrThemeMode mode) async {
    debug("Setting theme mode to $mode", name: logName);
    _themeMode = mode;
    _updateThemes();
    notifyListeners();
    await _settingsRepository.setThemeMode(_themeMode);
    info("Theme mode updated to $mode", name: logName);
  }
}
