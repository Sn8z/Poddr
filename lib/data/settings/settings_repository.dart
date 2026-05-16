import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme_mode.dart';

abstract class ISettingsRepository {
  Future<void> setColor(Color color);
  Future<Color> getColor();

  Future<void> setThemeMode(PoddrThemeMode mode);
  Future<PoddrThemeMode> getThemeMode();

  Future<void> saveActiveProfile(int profileId);
  Future<int> getActiveProfile();

  Future<void> saveCountryCode(String countryCode);
  Future<String> getCountryCode();

  Future<void> saveGenreID(String genreID);
  Future<String> getGenreID();

  Future<void> setSyncEnabled(bool enabled);
  Future<bool> getSyncEnabled();

  Future<void> setSyncDeviceId(String deviceId);
  Future<String> getSyncDeviceId();

  Future<void> setSyncDeviceName(String deviceName);
  Future<String> getSyncDeviceName();

  Future<void> setSyncLastSubscriptionSync(int timestamp);
  Future<int> getSyncLastSubscriptionSync();

  Future<void> setSyncLastEpisodeSync(int timestamp);
  Future<int> getSyncLastEpisodeSync();
}
