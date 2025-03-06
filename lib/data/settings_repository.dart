import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ISettingsRepository {
  Future<void> init();
  Future<void> setColor(Color color);
  Future<Color> getColor();
  Future<void> setThemeMode(ThemeMode mode);
  Future<ThemeMode> getThemeMode();
}

class SavedPrefsSettingsRepository implements ISettingsRepository {
  static const String _themeModeKey = "themeMode";
  static const String _colorKey = "themeColor";

  SharedPreferences? _prefs;

  SavedPrefsSettingsRepository() {
    init();
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setColor(Color color) async {
    await _prefs?.setInt(_colorKey, color.value);
  }

  @override
  Future<Color> getColor() async {
    final color = _prefs?.getInt(_colorKey);
    return Color(color ?? 0);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setInt(_themeModeKey, mode.index);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeMode = _prefs?.getInt(_themeModeKey);
    return ThemeMode.values[themeMode ?? 0];
  }
}
