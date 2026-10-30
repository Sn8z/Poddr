import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/progress.dart';

class DriftHistoryRepository implements IHistoryRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftHistoryRepository();

  @override
  Future<List<PodcastEpisode>> getHistory() async {
    final history = await (database.select(database.listeningHistory)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.listenedAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .get();

    return history.map((episode) {
      return PodcastEpisode(
        title: episode.title,
        podcastTitle: episode.podcastTitle,
        podcastRSS: episode.podcastRSS,
        description: episode.description,
        audioUrl: episode.audioUrl,
        videoUrl: episode.videoUrl,
        duration: Duration(seconds: episode.duration),
        publicationDate: null,
        imageUrl: episode.imageUrl,
      );
    }).toList();
  }

  @override
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
  }) async {
    final metadataFields = [
      title,
      description,
      imageUrl,
      podcastTitle,
      podcastRSS,
    ];
    final providedMetadata = metadataFields.whereType<String>().length;
    assert(
      providedMetadata == 0 || providedMetadata == metadataFields.length,
      'Provide all episode metadata fields or none.',
    );

    final hasMetadata = providedMetadata == metadataFields.length;
    final safePosition = position < 0 ? 0 : position;
    final hasValidDuration = duration > 0;
    final Value<bool> isFinished = hasValidDuration && markFinished
        ? Value((safePosition / duration) >= .9)
        : const Value.absent();

    await database.transaction(() async {
      final existing = await (database.select(database.listeningHistory)
            ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
          .getSingleOrNull();

      if (existing == null) {
        if (!hasMetadata) return;

        await database.into(database.listeningHistory).insert(
              ListeningHistoryCompanion.insert(
                audioUrl: audioUrl,
                title: title!,
                description: description!,
                imageUrl: imageUrl!,
                podcastTitle: podcastTitle!,
                podcastRSS: podcastRSS!,
                position: Value(safePosition),
                duration: hasValidDuration ? duration : 0,
                isFinished: isFinished,
                listenedAt: Value(DateTime.now()),
                videoUrl: Value(videoUrl),
              ),
            );
        return;
      }

      await (database.update(database.listeningHistory)
            ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
          .write(
        ListeningHistoryCompanion(
          title: hasMetadata ? Value(title!) : const Value.absent(),
          description: hasMetadata ? Value(description!) : const Value.absent(),
          imageUrl: hasMetadata ? Value(imageUrl!) : const Value.absent(),
          podcastTitle:
              hasMetadata ? Value(podcastTitle!) : const Value.absent(),
          podcastRSS: hasMetadata ? Value(podcastRSS!) : const Value.absent(),
          videoUrl: hasMetadata ? Value(videoUrl) : const Value.absent(),
          position: Value(safePosition),
          duration: hasValidDuration ? Value(duration) : const Value.absent(),
          isFinished: isFinished,
          listenedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<EpisodeProgress?> getProgress(String audioUrl) async {
    final history = await (database.select(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .getSingleOrNull();

    if (history == null) return null;

    return EpisodeProgress(
      position: history.position,
      duration: history.duration,
      isFinished: history.isFinished,
    );
  }

  @override
  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl) {
    return (database.select(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .watchSingleOrNull()
        .map((history) => history == null
            ? null
            : EpisodeProgress(
                position: history.position,
                duration: history.duration,
                isFinished: history.isFinished,
              ));
  }

  @override
  Stream<List<PodcastEpisode>> watchAllHistory() {
    return (database.select(database.listeningHistory)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.listenedAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((history) => history
            .map((ep) => PodcastEpisode(
                  title: ep.title,
                  podcastTitle: ep.podcastTitle,
                  podcastRSS: ep.podcastRSS,
                  description: ep.description,
                  audioUrl: ep.audioUrl,
                  videoUrl: ep.videoUrl,
                  duration: Duration(seconds: ep.duration),
                  publicationDate: null,
                  imageUrl: ep.imageUrl,
                ))
            .toList());
  }

  @override
  Stream<List<PodcastEpisode>> watchHistoryForPodcast(String podcastRSS) {
    return (database.select(database.listeningHistory)
          ..where((tbl) => tbl.podcastRSS.equals(podcastRSS))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.listenedAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((history) => history
            .map((ep) => PodcastEpisode(
                  title: ep.title,
                  podcastTitle: ep.podcastTitle,
                  podcastRSS: ep.podcastRSS,
                  description: ep.description,
                  audioUrl: ep.audioUrl,
                  videoUrl: ep.videoUrl,
                  duration: Duration(seconds: ep.duration),
                  publicationDate: null,
                  imageUrl: ep.imageUrl,
                ))
            .toList());
  }

  @override
  Future<void> removeHistory(String audioUrl) async {
    await (database.delete(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .go();
  }
}
