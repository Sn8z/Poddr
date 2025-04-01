import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
part 'database.g.dart';

class PodcastSubscription extends Table {
  TextColumn get rss => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get author => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {rss};
}

class ListeningHistory extends Table {
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

  @override
  Set<Column<Object>> get primaryKey => {audioUrl};
}

@DriftDatabase(tables: [PodcastSubscription, ListeningHistory])
class PoddrDatabase extends _$PoddrDatabase {
  static PoddrDatabase? _instance;

  PoddrDatabase._internal() : super(_openConnection());

  factory PoddrDatabase() {
    return _instance ??= PoddrDatabase._internal();
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'poddr_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}
