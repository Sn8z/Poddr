import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/collections/collections_repository.dart';
import 'package:poddr/models/collection.dart';
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
      int collectionId, String rss) async {
    final subscriptionId = await _subscriptionIdForRss(rss);
    if (subscriptionId == null) return;

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
      int collectionId, String rss) async {
    final subscriptionId = await _subscriptionIdForRss(rss);
    if (subscriptionId == null) return;

    await (database.delete(database.subscriptionCollections)
          ..where((sc) =>
              sc.collectionId.equals(collectionId) &
              sc.subscriptionId.equals(subscriptionId)))
        .go();
  }

  Future<int?> _subscriptionIdForRss(String rss) async {
    final subscription = await (database.select(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .getSingleOrNull();
    return subscription?.id;
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
  Stream<List<PodcastCollection>> watchCollectionsForRss(String rss) {
    final query = database.select(database.collections).join([
      innerJoin(
        database.subscriptionCollections,
        database.subscriptionCollections.collectionId
            .equalsExp(database.collections.id),
      ),
      innerJoin(
        database.podcastSubscription,
        database.podcastSubscription.id
            .equalsExp(database.subscriptionCollections.subscriptionId),
      ),
    ])
      ..where(database.podcastSubscription.rss.equals(rss));

    return query.watch().map(
          (rows) => rows.map((row) {
            final collection = row.readTable(database.collections);
            return PodcastCollection(
              id: collection.id,
              name: collection.name,
              color: collection.color,
            );
          }).toList(),
        );
  }

  @override
  Stream<Set<String>> watchRssInCollections(Set<int> collectionIds) {
    if (collectionIds.isEmpty) return Stream.value(const <String>{});

    final query = database.select(database.podcastSubscription).join([
      innerJoin(
        database.subscriptionCollections,
        database.subscriptionCollections.subscriptionId
            .equalsExp(database.podcastSubscription.id),
      ),
    ])
      ..where(
          database.subscriptionCollections.collectionId.isIn(collectionIds));

    return query.watch().map(
          (rows) => {
            for (final row in rows)
              row.readTable(database.podcastSubscription).rss,
          },
        );
  }
}
