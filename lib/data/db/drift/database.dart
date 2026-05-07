import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poddr/data/migration/electron_migration.dart';
import 'package:poddr/core/log.dart';

part 'database.g.dart';

class PodcastSubscription extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rss => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get author => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get broken => boolean().withDefault(const Constant(false))();
}

class ListeningHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get audioUrl => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text()();
  TextColumn get podcastTitle => text()();
  TextColumn get podcastRSS => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer()();
  BoolColumn get isFinished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get listenedAt => dateTime().withDefault(currentDateAndTime)();

  // Video support
  TextColumn get videoUrl => text().nullable()();
}

class OfflineEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get audioUrl => text().unique()();
  TextColumn get localPath => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text()();
  TextColumn get podcastTitle => text()();
  TextColumn get podcastRSS => text()();
  IntColumn get duration => integer()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get publicationDate => dateTime().nullable()();

  // Video support
  TextColumn get videoUrl => text().nullable()();
  TextColumn get videoLocalPath => text().nullable()();
  IntColumn get videoFileSize => integer().nullable()();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer()();
}

class SubscriptionCollections extends Table {
  IntColumn get subscriptionId => integer()
      .references(PodcastSubscription, #id, onDelete: KeyAction.cascade)();
  IntColumn get collectionId =>
      integer().references(Collections, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {subscriptionId, collectionId};
}

class PendingEpisodeActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get podcastRss => text()();
  TextColumn get episodeUrl => text()();
  TextColumn get action => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get timestamp => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {episodeUrl, action},
      ];
}

class PendingSubscriptionActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rss => text().unique()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [
  PodcastSubscription,
  ListeningHistory,
  OfflineEpisodes,
  Collections,
  SubscriptionCollections,
  PendingEpisodeActions,
  PendingSubscriptionActions
])
class PoddrDatabase extends _$PoddrDatabase {
  static PoddrDatabase? _instance;

  PoddrDatabase._internal() : super(_openConnection());

  factory PoddrDatabase() {
    return _instance ??= PoddrDatabase._internal();
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        try {
          await ElectronMigration.migrateSubscriptions(
            (rss, title, imageUrl, subscribedAt) async {
              await into(podcastSubscription).insert(
                PodcastSubscriptionCompanion.insert(
                  rss: rss,
                  title: title,
                  description: '',
                  author: '',
                  imageUrl: imageUrl,
                  subscribedAt: Value(subscribedAt),
                ),
              );
            },
          );
        } catch (e, stackTrace) {
          error('Failed to migrate subscriptions: $e',
              name: 'PoddrDatabase', error: e, stackTrace: stackTrace);
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {},
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'poddr_db',
    native: DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
