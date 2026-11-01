import 'package:poddr/models/podcast.dart';

abstract class ISubscriptionRepository {
  Future<int> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  );

  Future<int?> getSubscriptionIdByRss(String rss);

  Future<Map<String, int>> getAllSubscriptionIds();

  Stream<List<Podcast>> watchAllSubscriptions();

  Future<void> removeSubscription(String rss);

  Future<void> updateSubscription({
    required String rss,
    String? title,
    String? description,
    String? author,
    String? imageUrl,
    String? newRss,
  });

  Future<void> markAsBroken(String rss, {bool broken = true});
}
