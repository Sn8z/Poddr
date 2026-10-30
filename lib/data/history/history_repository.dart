import 'package:poddr/models/episode.dart';
import 'package:poddr/models/progress.dart';

abstract class IHistoryRepository {
  Future<void> upsertProgress(
    String audioUrl, {
    required int position,
    required int duration,
    bool markFinished = true,
    String? title,
    String? description,
    String? imageUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? videoUrl,
  });

  Future<List<PodcastEpisode>> getHistory();

  Future<EpisodeProgress?> getProgress(String audioUrl);

  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl);

  Stream<List<PodcastEpisode>> watchAllHistory();

  Stream<List<PodcastEpisode>> watchHistoryForPodcast(String podcastRSS);

  Future<void> removeHistory(String audioUrl);
}
