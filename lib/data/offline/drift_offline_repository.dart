import 'dart:io';
import 'dart:async';
import 'package:drift/drift.dart';
import 'package:poddr/core/log.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:poddr/data/db/drift/database.dart' as drift;
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';

class DriftOfflineRepository implements IOfflineRepository {
  static const String logName = "DriftOfflineRepository";
  final drift.PoddrDatabase database = drift.PoddrDatabase();

  DriftOfflineRepository();

  static const Map<String, String> _mimeToExtension = {
    'audio/mpeg': 'mp3',
    'audio/mp3': 'mp3',
    'audio/mp4': 'm4a',
    'audio/x-m4a': 'm4a',
    'audio/ogg': 'ogg',
    'audio/opus': 'opus',
    'audio/wav': 'wav',
    'audio/x-wav': 'wav',
    'audio/aac': 'aac',
    'audio/aacp': 'aac',
    'audio/webm': 'webm',
    'audio/flac': 'flac',
    'audio/3gpp': '3gp',
    'video/mp4': 'mp4',
    'video/webm': 'webm',
    'video/quicktime': 'mov',
    'video/x-m4v': 'mp4',
    'video/ogg': 'ogv',
    'video/mpeg': 'mpg',
    'video/x-msvideo': 'avi',
    'video/avi': 'avi',
  };

  static final RegExp _safeExtension = RegExp(r'^[a-z0-9]{2,5}$');
  static const int maxDownloadBytes = 10 * 1024 * 1024 * 1024;

  static String? _extensionFromUrl(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      final segment = path.split('/').lastOrNull;
      if (segment == null || !segment.contains('.')) return null;
      final ext = segment.split('.').lastOrNull;
      if (ext == null || !_safeExtension.hasMatch(ext)) return null;
      return ext;
    } catch (_) {
      return null;
    }
  }

  static String _resolveExtension({
    required String url,
    String? contentType,
    required String fallback,
  }) {
    if (contentType != null) {
      final normalized = contentType.split(';').first.trim().toLowerCase();
      final mapped = _mimeToExtension[normalized];
      if (mapped != null) return mapped;
    }
    return _extensionFromUrl(url) ?? fallback;
  }

  String _getFileName(
    String url, {
    String? contentType,
    String fallback = 'mp3',
  }) {
    final extension = _resolveExtension(
      url: url,
      contentType: contentType,
      fallback: fallback,
    );
    return '${_hashFor(url)}.$extension';
  }

  static String _hashFor(String url) {
    return sha256.convert(utf8.encode(url)).toString().substring(0, 16);
  }

  static String _partFileName(String url) {
    return '${_hashFor(url)}.part';
  }

  final Map<String, String> _etags = {};

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
      await _discardPartialsForUrls(audioUrl, episode.videoUrl);
    }
    await (database.delete(database.offlineEpisodes)
        ..where((t) => t.audioUrl.equals(audioUrl)))
        .go();
  }

  @override
  Future<void> discardPartials(PodcastEpisode episode) async {
    await _discardPartialsForUrls(episode.audioUrl, episode.videoUrl);
  }

  Future<void> _discardPartialsForUrls(String audioUrl, String? videoUrl) async {
    final downloadDir = Directory(await _getDownloadDir());
    for (final url in [audioUrl, if (videoUrl != null) videoUrl]) {
      final part = File('${downloadDir.path}/${_partFileName(url)}');
      if (await part.exists()) await part.delete();
    }
  }

  @override
  Future<int> sweepDownloadDir() async {
    final downloadDir = Directory(await _getDownloadDir());
    if (!await downloadDir.exists()) return 0;
    final referenced = <String>{};
    for (final episode in await getAll()) {
      referenced.add(episode.localPath);
      if (episode.videoLocalPath != null) {
        referenced.add(episode.videoLocalPath!);
      }
    }
    var reclaimed = 0;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await for (final entity in downloadDir.list()) {
      if (entity is! File) continue;
      if (referenced.contains(entity.path)) continue;
      if (entity.path.endsWith('.part')) {
        final modified = (await entity.stat()).modified;
        if (modified.isAfter(cutoff)) continue;
      }
      try {
        await entity.delete();
        reclaimed++;
        debug('Swept ${entity.path}', name: logName);
      } catch (e) {
        debug('Sweep detail: $e', name: logName);
      }
    }
    return reclaimed;
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
  Stream<List<OfflineEpisode>> watchAllEpisodes() {
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

  static String? _normalizeContentType(String? header) {
    if (header == null) return null;
    final normalized = header.split(';').first.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  static int? _rangeTotal(String? contentRange) {
    if (contentRange == null) return null;
    final match = RegExp(r'/(\d+)\s*$').firstMatch(contentRange);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  Future<http.StreamedResponse?> _resumeResponse({
    required String url,
    required int existing,
    required PoddrHttpClient client,
  }) async {
    try {
      final head = await client.head(Uri.parse(url));
      if ((head.headers['accept-ranges'] ?? '').toLowerCase() != 'bytes') {
        return null;
      }
      final headEtag = head.headers['etag'];
      final recorded = _etags[url];
      if (recorded != null && headEtag != null && headEtag != recorded) {
        debug('Resume ETag mismatch for $url', name: logName);
        return null;
      }
      final headLength = int.tryParse(head.headers['content-length'] ?? '');
      if (headLength != null && headLength < existing) return null;
    } catch (e) {
      debug('Resume probe detail: $e', name: logName);
      return null;
    }

    final request = http.Request('GET', Uri.parse(url));
    request.headers['Range'] = 'bytes=$existing-';
    if (_etags[url] != null) request.headers['If-Range'] = _etags[url]!;
    final response = await client.send(request);
    if (response.statusCode == 206) {
      final total = _rangeTotal(response.headers['content-range']);
      if (total == null || total >= existing) return response;
      await response.stream.drain();
      return null;
    }
    if (response.statusCode != 200) {
      await response.stream.drain();
      return null;
    }
    return response;
  }

  Future<({String path, int fileSize})> _fetchMedia({
    required String url,
    required String fallbackExt,
    required String label,
    required String downloadDir,
    required PoddrHttpClient client,
    required bool Function() isCancelled,
    required void Function(int chunkLength) onChunk,
    required void Function(int resumedBytes) onResumed,
    required void Function(int totalSize) onTotalKnown,
  }) async {
    final partFile = File('$downloadDir/${_partFileName(url)}');
    final preExisting =
        await partFile.exists() ? await partFile.length() : 0;

    http.StreamedResponse? response;
    var resumeOffset = 0;
    if (preExisting > 0) {
      response = await _resumeResponse(
        url: url,
        existing: preExisting,
        client: client,
      );
      if (response == null) {
        if (await partFile.exists()) await partFile.delete();
      } else if (response.statusCode == 206) {
        resumeOffset = preExisting;
        onResumed(preExisting);
        final total = _rangeTotal(response.headers['content-range']);
        if (total != null) onTotalKnown(total);
      }
    }
    response ??= await client.send(http.Request('GET', Uri.parse(url)));

    if (response.statusCode != 200 && response.statusCode != 206) {
      await response.stream.drain();
      throw DownloadFailedException(
        response.statusCode,
        'Failed to download $label: ${response.statusCode}',
      );
    }

    final contentType = _normalizeContentType(response.headers['content-type']);
    if (contentType != null && contentType.startsWith('text/')) {
      error('Download rejected: unexpected content type', name: logName);
      debug('Rejected $label with content type: $contentType', name: logName);
      if (await partFile.exists()) await partFile.delete();
      throw DownloadFailedException(response.statusCode, 'Unexpected content');
    }

    final etag = response.headers['etag'];
    if (etag != null && etag.isNotEmpty) _etags[url] = etag;
    if (response.contentLength != null) {
      onTotalKnown(resumeOffset + response.contentLength!);
    }

    final sink = partFile.openWrite(
      mode: resumeOffset > 0 ? FileMode.append : FileMode.write,
    );
    var closed = false;
    Future<void> closeSink() async {
      if (!closed) {
        closed = true;
        await sink.close();
      }
    }

    var written = 0;
    try {
      await for (final chunk in response.stream) {
        if (isCancelled()) {
          await closeSink();
          throw DownloadCancelledException();
        }
        sink.add(chunk);
        written += chunk.length;
        if (resumeOffset + written > maxDownloadBytes) {
          await closeSink();
          if (await partFile.exists()) await partFile.delete();
          throw DownloadFailedException(null, 'Download too large');
        }
        onChunk(chunk.length);
      }
      await sink.flush();
      await closeSink();
    } catch (e) {
      await closeSink();
      if (e is FileSystemException &&
          (e.osError?.errorCode == 28 || e.osError?.errorCode == 112)) {
        error('Download failed: no space left on device', name: logName);
        throw DownloadFailedException(null, 'No space left on device');
      }
      rethrow;
    }

    final actual = await partFile.length();
    if (actual != resumeOffset + written) {
      throw DownloadException('Downloaded file validation failed');
    }

    final finalPath =
        '$downloadDir/${_getFileName(url, contentType: contentType, fallback: fallbackExt)}';
    await partFile.rename(finalPath);
    _etags.remove(url);
    return (path: finalPath, fileSize: actual);
  }

  @override
  Future<void> downloadEpisode(
    PodcastEpisode episode, {
    required Function(double) onProgress,
    required bool Function() isCancelled,
    required PoddrHttpClient client,
  }) async {
    String? localPath;
    String? videoLocalPath;
    int downloadedBytes = 0;
    int audioSize = 0;
    var audioTotal = 0;
    var videoTotal = 0;

    try {
      final downloadDir = await _getDownloadDir();
      final title = episode.title ?? '';
      var lastLoggedPercent = 0;

      void reportProgress(String label) {
        final total = audioTotal + videoTotal;
        if (total > 0) {
          final progress = (downloadedBytes / total).clamp(0.0, 1.0);
          onProgress(progress);
          final percent = (progress * 100).round();
          if (percent >= lastLoggedPercent + 25 && percent <= 100) {
            debug('Download progress: $label - $percent%', name: logName);
            lastLoggedPercent = percent;
          }
        }
      }

      void trackChunks(int length, String label) {
        downloadedBytes += length;
        reportProgress(label);
      }

      if (episode.hasVideo && episode.videoUrl != null) {
        try {
          final videoHead = await client.head(Uri.parse(episode.videoUrl!));
          videoTotal =
              int.tryParse(videoHead.headers['content-length'] ?? '') ?? 0;
        } catch (e) {
          error('Failed to get video size', name: logName);
          debug('Video size detail: $e', name: logName);
        }
      }

      final audio = await _fetchMedia(
        url: episode.audioUrl,
        fallbackExt: 'mp3',
        label: title,
        downloadDir: downloadDir,
        client: client,
        isCancelled: isCancelled,
        onChunk: (length) => trackChunks(length, title),
        onResumed: (bytes) => downloadedBytes += bytes,
        onTotalKnown: (total) => audioTotal = total,
      );
      localPath = audio.path;
      audioSize = audio.fileSize;

      if (episode.hasVideo && episode.videoUrl != null) {
        debug('Starting video download for: ${episode.title}',
            name: logName);

        final video = await _fetchMedia(
          url: episode.videoUrl!,
          fallbackExt: 'mp4',
          label: '$title (video)',
          downloadDir: downloadDir,
          client: client,
          isCancelled: isCancelled,
          onChunk: (length) => trackChunks(length, '$title (video)'),
          onResumed: (bytes) => downloadedBytes += bytes,
          onTotalKnown: (total) => videoTotal = total,
        );
        videoLocalPath = video.path;

        info('Video download completed: ${episode.title}',
            name: logName);
      }

      onProgress(1.0);

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
        info('Download cancelled: ${episode.title}',
            name: logName);
      } else {
        error('Download failed', name: logName);
        debug('Download detail: $e', name: logName);
        for (final path in [localPath, videoLocalPath]) {
          if (path != null) {
            final file = File(path);
            if (await file.exists()) await file.delete();
          }
        }
        rethrow;
      }
    } finally {
      // Client lifecycle managed by OfflineProvider
    }
  }
}
