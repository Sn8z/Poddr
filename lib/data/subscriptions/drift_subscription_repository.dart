import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/models/podcast.dart';

class DriftSubscriptionRepository implements ISubscriptionRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftSubscriptionRepository();

  @override
  Future<List<Podcast>> getSubscriptions() async {
    final subscriptions =
        await database.select(database.podcastSubscription).get();

    return subscriptions.map((sub) {
      return Podcast(
        title: sub.title,
        rss: sub.rss,
        description: sub.description,
        author: sub.author,
        image: sub.imageUrl,
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
    await database.into(database.podcastSubscription).insert(
          PodcastSubscriptionCompanion.insert(
            title: title ?? '',
            rss: rss ?? '',
            description: description ?? '',
            author: author ?? '',
            imageUrl: image ?? '',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> removeSubscription(String rss) async {
    await (database.delete(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .go();
  }
}
