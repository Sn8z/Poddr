import 'package:poddr/models/collection.dart';
import 'package:poddr/models/podcast.dart';

abstract class ICollectionsRepository {
  Future<PodcastCollection> createCollection(String name, {int? color});

  Future<List<PodcastCollection>> getAllCollections();

  Future<List<PodcastCollection>> getCollectionsForSubscription(
      int subscriptionId);

  Future<void> updateCollectionName(int id, String name);

  Future<void> updateCollectionColor(int id, int color);

  Future<void> deleteCollection(int id);

  Future<void> linkCollectionToSubscription(
      int collectionId, int subscriptionId);

  Future<void> unlinkCollectionFromSubscription(
      int collectionId, int subscriptionId);

  Stream<List<PodcastCollection>> watchAllCollections();

  Stream<List<PodcastCollection>> watchCollectionsForSubscription(
      int subscriptionId);

  Stream<List<Podcast>> watchSubscriptionsForCollection(int collectionId);
 
  Future<Map<int, Set<int>>> getAllSubscriptionCollectionPairs();

  Stream<Map<int, Set<int>>> watchAllSubscriptionCollectionPairs();
}
