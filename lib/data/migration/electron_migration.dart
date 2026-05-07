import 'package:poddr/core/log.dart';
import 'dart:io';
import 'dart:convert';

typedef SubscriptionInsert = Future<void> Function(
  String rss,
  String title,
  String imageUrl,
  DateTime subscribedAt,
);

class ElectronMigration {
  static const String logName = "ElectronMigration";

  static Future<void> migrateSubscriptions(SubscriptionInsert insert) async {
    final favourites = await _readFavourites();
    if (favourites.isEmpty) return;

    for (final entry in favourites.entries) {
      final rss = entry.key.replaceAll(r'\.', '.');
      final data = entry.value as Map<String, dynamic>;

      final dateAdded = data['dateAdded'];
      final subscribedAt = (dateAdded != null && dateAdded > 0)
          ? DateTime.fromMillisecondsSinceEpoch(dateAdded)
          : DateTime.now();

      try {
        await insert(
          rss,
          data['title'] ?? '',
          data['img'] ?? '',
          subscribedAt,
        );
      } catch (e, stackTrace) {
        error('Failed to migrate subscription for $rss: $e',
            name: logName, error: e, stackTrace: stackTrace);
      }
    }
  }

  static Future<Map<String, dynamic>> _readFavourites() async {
    final dir = await _electronDir();
    if (dir == null) return {};

    final file = File('${dir.path}${Platform.pathSeparator}favourites.json');
    if (!await file.exists()) return {};

    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e, stackTrace) {
      error('Failed to read favourites: $e',
          name: logName, error: e, stackTrace: stackTrace);
    }
    return {};
  }

  static Future<Directory?> _electronDir() async {
    late final String path;

    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData == null) return null;
      path = '$appData${Platform.pathSeparator}poddr';
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home == null) return null;
      path =
          '$home${Platform.pathSeparator}Library${Platform.pathSeparator}Application Support${Platform.pathSeparator}poddr';
    } else {
      final home = Platform.environment['HOME'];
      if (home == null) return null;
      final xdgConfig = Platform.environment['XDG_CONFIG_HOME'];
      if (xdgConfig != null) {
        path = '$xdgConfig${Platform.pathSeparator}poddr';
      } else {
        path =
            '$home${Platform.pathSeparator}.config${Platform.pathSeparator}poddr';
      }
    }

    final dir = Directory(path);
    return await dir.exists() ? dir : null;
  }
}
