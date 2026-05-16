import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/core/theme/poddr_theme_mode.dart';

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
    debug("Saving color: $colorInt", name: logName);
    prefs.setInt(_colorKey, colorInt);
  }

  @override
  Future<Color> getColor() async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getInt(_colorKey) ?? 4294940190;
    debug("Loading color: $color", name: logName);
    return Color(color);
  }

  @override
  Future<void> setThemeMode(PoddrThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving theme mode: $mode", name: logName);
    prefs.setInt(_themeModeKey, mode.index);
  }

  @override
  Future<PoddrThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getInt(_themeModeKey) ?? 0;
    debug("Loading theme mode: $themeMode", name: logName);
    return PoddrThemeMode.values[themeMode];
  }

  @override
  Future<void> saveActiveProfile(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving active profile: $profileId", name: logName);
    prefs.setInt(_profileKey, profileId);
  }

  @override
  Future<int> getActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final int profile = prefs.getInt(_profileKey) ?? 0;
    debug("Loading active profile: $profile", name: logName);
    return profile;
  }

  @override
  Future<void> saveCountryCode(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving country code: $countryCode", name: logName);
    prefs.setString(_countryCodeKey, countryCode);
  }

  @override
  Future<String> getCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    final String countryCode = prefs.getString(_countryCodeKey) ?? 'us';
    debug("Loading country code: $countryCode", name: logName);
    return countryCode;
  }

  @override
  Future<void> saveGenreID(String genreID) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving genre ID: $genreID", name: logName);
    prefs.setString(_genreIDKey, genreID);
  }

  @override
  Future<String> getGenreID() async {
    final prefs = await SharedPreferences.getInstance();
    final String genreID = prefs.getString(_genreIDKey) ?? '';
    debug("Loading genre ID: $genreID", name: logName);
    return genreID;
  }

  static const String _syncEnabledKey = "syncEnabled";
  static const String _syncDeviceIdKey = "syncDeviceId";
  static const String _syncDeviceNameKey = "syncDeviceName";
  static const String _syncLastSubscriptionSyncKey = "syncLastSubscriptionSync";
  static const String _syncLastEpisodeSyncKey = "syncLastEpisodeSync";

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving sync enabled: $enabled", name: logName);
    prefs.setBool(_syncEnabledKey, enabled);
  }

  @override
  Future<bool> getSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_syncEnabledKey) ?? false;
    debug("Loading sync enabled: $enabled", name: logName);
    return enabled;
  }

  @override
  Future<void> setSyncDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving sync device ID: $deviceId", name: logName);
    prefs.setString(_syncDeviceIdKey, deviceId);
  }

  @override
  Future<String> getSyncDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final String deviceId = prefs.getString(_syncDeviceIdKey) ?? '';
    debug("Loading sync device ID: $deviceId", name: logName);
    return deviceId;
  }

  @override
  Future<void> setSyncDeviceName(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving sync device name: $deviceName", name: logName);
    prefs.setString(_syncDeviceNameKey, deviceName);
  }

  @override
  Future<String> getSyncDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final String deviceName = prefs.getString(_syncDeviceNameKey) ?? 'Poddr';
    debug("Loading sync device name: $deviceName", name: logName);
    return deviceName;
  }

  @override
  Future<void> setSyncLastSubscriptionSync(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving last subscription sync: $timestamp", name: logName);
    prefs.setInt(_syncLastSubscriptionSyncKey, timestamp);
  }

  @override
  Future<int> getSyncLastSubscriptionSync() async {
    final prefs = await SharedPreferences.getInstance();
    final int timestamp = prefs.getInt(_syncLastSubscriptionSyncKey) ?? 0;
    debug("Loading last subscription sync: $timestamp", name: logName);
    return timestamp;
  }

  @override
  Future<void> setSyncLastEpisodeSync(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    debug("Saving last episode sync: $timestamp", name: logName);
    prefs.setInt(_syncLastEpisodeSyncKey, timestamp);
  }

  @override
  Future<int> getSyncLastEpisodeSync() async {
    final prefs = await SharedPreferences.getInstance();
    final int timestamp = prefs.getInt(_syncLastEpisodeSyncKey) ?? 0;
    debug("Loading last episode sync: $timestamp", name: logName);
    return timestamp;
  }
}
