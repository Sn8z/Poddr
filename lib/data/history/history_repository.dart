import 'package:poddr/models/episode.dart';
import 'package:poddr/models/progress.dart';

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

  Future<void> updateProgress(
    String audioUrl,
    int position,
    int duration, {
    bool markFinished = true,
  });

  Future<EpisodeProgress?> getProgress(String audioUrl);

  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl);

  Stream<List<PodcastEpisode>> watchAllHistory();

  Stream<List<PodcastEpisode>> watchHistoryForPodcast(String podcastRSS);

  Future<void> removeHistory(String audioUrl);
}
