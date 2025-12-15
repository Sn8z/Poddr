import 'dart:developer';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/profiles/profiles_repository.dart';
import 'package:poddr/models/user_profile.dart';

class DriftProfileRepository implements IProfileRepository {
  static const String logName = "DriftProfileRepository";

  final PoddrDatabase _profileDb = PoddrDatabase();

  @override
  Future<UserProfile?> getProfile(int id) async {
    log("Fetching profile with ID: $id", name: logName);
    final profile = await (_profileDb.select(_profileDb.profile)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return profile == null ? null : _mapUserProfile(profile);
  }

  @override
  Future<int> createProfile(String name) async {
    log("Creating profile with name: $name", name: logName);
    final profileId = await _profileDb
        .into(_profileDb.profile)
        .insert(ProfileCompanion.insert(name: name));

    return profileId;
  }

  @override
  Future<void> deleteProfile(int id) async {
    log("Deleting profile with ID: $id", name: logName);
    await (_profileDb.delete(_profileDb.profile)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<List<UserProfile>> getProfiles() async {
    log("Fetching all profiles", name: logName);
    final profiles = await _profileDb.select(_profileDb.profile).get();
    return profiles.map(_mapUserProfile).toList();
  }

  UserProfile _mapUserProfile(ProfileData dbProfile) {
    return UserProfile(id: dbProfile.id, name: dbProfile.name);
  }
}
