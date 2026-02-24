import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/offline/offline_repository.dart';

class DriftOfflineRepository implements IOfflineRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftOfflineRepository();

  @override
  Future<List<OfflineEpisode>> getAll() async {
    return await (database.select(database.offlineEpisodes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.downloadedAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .get();
  }

  @override
  Future<OfflineEpisode?> getByAudioUrl(String audioUrl) async {
    return await (database.select(database.offlineEpisodes)
          ..where((t) => t.audioUrl.equals(audioUrl)))
        .getSingleOrNull();
  }

  @override
  Future<void> add(OfflineEpisodesCompanion episode) async {
    await database.into(database.offlineEpisodes).insert(
          episode,
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> remove(String audioUrl) async {
    await (database.delete(database.offlineEpisodes)
          ..where((t) => t.audioUrl.equals(audioUrl)))
        .go();
  }

  @override
  Future<void> updateFileSize(String audioUrl, int fileSize) async {
    await (database.update(database.offlineEpisodes)
          ..where((t) => t.audioUrl.equals(audioUrl)))
        .write(
      OfflineEpisodesCompanion(
        fileSize: Value(fileSize),
      ),
    );
  }

  @override
  Stream<List<OfflineEpisode>> watchAll() {
    return (database.select(database.offlineEpisodes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.downloadedAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .watch();
  }
}
