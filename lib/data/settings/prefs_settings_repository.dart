import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefSettingsRepository implements ISettingsRepository {
  static const String logName = "SharedPrefSettingsRepository";
  static const String _themeModeKey = "themeMode";
  static const String _colorKey = "themeColor";

  @override
  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final int colorInt = color.toARGB32();
    log("Saving color: $colorInt", name: logName);
    prefs.setInt(_colorKey, colorInt);
  }

  @override
  Future<Color> getColor() async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getInt(_colorKey) ?? 4294940190;
    log("Loading color: $color", name: logName);
    return Color(color);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving theme mode: $mode", name: logName);
    prefs.setInt(_themeModeKey, mode.index);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getInt(_themeModeKey) ?? 0;
    log("Loading theme mode: $themeMode", name: logName);
    return ThemeMode.values[themeMode];
  }

  @override
  Future<void> saveActiveProfile(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving active profile: $profileId", name: logName);
    prefs.setInt("activeProfile", profileId);
  }

  @override
  Future<int> getActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final int profile = prefs.getInt("activeProfile") ?? 0;
    log("Loading active profile: $profile", name: logName);
    return profile;
  }
}
