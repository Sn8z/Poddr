import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/sync/sync_repository.dart';

class DriftSyncRepository implements ISyncRepository {
  final PoddrDatabase _db = PoddrDatabase();

  @override
  Future<void> addPendingEpisodeAction({
    required String podcastRss,
    required String episodeUrl,
    required String action,
    int position = 0,
    DateTime? timestamp,
  }) async {
    await _db.into(_db.pendingEpisodeActions).insert(
          PendingEpisodeActionsCompanion.insert(
            podcastRss: podcastRss,
            episodeUrl: episodeUrl,
            action: action,
            position: Value(position),
            timestamp: timestamp ?? DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingEpisodeActions() async {
    final results = await (_db.select(_db.pendingEpisodeActions)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .get();

    return results
        .map((row) => {
              'id': row.id,
              'podcast': row.podcastRss,
              'episode': row.episodeUrl,
              'action': row.action,
              'position': row.position,
              'timestamp': row.timestamp.millisecondsSinceEpoch ~/ 1000,
            })
        .toList();
  }

  @override
  Future<void> deletePendingEpisodeActions(List<int> ids) async {
    if (ids.isEmpty) return;

    await (_db.delete(_db.pendingEpisodeActions)
          ..where((tbl) => tbl.id.isIn(ids)))
        .go();
  }

  @override
  Future<void> clearPendingEpisodeActions() async {
    await _db.delete(_db.pendingEpisodeActions).go();
  }

  @override
  Future<void> addPendingSubscriptionAction(String rss, String action) async {
    await _db.into(_db.pendingSubscriptionActions).insert(
          PendingSubscriptionActionsCompanion.insert(
            rss: rss,
            action: action,
            timestamp: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSubscriptionActions() async {
    final results = await (_db.select(_db.pendingSubscriptionActions)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .get();

    return results
        .map((row) => {
              'rss': row.rss,
              'action': row.action,
              'timestamp': row.timestamp.millisecondsSinceEpoch ~/ 1000,
            })
        .toList();
  }

  @override
  Future<void> deletePendingSubscriptionActions(List<int> ids) async {
    if (ids.isEmpty) return;

    await (_db.delete(_db.pendingSubscriptionActions)
          ..where((tbl) => tbl.id.isIn(ids)))
        .go();
  }

  @override
  Future<void> clearPendingSubscriptionActions() async {
    await _db.delete(_db.pendingSubscriptionActions).go();
  }
}
