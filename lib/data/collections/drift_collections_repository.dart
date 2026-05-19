import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/collections/collections_repository.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/utils/colors.dart';

class DriftCollectionsRepository implements ICollectionsRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftCollectionsRepository();

  @override
  Future<PodcastCollection> createCollection(String name, {int? color}) async {
    final trimmedName = name.trim();
    final collectionColor = color ?? generateRandomColorInt();

    final newCollectionId = await database.into(database.collections).insert(
          CollectionsCompanion.insert(
            name: trimmedName,
            color: collectionColor,
          ),
        );

    final newCollection = await (database.select(database.collections)
          ..where((c) => c.id.equals(newCollectionId)))
        .getSingle();

    return PodcastCollection(
      id: newCollection.id,
      name: newCollection.name,
      color: newCollection.color,
    );
  }

  @override
  Future<List<PodcastCollection>> getAllCollections() async {
    final allCollections = await database.select(database.collections).get();
    return allCollections
        .map((c) => PodcastCollection(id: c.id, name: c.name, color: c.color))
        .toList();
  }

  @override
  Future<List<PodcastCollection>> getCollectionsForSubscription(
      int subscriptionId) async {
    final query = database.select(database.collections).join([
      innerJoin(
        database.subscriptionCollections,
        database.subscriptionCollections.collectionId
            .equalsExp(database.collections.id),
      ),
    ])
      ..where(database.subscriptionCollections.subscriptionId
          .equals(subscriptionId));

    final results = await query.get();
    return results.map((row) {
      final collection = row.readTable(database.collections);
      return PodcastCollection(
          id: collection.id, name: collection.name, color: collection.color);
    }).toList();
  }

  @override
  Future<void> updateCollectionColor(int id, int color) async {
    await (database.update(database.collections)..where((c) => c.id.equals(id)))
        .write(CollectionsCompanion(color: Value(color)));
  }

  @override
  Future<void> updateCollectionName(int id, String name) async {
    await (database.update(database.collections)..where((c) => c.id.equals(id)))
        .write(CollectionsCompanion(name: Value(name.trim())));
  }

  @override
  Future<void> deleteCollection(int id) async {
    await (database.delete(database.subscriptionCollections)
          ..where((sc) => sc.collectionId.equals(id)))
        .go();
    await (database.delete(database.collections)..where((c) => c.id.equals(id)))
        .go();
  }

  @override
  Future<void> linkCollectionToSubscription(
      int collectionId, int subscriptionId) async {
    await database.into(database.subscriptionCollections).insert(
          SubscriptionCollectionsCompanion.insert(
            subscriptionId: subscriptionId,
            collectionId: collectionId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> unlinkCollectionFromSubscription(
      int collectionId, int subscriptionId) async {
    await (database.delete(database.subscriptionCollections)
          ..where((sc) =>
              sc.collectionId.equals(collectionId) &
              sc.subscriptionId.equals(subscriptionId)))
        .go();
  }

  @override
  Future<Map<int, Set<int>>> getAllSubscriptionCollectionPairs() async {
    final rows =
        await database.select(database.subscriptionCollections).get();
    return _rowsToMap(rows);
  }
 
  @override
  Stream<Map<int, Set<int>>> watchAllSubscriptionCollectionPairs() {
    return database.select(database.subscriptionCollections)
        .watch()
        .map(_rowsToMap);
  }
 
  Map<int, Set<int>> _rowsToMap(List<SubscriptionCollection> rows) {
    final map = <int, Set<int>>{};
    for (var row in rows) {
      map.putIfAbsent(row.subscriptionId, () => {}).add(row.collectionId);
    }
    return map;
  }
 
  @override
  Stream<List<PodcastCollection>> watchAllCollections() {
    return database.select(database.collections).watch().map(
          (collections) => collections
              .map((c) =>
                  PodcastCollection(id: c.id, name: c.name, color: c.color))
              .toList(),
        );
  }

  @override
  Stream<List<PodcastCollection>> watchCollectionsForSubscription(
      int subscriptionId) {
    final query = database.select(database.collections).join([
      innerJoin(
        database.subscriptionCollections,
        database.subscriptionCollections.collectionId
            .equalsExp(database.collections.id),
      ),
    ])
      ..where(database.subscriptionCollections.subscriptionId
          .equals(subscriptionId));

    return query.watch().map(
          (rows) => rows.map((row) {
            final collection = row.readTable(database.collections);
            return PodcastCollection(
                id: collection.id,
                name: collection.name,
                color: collection.color);
          }).toList(),
        );
  }

  @override
  Stream<List<Podcast>> watchSubscriptionsForCollection(int collectionId) {
    final query = database.select(database.podcastSubscription).join([
      innerJoin(
        database.subscriptionCollections,
        database.subscriptionCollections.subscriptionId
            .equalsExp(database.podcastSubscription.id),
      ),
    ])
      ..where(database.subscriptionCollections.collectionId
          .equals(collectionId));

    return query.watch().map((rows) => rows.map((row) {
          final sub = row.readTable(database.podcastSubscription);
          return Podcast(
            title: sub.title,
            rss: sub.rss,
            description: sub.description,
            author: sub.author,
            image: sub.imageUrl,
          );
        }).toList());
  }
}
