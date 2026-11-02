import 'package:drift/drift.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/core/log.dart';

class DriftSubscriptionRepository implements ISubscriptionRepository {
  static const String logName = "DriftSubscriptionRepository";
  final PoddrDatabase database = PoddrDatabase();

  DriftSubscriptionRepository();

  @override
  Future<int> addSubscription(
    String? title,
    String? rss,
    String? description,
    String? author,
    String? image,
  ) async {
    info("Adding subscription: $rss", name: logName);
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
    info("Removing subscription: $rss", name: logName);
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
    debug("Updating subscription: $rss", name: logName);
    await (database.update(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .write(PodcastSubscriptionCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      author: author != null ? Value(author) : const Value.absent(),
      imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
      rss: newRss != null ? Value(newRss) : const Value.absent(),
      broken: const Value(false),
    ));
  }

  @override
  Future<void> markAsBroken(String rss, {bool broken = true}) async {
    info("Marking $rss as broken=$broken", name: logName);
    await (database.update(database.podcastSubscription)
          ..where((sub) => sub.rss.equals(rss)))
        .write(PodcastSubscriptionCompanion(
      broken: Value(broken),
    ));
  }

  @override
  Stream<List<Podcast>> watchAllSubscriptions() {
    debug("Watching all subscriptions", name: logName);
    return database
        .select(database.podcastSubscription)
        .watch()
        .map((subs) => subs
            .map((sub) => Podcast(
                  title: sub.title,
                  rss: sub.rss,
                  description: sub.description,
                  author: sub.author,
                  image: sub.imageUrl,
                  broken: sub.broken,
                ))
            .toList());
  }
}
