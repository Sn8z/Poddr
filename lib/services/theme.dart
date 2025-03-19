import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poddr/data/settings/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final ISettingsRepository _settingsRepository =
      SavedPrefsSettingsRepository();

  ThemeMode _themeMode = ThemeMode.system;
  Color _color = const Color(4294940190);

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
    await _settingsRepository.init();
    _themeMode = await _settingsRepository.getThemeMode();
    _color = await _settingsRepository.getColor();
    _updateThemes();
    notifyListeners();
  }

  void _updateThemes() {
    _lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
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
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
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
        surface: const Color.fromRGBO(25, 25, 25, 1),
        surfaceBright: const Color.fromRGBO(30, 30, 30, 1),
        surfaceDim: const Color.fromRGBO(15, 15, 15, 0.5),
        surfaceContainerLowest: const Color.fromRGBO(20, 20, 20, 1),
        surfaceContainerLow: const Color.fromRGBO(30, 30, 30, 1),
        surfaceContainer: const Color.fromRGBO(40, 40, 40, 1),
        surfaceContainerHigh: const Color.fromRGBO(50, 50, 50, 1),
        surfaceContainerHighest: const Color.fromRGBO(60, 60, 60, 1),
      ),
    );
  }

  Future<void> setColor(Color color) async {
    _color = color;
    _updateThemes();
    notifyListeners();
    await _settingsRepository.setColor(_color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateThemes();
    notifyListeners();
    await _settingsRepository.setThemeMode(_themeMode);
  }
}
