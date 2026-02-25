import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/models/episode.dart';

abstract class IHistoryRepository {
  Future<PodcastEpisode?> addHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int position,
    int duration,
    int profileId,
  );

  Future<List<PodcastEpisode>> getHistory(int profileId);

  Future<void> updateProgress(
      int profileId, String audioUrl, int position, int duration);

  Future<Map<String, dynamic>?> getProgress(int profileId, String audioUrl);

  Stream<ListeningHistoryData?> getProgressStream(
      int profileId, String audioUrl);

  Future<void> removeHistory(int profileId, String audioUrl);
}
