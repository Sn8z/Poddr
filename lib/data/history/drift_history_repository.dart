import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';

class DriftHistoryRepository implements IHistoryRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftHistoryRepository();

  @override
  Future<PodcastEpisode?> addHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int duration,
    String? videoUrl,
  ) async {
    final id = await database.into(database.listeningHistory).insert(
          ListeningHistoryCompanion.insert(
            audioUrl: audioUrl,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            duration: duration,
            videoUrl: Value(videoUrl),
          ),
        );

    final inserted = await (database.select(database.listeningHistory)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (inserted == null) return null;

    return PodcastEpisode(
      title: inserted.title,
      podcastTitle: inserted.podcastTitle,
      podcastRSS: inserted.podcastRSS,
      description: inserted.description,
      audioUrl: inserted.audioUrl,
      videoUrl: inserted.videoUrl,
      duration: Duration(seconds: inserted.duration),
      publicationDate: null,
      imageUrl: inserted.imageUrl,
    );
  }

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
  Future<void> updateProgress(
    String audioUrl,
    int position,
    int duration,
  ) async {
    final bool isFinished = (position / duration) >= .9;
    await (database.update(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .write(
      ListeningHistoryCompanion(
        position: Value(position),
        duration: Value(duration),
        isFinished: Value(isFinished),
        listenedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getProgress(String audioUrl) async {
    final history = await (database.select(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .getSingleOrNull();

    if (history == null) {
      return null;
    } else {
      return {
        'title': history.title,
        'description': history.description,
        'audioUrl': history.audioUrl,
        'videoUrl': history.videoUrl,
        'imageUrl': history.imageUrl,
        'podcastTitle': history.podcastTitle,
        'podcastRSS': history.podcastRSS,
        'position': history.position,
        'duration': history.duration,
        'isFinished': history.isFinished,
        'listenedAt': history.listenedAt,
      };
    }
  }

  @override
  Stream<ListeningHistoryData?> watchProgressByAudioUrl(String audioUrl) {
    return (database.select(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .watchSingleOrNull();
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
