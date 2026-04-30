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
  Future<int> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  ) async {
    final id = await database.into(database.podcastSubscription).insert(
          PodcastSubscriptionCompanion.insert(
            title: title ?? '',
            rss: rss ?? '',
            description: description ?? '',
            author: author ?? '',
            imageUrl: image ?? '',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return id;
  }

  @override
  Future<void> removeSubscription(String rss) async {
    await (database.delete(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .go();
  }

  @override
  Future<void> updateSubscription({
    required String rss,
    String? title,
    String? description,
    String? author,
    String? imageUrl,
    String? newRss,
  }) async {
    await (database.update(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .write(PodcastSubscriptionCompanion(
          title: title != null ? Value(title) : const Value.absent(),
          description: description != null ? Value(description) : const Value.absent(),
          author: author != null ? Value(author) : const Value.absent(),
          imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
          rss: newRss != null ? Value(newRss) : const Value.absent(),
          broken: const Value(false),
        ));
  }

  @override
  Future<void> markAsBroken(String rss, {bool broken = true}) async {
    await (database.update(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .write(PodcastSubscriptionCompanion(
          broken: Value(broken),
        ));
  }

  @override
  Future<int?> getSubscriptionIdByRss(String rss) async {
    final result = await (database.select(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .getSingleOrNull();
    return result?.id;
  }

  @override
  Stream<int?> watchSubscriptionIdByRss(String rss) {
    return (database.select(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .watchSingleOrNull()
        .map((row) => row?.id);
  }
}
