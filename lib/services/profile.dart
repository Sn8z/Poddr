import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:poddr/data/profiles/drift_profiles_repository.dart';
import 'package:poddr/data/profiles/profiles_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const String logName = "ProfileProvider";

  final IProfileRepository _profileRepository;
  final ISettingsRepository _settingsRepository;

  static const String _defaultProfileName = "Default";

  List<UserProfile> _profiles = [];
  List<UserProfile> get profiles => _profiles;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;

  ProfileProvider(
      {IProfileRepository? profileRepository,
      ISettingsRepository? settingsRepository})
      : _profileRepository = profileRepository ?? DriftProfileRepository(),
        _settingsRepository =
            settingsRepository ?? SharedPrefSettingsRepository();

  Future<void> init() async {
    log("Initializing ProfileProvider", name: logName);

    try {
      _profiles = await _profileRepository.getProfiles();

      if (_profiles.isEmpty) {
        await _createAndActivateDefaultProfile();
      } else {
        await _loadSavedProfile();
      }
    } catch (e, stack) {
      log("Init failed", name: logName, error: e, stackTrace: stack);

      if (_profiles.isNotEmpty) {
        _currentProfile ??= _profiles.first;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _createAndActivateDefaultProfile() async {
    log("No profiles found, creating default profile", name: logName);

    final id = await _profileRepository.createProfile(_defaultProfileName);
    final profile = await _profileRepository.getProfile(id);

    if (profile == null) {
      throw StateError("Failed to create default profile");
    }

    _profiles = [profile];
    _currentProfile = profile;

    await _settingsRepository.saveActiveProfile(profile.id);
  }

  Future<void> _loadSavedProfile() async {
    final savedProfileId = await _settingsRepository.getActiveProfile();
    _currentProfile = _resolveActiveProfile(savedProfileId);
    await _settingsRepository.saveActiveProfile(_currentProfile!.id);
  }

  UserProfile _resolveActiveProfile(int savedProfileId) {
    if (savedProfileId == 0) {
      log("No saved profile, defaulting to first", name: logName);
      return _profiles.first;
    }

    final match = _profiles.firstWhere(
      (p) => p.id == savedProfileId,
      orElse: () {
        log(
          "Saved profile $savedProfileId not found, falling back",
          name: logName,
        );
        return _profiles.first;
      },
    );

    log("Resolved active profile: ${match.id}", name: logName);
    return match;
  }

  Future<void> activateProfile(int profileId) async {
    final profile = await _profileRepository.getProfile(profileId);

    if (profile == null) {
      log("Attempted to activate non-existing profile $profileId",
          name: logName);
      return;
    }

    _currentProfile = profile;
    await _settingsRepository.saveActiveProfile(profileId);
    notifyListeners();
  }

  Future<void> createProfile(String name) async {
    try {
      final newId = await _profileRepository.createProfile(name);
      final newProfile = await _profileRepository.getProfile(newId);

      if (newProfile == null) {
        log("Profile created but could not be loaded", name: logName);
        return;
      }

      _profiles.add(newProfile);

      if (_currentProfile == null) {
        _currentProfile = newProfile;
        await _settingsRepository.saveActiveProfile(newProfile.id);
      }
    } catch (e, stack) {
      log("Create failed", name: logName, error: e, stackTrace: stack);
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteProfile(int profileId) async {
    try {
      await _profileRepository.deleteProfile(profileId);
      _profiles.removeWhere((p) => p.id == profileId);

      if (_currentProfile?.id == profileId) {
        _currentProfile = _profiles.isNotEmpty ? _profiles.first : null;

        if (_currentProfile != null) {
          await _settingsRepository.saveActiveProfile(_currentProfile!.id);
        }
      }
    } catch (e, stack) {
      log("Delete failed", name: logName, error: e, stackTrace: stack);
    } finally {
      notifyListeners();
    }
  }
}
