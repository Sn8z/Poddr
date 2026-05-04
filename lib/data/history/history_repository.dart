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
    int duration,
    String? videoUrl,
  );

  Future<List<PodcastEpisode>> getHistory();

  Future<void> updateProgress(String audioUrl, int position, int duration);

  Future<Map<String, dynamic>?> getProgress(String audioUrl);

  Stream<ListeningHistoryData?> getProgressStream(String audioUrl);

  Future<void> removeHistory(String audioUrl);
}
