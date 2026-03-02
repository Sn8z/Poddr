import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('PodcastSubscriptionData')
@TableIndex(name: 'idx_podcast_subscription_rss', columns: {#rss})
class PodcastSubscription extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rss => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get author => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ListeningHistoryData')
@TableIndex(name: 'idx_history_audio_url', columns: {#audioUrl})
@TableIndex(name: 'idx_history_listened_at', columns: {#listenedAt})
class ListeningHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get audioUrl => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text()();
  TextColumn get podcastTitle => text()();
  TextColumn get podcastRSS => text()();
  IntColumn get position => integer()();
  IntColumn get duration => integer()();
  BoolColumn get isFinished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get listenedAt => dateTime().withDefault(currentDateAndTime)();
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
}

@DriftDatabase(tables: [PodcastSubscription, ListeningHistory, OfflineEpisodes])
class PoddrDatabase extends _$PoddrDatabase {
  static PoddrDatabase? _instance;

  PoddrDatabase._internal() : super(_openConnection());

  factory PoddrDatabase() {
    return _instance ??= PoddrDatabase._internal();
  }

  @override
  int get schemaVersion => 1;
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
