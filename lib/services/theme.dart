import 'package:flutter/material.dart';
import 'package:poddr/ui/utils/theme_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = "themeMode";
  ThemeMode _themeMode = ThemeMode.system;
  static const String _colorKey = "themeColor";
  Color _color = colors[0].color;
  SharedPreferences? _prefs;

  ThemeData _lightTheme = ThemeData.light();
  ThemeData get lightTheme => _lightTheme;

  ThemeData _darkTheme = ThemeData.dark();
  ThemeData get darkTheme => _darkTheme;

  ThemeMode get themeMode => _themeMode;
  Color get color => _color;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode
        .values[_prefs?.getInt(_themeModeKey) ?? ThemeMode.system.index];
    _color = Color(_prefs?.getInt(_colorKey) ?? Colors.red.value);
    _updateThemes();
    notifyListeners();
  }

  void _updateThemes() {
    _lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: _color,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        primary: _color,
      ),
    );

    _darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: const Color.fromARGB(255, 15, 15, 15),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        primary: _color,
        onPrimary: const Color.fromRGBO(15, 15, 15, 1),
        onPrimaryContainer: const Color.fromRGBO(15, 15, 15, 1),
        onPrimaryFixed: const Color.fromRGBO(15, 15, 15, 1),
        onPrimaryFixedVariant: const Color.fromRGBO(15, 15, 15, 1),
        onSecondary: const Color.fromRGBO(15, 15, 15, 1),
        onSecondaryContainer: const Color.fromRGBO(15, 15, 15, 1),
        onSecondaryFixed: const Color.fromRGBO(15, 15, 15, 1),
        onSecondaryFixedVariant: const Color.fromRGBO(15, 15, 15, 1),
        onTertiary: const Color.fromRGBO(15, 15, 15, 1),
        onTertiaryContainer: const Color.fromRGBO(15, 15, 15, 1),
        onTertiaryFixed: const Color.fromRGBO(15, 15, 15, 1),
        onTertiaryFixedVariant: const Color.fromRGBO(15, 15, 15, 1),
        onError: const Color.fromRGBO(15, 15, 15, 1),
        onErrorContainer: const Color.fromRGBO(15, 15, 15, 1),
        onSurface: const Color.fromARGB(255, 255, 255, 255),
        surface: const Color.fromRGBO(15, 15, 15, 1),
        surfaceBright: const Color.fromRGBO(25, 25, 25, 1),
        surfaceDim: const Color.fromRGBO(15, 15, 15, 0.5),
        surfaceContainerLowest: const Color.fromRGBO(15, 15, 15, 1),
        surfaceContainerLow: const Color.fromRGBO(20, 20, 20, 1),
        surfaceContainer: const Color.fromRGBO(25, 25, 25, 1),
        surfaceContainerHigh: const Color.fromRGBO(35, 35, 35, 1),
        surfaceContainerHighest: const Color.fromRGBO(50, 50, 50, 1),
      ),
    );
  }

  Future<void> setColor(Color color) async {
    _color = color;
    _updateThemes();
    notifyListeners();
    await _prefs?.setInt(_colorKey, _color.value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateThemes();
    notifyListeners();
    await _prefs?.setInt(_themeModeKey, _themeMode.index);
  }
}
