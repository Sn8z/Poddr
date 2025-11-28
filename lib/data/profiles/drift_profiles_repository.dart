import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/profiles/profiles_repository.dart';
import 'package:poddr/models/user_profile.dart';

class DriftProfileRepository implements IProfileRepository {
  final PoddrDatabase _profileDb = PoddrDatabase();

  @override
  Future<UserProfile> getProfile(int id) async {
    final profile = await (_profileDb.select(_profileDb.profile)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (profile == null) {
      throw Exception('Profile not found');
    }

    return UserProfile(id: profile.id, name: profile.name);
  }

  @override
  Future<int> createProfile(String name) async {
    final profileId = await _profileDb
        .into(_profileDb.profile)
        .insert(ProfileCompanion.insert(name: name));

    return profileId;
  }

  @override
  Future<void> deleteProfile(int id) async {
    await (_profileDb.delete(_profileDb.profile)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Future<List<UserProfile>> getProfiles() async {
    final profiles = await _profileDb.select(_profileDb.profile).get();

    return profiles.map((e) => UserProfile(id: e.id, name: e.name)).toList();
  }
}
