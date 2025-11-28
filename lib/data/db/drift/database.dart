import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get shouldSync => boolean().withDefault(const Constant(false))();
}

class PodcastSubscription extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rss => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get author => text()();
  TextColumn get imageUrl => text()();
  IntColumn get profileId => integer().references(Profile, #id)();
  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

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
  IntColumn get profileId => integer().references(Profile, #id)();
}

@DriftDatabase(tables: [Profile, PodcastSubscription, ListeningHistory])
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
      onCreate: (migrator) async {
        await migrator.createAll();
        await into(profile).insert(
          ProfileCompanion.insert(name: "Default"),
        );
      },
      onUpgrade: (migrator, from, to) async {},
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
