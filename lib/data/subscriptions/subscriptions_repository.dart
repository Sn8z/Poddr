import 'package:poddr/models/podcast.dart';

abstract class ISubscriptionRepository {
  Future<List<Podcast>> getSubscriptions();

  Future<int> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  );

  Future<int?> getSubscriptionIdByRss(String rss);

  Stream<int?> watchSubscriptionIdByRss(String rss);

  Future<void> removeSubscription(String rss);
}
