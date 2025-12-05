import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poddr/data/settings/settings_repository.dart';

class SharedPrefSettingsRepository implements ISettingsRepository {
  static const String logName = "SharedPrefSettingsRepository";

  static const String _themeModeKey = "themeMode";
  static const String _colorKey = "themeColor";

  static const String _profileKey = "activeProfile";

  static const String _countryCodeKey = "countryCode";
  static const String _genreIDKey = "genreID";

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
    prefs.setInt(_profileKey, profileId);
  }

  @override
  Future<int> getActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final int profile = prefs.getInt(_profileKey) ?? 0;
    log("Loading active profile: $profile", name: logName);
    return profile;
  }

  @override
  Future<void> saveCountryCode(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving country code: $countryCode", name: logName);
    prefs.setString(_countryCodeKey, countryCode);
  }

  @override
  Future<String> getCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    final String countryCode = prefs.getString(_countryCodeKey) ?? 'us';
    log("Loading country code: $countryCode", name: logName);
    return countryCode;
  }

  @override
  Future<void> saveGenreID(String genreID) async {
    final prefs = await SharedPreferences.getInstance();
    log("Saving genre ID: $genreID", name: logName);
    prefs.setString(_genreIDKey, genreID);
  }

  @override
  Future<String> getGenreID() async {
    final prefs = await SharedPreferences.getInstance();
    final String genreID = prefs.getString(_genreIDKey) ?? 'us';
    log("Loading genre ID: $genreID", name: logName);
    return genreID;
  }
}
