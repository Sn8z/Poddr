import 'package:poddr/data/db/drift/database.dart';

abstract class IOfflineRepository {
  Future<List<OfflineEpisode>> getAll();

  Future<OfflineEpisode?> getByAudioUrl(String audioUrl);

  Future<void> add(OfflineEpisodesCompanion episode);

  Future<void> remove(String audioUrl);

  Future<void> updateFileSize(String audioUrl, int fileSize);

  Stream<List<OfflineEpisode>> watchAll();
}
