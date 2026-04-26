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
}
