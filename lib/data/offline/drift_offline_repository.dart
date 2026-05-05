import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:poddr/data/db/drift/database.dart' as drift;
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/core/poddr_http_client.dart';
import 'package:poddr/core/exceptions.dart';

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

  static const Map<String, String> _videoExtensions = {
    'video/mp4': 'mp4',
    'video/webm': 'webm',
    'video/quicktime': 'mov',
    'video/x-m4v': 'mp4',
    'video/ogg': 'ogv',
    'video avi': 'avi',
    'video/mpeg': 'mpg',
    'video/x-msvideo': 'avi',
  };

  String _getVideoExtension(String videoUrl) {
    final uri = Uri.parse(videoUrl);
    final path = uri.path.toLowerCase();
    for (final entry in _videoExtensions.entries) {
      if (path.endsWith('.${entry.value}')) {
        return entry.value;
      }
    }
    final ext = path.split('.').lastOrNull;
    if (ext != null && _videoExtensions.values.contains(ext)) {
      return ext;
    }
    return 'mp4';
  }

  @override
  Future<void> downloadEpisode(
    PodcastEpisode episode, {
    required Function(double) onProgress,
    required Function() onCancel,
    required PoddrHttpClient client,
  }) async {
    String? localPath;
    String? videoLocalPath;
    File? audioFile;
    File? videoFile;
    int downloadedBytes = 0;
    int totalBytes = 0;
    int audioSize = 0;

    try {
      localPath = await getLocalPathForDownload(episode.audioUrl);
      audioFile = File(localPath);

      final response = await client.send(
        http.Request('GET', Uri.parse(episode.audioUrl)),
      );

      if (response.statusCode != 200) {
        throw DownloadFailedException(
          response.statusCode,
          'Failed to download: ${response.statusCode}',
        );
      }

      audioSize = response.contentLength ?? 0;
      totalBytes = audioSize;

      int? videoSize;
      if (episode.hasVideo && episode.videoUrl != null) {
        try {
          final videoHead = await client.head(Uri.parse(episode.videoUrl!));
          videoSize = int.tryParse(videoHead.headers['content-length'] ?? '0');
          if (videoSize != null && videoSize > 0) {
            totalBytes += videoSize;
          }
        } catch (e) {
          log('Failed to get video size: $e', name: 'DriftOfflineRepository');
        }
      }

      int lastLoggedPercent = 0;
      final audioSink = audioFile.openWrite();

      try {
        await for (final chunk in response.stream) {
          audioSink.add(chunk);
          downloadedBytes += chunk.length;

          if (totalBytes > 0) {
            final progress = downloadedBytes / totalBytes;
            onProgress(progress);
            final percent = (progress * 100).round();
            if (percent >= lastLoggedPercent + 25 && percent <= 100) {
              log('Download progress: ${episode.title} - $percent%',
                  name: 'DriftOfflineRepository');
              lastLoggedPercent = percent;
            }
          }
        }

        await audioSink.flush();
        await audioSink.close();
      } catch (e) {
        await audioSink.close();
        rethrow;
      }

      final savedFile = File(localPath);
      if (!await savedFile.exists() ||
          await savedFile.length() != downloadedBytes) {
        throw DownloadException('Downloaded file validation failed');
      }

      if (episode.hasVideo && episode.videoUrl != null) {
        log('Starting video download for: ${episode.title}',
            name: 'DriftOfflineRepository');

        videoLocalPath =
            await getLocalPathForDownload(episode.videoUrl!);
        final videoExtension = _getVideoExtension(episode.videoUrl!);
        videoLocalPath =
            videoLocalPath.replaceAll(RegExp(r'\.[^.]+$'), '.$videoExtension');
        videoFile = File(videoLocalPath);

        final videoResponse = await client.send(
          http.Request('GET', Uri.parse(episode.videoUrl!)),
        );

        if (videoResponse.statusCode != 200) {
          throw DownloadFailedException(
            videoResponse.statusCode,
            'Failed to download video: ${videoResponse.statusCode}',
          );
        }

        final videoSink = videoFile.openWrite();
        try {
          await for (final chunk in videoResponse.stream) {
            videoSink.add(chunk);
            downloadedBytes += chunk.length;

            if (totalBytes > 0) {
              final progress = downloadedBytes / totalBytes;
              onProgress(progress);
              final percent = (progress * 100).round();
              if (percent >= lastLoggedPercent + 25 &&
                  percent <= 100) {
                log('Download progress (video): ${episode.title} - $percent%',
                    name: 'DriftOfflineRepository');
                lastLoggedPercent = percent;
              }
            }
          }

          await videoSink.flush();
          await videoSink.close();
        } catch (e) {
          await videoSink.close();
          rethrow;
        }

        log('Video download completed: ${episode.title}',
            name: 'DriftOfflineRepository');
      }

      await addEpisode(
        audioUrl: episode.audioUrl,
        localPath: localPath,
        title: episode.title ?? '',
        description: episode.description ?? '',
        imageUrl: episode.imageUrl ?? '',
        podcastTitle: episode.podcastTitle ?? '',
        podcastRSS: episode.podcastRSS ?? '',
        duration: episode.duration?.inSeconds ?? 0,
        fileSize: downloadedBytes,
        publicationDate: episode.publicationDate,
        videoUrl: episode.videoUrl,
        videoLocalPath: videoLocalPath,
        videoFileSize: videoLocalPath != null
            ? downloadedBytes - audioSize
            : null,
      );
    } catch (e) {
      if (e is DownloadCancelledException) {
        log('Download cancelled: ${episode.title}',
            name: 'DriftOfflineRepository');
      } else {
        log('Download failed: $e', name: 'DriftOfflineRepository');
        if (localPath != null) {
          final file = File(localPath);
          if (await file.exists()) await file.delete();
          if (videoLocalPath != null) {
            final videoFile = File(videoLocalPath);
            if (await videoFile.exists()) await videoFile.delete();
          }
          await remove(episode.audioUrl);
        }
        rethrow;
      }
    } finally {
      // Client lifecycle managed by OfflineProvider
    }
  }
}
