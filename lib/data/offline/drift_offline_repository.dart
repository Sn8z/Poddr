import 'dart:io';
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:poddr/data/db/drift/database.dart' as drift;
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/models/offline_episode.dart';

class DriftOfflineRepository implements IOfflineRepository {
  final drift.PoddrDatabase database = drift.PoddrDatabase();

  DriftOfflineRepository();

  String _getFileName(String audioUrl) {
    final cleanUrl = audioUrl.split('?').first;
    final extension = cleanUrl.split('.').lastOrNull ?? 'mp3';
    final hash = sha256.convert(utf8.encode(audioUrl)).toString().substring(0, 16);
    return '$hash.$extension';
  }

  Future<String> _getDownloadDir() async {
    final appDir = await getApplicationSupportDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  @override
  Future<String> getLocalPathForDownload(String audioUrl) async {
    final downloadDir = await _getDownloadDir();
    final fileName = _getFileName(audioUrl);
    return '$downloadDir/$fileName';
  }

  OfflineEpisode _mapToDomain(drift.OfflineEpisode drift) {
    return OfflineEpisode(
      id: drift.id,
      audioUrl: drift.audioUrl,
      localPath: drift.localPath,
      title: drift.title,
      description: drift.description,
      imageUrl: drift.imageUrl,
      podcastTitle: drift.podcastTitle,
      podcastRSS: drift.podcastRSS,
      duration: drift.duration,
      fileSize: drift.fileSize,
      downloadedAt: drift.downloadedAt,
      publicationDate: drift.publicationDate,
      videoUrl: drift.videoUrl,
      videoLocalPath: drift.videoLocalPath,
      videoFileSize: drift.videoFileSize,
    );
  }

  @override
  Future<List<OfflineEpisode>> getAll() async {
    final results = await (database.select(database.offlineEpisodes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.downloadedAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .get();
    return results.map(_mapToDomain).toList();
  }

  @override
  Future<OfflineEpisode?> getByAudioUrl(String audioUrl) async {
    final result = await (database.select(database.offlineEpisodes)
          ..where((t) => t.audioUrl.equals(audioUrl)))
        .getSingleOrNull();
    return result != null ? _mapToDomain(result) : null;
  }

  @override
  Future<void> addEpisode({
    required String audioUrl,
    required String localPath,
    required String title,
    required String description,
    required String imageUrl,
    required String podcastTitle,
    required String podcastRSS,
    required int duration,
    required int fileSize,
    DateTime? publicationDate,
    // Video support
    String? videoUrl,
    String? videoLocalPath,
    int? videoFileSize,
  }) async {
    await database.into(database.offlineEpisodes).insert(
          drift.OfflineEpisodesCompanion.insert(
            audioUrl: audioUrl,
            localPath: localPath,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            duration: duration,
            fileSize: fileSize,
            publicationDate: Value(publicationDate),
            videoUrl: Value(videoUrl),
            videoLocalPath: Value(videoLocalPath),
            videoFileSize: Value(videoFileSize),
          ),
        );
  }

  @override
  Future<void> remove(String audioUrl) async {
    final episode = await getByAudioUrl(audioUrl);
    if (episode != null) {
      final audioFile = File(episode.localPath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      // Delete video file if exists
      if (episode.videoLocalPath != null) {
        final videoFile = File(episode.videoLocalPath!);
        if (await videoFile.exists()) {
          await videoFile.delete();
        }
      }
    }
    await (database.delete(database.offlineEpisodes)
        ..where((t) => t.audioUrl.equals(audioUrl)))
        .go();
  }

  @override
  Future<String?> getLocalPath(String audioUrl) async {
    final episode = await getByAudioUrl(audioUrl);
    if (episode == null) return null;
    final file = File(episode.localPath);
    if (await file.exists()) {
      return episode.localPath;
    }
    return null;
  }

  @override
  Future<String?> getVideoLocalPath(String audioUrl) async {
    final episode = await getByAudioUrl(audioUrl);
    if (episode == null || episode.videoLocalPath == null) return null;
    final file = File(episode.videoLocalPath!);
    if (await file.exists()) {
      return episode.videoLocalPath;
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    await database.delete(database.offlineEpisodes).go();
  }

  @override
  Stream<List<OfflineEpisode>> watchAll() {
    return (database.select(database.offlineEpisodes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.downloadedAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .watch()
        .map((list) => list.map(_mapToDomain).toList());
  }
}
