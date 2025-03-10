import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';

class DriftHistoryRepository implements IHistoryRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftHistoryRepository();

  @override
  Future<void> addHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int position,
    int duration,
  ) async {
    await database.into(database.listeningHistory).insert(
          ListeningHistoryCompanion.insert(
            audioUrl: audioUrl,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            position: position,
            duration: duration,
          ),
        );
  }

  @override
  Future<List<PodcastEpisode>> getHistory({int limit = 10}) async {
    final history =
        await (database.select(database.listeningHistory)..limit(limit)).get();

    return history.map((e) {
      return PodcastEpisode(
        title: e.title,
        description: e.description,
        audioUrl: e.audioUrl,
        //TODO: fix duration type
        duration: e.duration.toString(),
        guid: e.audioUrl,
        publicationDate: null,
        imageUrl: e.imageUrl,
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
  Future<void> removeHistory(String audioUrl) async {
    await (database.delete(database.listeningHistory)
          ..where((tbl) => tbl.audioUrl.equals(audioUrl)))
        .go();
  }
}
