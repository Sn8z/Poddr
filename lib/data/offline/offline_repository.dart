import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/core/poddr_http_client.dart';

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
    // Video support
    String? videoUrl,
    String? videoLocalPath,
    int? videoFileSize,
  });

  Future<void> remove(String audioUrl);

  Future<void> clearAll();

  Stream<List<OfflineEpisode>> watchAllEpisodes();

  Future<String> getLocalPathForDownload(String audioUrl);

  Future<String?> getLocalPath(String audioUrl);

  // Video support
  Future<String?> getVideoLocalPath(String audioUrl);

  Future<void> downloadEpisode(
    PodcastEpisode episode, {
    required Function(double) onProgress,
    required Function() onCancel,
    required PoddrHttpClient client,
  });
}
