import 'package:flutter/material.dart';

abstract class ISettingsRepository {
  Future<void> init();
  Future<void> setColor(Color color);
  Future<Color> getColor();
  Future<void> setThemeMode(ThemeMode mode);
  Future<ThemeMode> getThemeMode();

  Future<void> saveActiveProfile(int profileId);
  Future<int?> getActiveProfile();
}
