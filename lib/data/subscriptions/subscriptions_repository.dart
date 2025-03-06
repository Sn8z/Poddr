import 'package:poddr/models/podcast.dart';

abstract class ISubscriptionRepository {
  Future<List<Podcast>> getSubscriptions();
  Future<void> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  );
  Future<void> removeSubscription(String rss);
}
