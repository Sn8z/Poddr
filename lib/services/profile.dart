import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:poddr/data/profiles/drift_profiles_repository.dart';
import 'package:poddr/data/profiles/profiles_repository.dart';
import 'package:poddr/models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final String logName = "ProfileProvider";

  final IProfileRepository _profileRepository;

  static const String _defaultProfileName = "Default";

  List<UserProfile> _profiles = [];
  List<UserProfile> get profiles => _profiles;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;

  ProfileProvider({IProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? DriftProfileRepository();
  Future<void> init() async {
    try {
      _profiles = await _profileRepository.getProfiles();

      if (_profiles.isEmpty) {
        final profileId =
            await _profileRepository.createProfile(_defaultProfileName);

        final newDefault = await _profileRepository.getProfile(profileId);

        _profiles.add(newDefault);
        _currentProfile = newDefault;
      } else {
        _currentProfile = _profiles.first;
      }
    } catch (e, stack) {
      log(e.toString(), name: logName, error: e, stackTrace: stack);
    } finally {
      notifyListeners();
    }
  }

  Future<void> activateProfile(int profileId) async {
    _currentProfile = await _profileRepository.getProfile(profileId);
    notifyListeners();
  }

  Future<void> createProfile(String name) async {
    try {
      final newId = await _profileRepository.createProfile(name);
      final newProfile = await _profileRepository.getProfile(newId);

      _profiles.add(newProfile);
      _currentProfile ??= newProfile;
    } catch (e, stack) {
      log('Create failed: $e', name: logName, error: e, stackTrace: stack);
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
      }
    } catch (e, stack) {
      log('Delete failed: $e', name: logName, error: e, stackTrace: stack);
    } finally {
      notifyListeners();
    }
  }
}
