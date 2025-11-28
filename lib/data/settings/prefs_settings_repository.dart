import 'package:flutter/material.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefSettingsRepository implements ISettingsRepository {
  static const String _themeModeKey = "themeMode";
  static const String _colorKey = "themeColor";

  SharedPreferences? _prefs;

  SharedPrefSettingsRepository() {
    init();
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setColor(Color color) async {
    await _prefs?.setInt(_colorKey, color.toARGB32());
  }

  @override
  Future<Color> getColor() async {
    final color = _prefs?.getInt(_colorKey);
    return Color(color ?? 4294940190);
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

  @override
  Future<void> saveActiveProfile(int profileId) async {
    await _prefs?.setInt("activeProfile", profileId);
  }

  @override
  Future<int?> getActiveProfile() async {
    return _prefs?.getInt("activeProfile");
  }
}
