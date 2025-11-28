import 'package:poddr/models/podcast.dart';

abstract class ISubscriptionRepository {
  Future<List<Podcast>> getSubscriptions(int profileId);
  Future<void> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
    int profileId,
  );
  Future<void> removeSubscription(int profileId, String rss);
}
