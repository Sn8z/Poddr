import 'package:poddr/data/subscriptions/drift/database.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/models/podcast.dart';

class DriftSubscriptionRepository implements ISubscriptionRepository {
  final Database database = Database();
  DriftSubscriptionRepository();

  @override
  Future<List<Podcast>> getSubscriptions() async {
    final subscriptions =
        await database.select(database.podcastSubscriptions).get();

    return subscriptions.map((sub) {
      return Podcast(
        title: sub.title,
        rss: sub.rss,
        description: sub.description,
        author: sub.author,
        image: sub.image,
      );
    }).toList();
  }

  @override
  Future<void> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  ) async {
    await database.into(database.podcastSubscriptions).insert(
          PodcastSubscriptionsCompanion.insert(
            title: title ?? '',
            rss: rss ?? '',
            description: description ?? '',
            author: author ?? '',
            image: image ?? '',
          ),
        );
  }

  @override
  Future<void> removeSubscription(String rss) async {
    await (database.delete(database.podcastSubscriptions)
          ..where((sub) => sub.rss.equals(rss)))
        .go();
  }
}
