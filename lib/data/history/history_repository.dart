import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/models/episode.dart';

abstract class IHistoryRepository {
  Future<void> addHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int position,
    int duration,
  );

  Future<List<PodcastEpisode>> getHistory();

  Future<List<PodcastEpisode>> getMostRecentHistory({int limit = 10});

  Future<void> updateProgress(String audioUrl, int position, int duration);

  Future<Map<String, dynamic>?> getProgress(String audioUrl);

  Stream<ListeningHistoryData?> getProgressStream(String audioUrl);

  Future<void> removeHistory(String audioUrl);
}
