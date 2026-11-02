import 'package:poddr/models/collection.dart';

abstract class ICollectionsRepository {
  Future<PodcastCollection> createCollection(String name, {int? color});

  Future<void> updateCollectionName(int id, String name);

  Future<void> updateCollectionColor(int id, int color);

  Future<void> deleteCollection(int id);

  Future<void> linkCollectionToSubscription(int collectionId, String rss);

  Future<void> unlinkCollectionFromSubscription(int collectionId, String rss);

  Stream<List<PodcastCollection>> watchAllCollections();

  Stream<List<PodcastCollection>> watchCollectionsForRss(String rss);

  Stream<Set<String>> watchRssInCollections(Set<int> collectionIds);
}
