import 'package:poddr/models/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> getProfile(int id);

  Future<int> createProfile(String name);

  Future<void> deleteProfile(int id);

  Future<List<UserProfile>> getProfiles();
}
