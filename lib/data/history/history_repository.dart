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

  Future<EpisodeProgress?> getProgress(String audioUrl);

  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl);

  Stream<List<PodcastEpisode>> watchRecentHistory();

  Future<void> removeHistory(String audioUrl);
}
