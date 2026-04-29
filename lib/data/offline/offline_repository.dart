import 'package:poddr/models/offline_episode.dart';

abstract class IOfflineRepository {
  Future<List<OfflineEpisode>> getAll();

  Future<OfflineEpisode?> getByAudioUrl(String audioUrl);

  Future<void> addEpisode({
    required String audioUrl,
    required String localPath,
    required String title,
    required String description,
    required String imageUrl,
    required String podcastTitle,
    required String podcastRSS,
    required int duration,
    required int fileSize,
    DateTime? publicationDate,
  });

  Future<void> remove(String audioUrl);

  Future<void> clearAll();

  Stream<List<OfflineEpisode>> watchAll();

  Future<String> getLocalPathForDownload(String audioUrl);

  Future<String?> getLocalPath(String audioUrl);
}
