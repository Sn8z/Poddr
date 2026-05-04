import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';

class OfflineProvider extends ChangeNotifier {
  final String logName = "OfflineProvider";

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

  final IOfflineRepository _repository;

  List<OfflineEpisode> _downloads = [];
  List<OfflineEpisode> get downloads => _downloads;

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => _downloadProgress;

  final Set<String> _downloading = {};
  Set<String> get downloading => _downloading;

  final Set<String> _cancelling = {};
  final Map<String, http.Client> _activeClients = {};
  final List<PodcastEpisode> _downloadQueue = [];
  List<PodcastEpisode> get downloadQueue => _downloadQueue;

  final int _maxConcurrentDownloads = 3;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  OfflineProvider({IOfflineRepository? repository})
      : _repository = repository ?? DriftOfflineRepository() {
    _init();
  }

  Future<void> _init() async {
    await getDownloads();
  }

  int getQueuePosition(String audioUrl) {
    return _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl) + 1;
  }

  Future<void> getDownloads() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _downloads = await _repository.getAll();
    } catch (e, stackTrace) {
      log(
        'Failed to get downloads',
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isDownloaded(String audioUrl) async {
    final episode = await _repository.getByAudioUrl(audioUrl);
    return episode != null;
  }

  Future<String?> getLocalPath(String audioUrl) async {
    return await _repository.getLocalPath(audioUrl);
  }

  Future<String?> getVideoLocalPath(String audioUrl) async {
    return await _repository.getVideoLocalPath(audioUrl);
  }

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

  Future<void> download(PodcastEpisode episode) async {
    if (_downloading.contains(episode.audioUrl)) return;

    final queuedIndex =
        _downloadQueue.indexWhere((e) => e.audioUrl == episode.audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      notifyListeners();
    }

    if (_downloading.length >= _maxConcurrentDownloads) {
      if (!_downloadQueue.any((e) => e.audioUrl == episode.audioUrl)) {
        _downloadQueue.add(episode);
        log('Added to download queue: ${episode.title}', name: logName);
        notifyListeners();
      }
      return;
    }

    final existing = await _repository.getByAudioUrl(episode.audioUrl);
    if (existing != null) {
      final localFile = File(existing.localPath);
      if (await localFile.exists()) {
        log('Episode already downloaded: ${episode.title}', name: logName);
        return;
      }
      await _repository.remove(episode.audioUrl);
    }

    _downloading.add(episode.audioUrl);
    _downloadProgress[episode.audioUrl] = 0.0;
    notifyListeners();

    final client = http.Client();
    _activeClients[episode.audioUrl] = client;

    String? localPath;
    String? videoLocalPath;
    File? audioFile;
    File? videoFile;
    int downloadedBytes = 0;
    int totalBytes = 0;
    int audioSize = 0;

    try {
      localPath = await _repository.getLocalPathForDownload(episode.audioUrl);
      audioFile = File(localPath);

      log('Starting download for: ${episode.title}', name: logName);

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

      // If video available, get video size and add to total
      int? videoSize;
      if (episode.hasVideo && episode.videoUrl != null) {
        try {
          final videoHead =
              await client.head(Uri.parse(episode.videoUrl!));
          videoSize =
              int.tryParse(videoHead.headers['content-length'] ?? '0');
          if (videoSize != null && videoSize > 0) {
            totalBytes += videoSize;
          }
        } catch (e) {
          log('Failed to get video size: $e', name: logName);
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
            _downloadProgress[episode.audioUrl] = progress;
            final percent = (progress * 100).round();
            if (percent >= lastLoggedPercent + 25 && percent <= 100) {
              log('Download progress: ${episode.title} - $percent%',
                  name: logName);
              lastLoggedPercent = percent;
            }
            notifyListeners();
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

      // Download video if available
      if (episode.hasVideo && episode.videoUrl != null) {
        log('Starting video download for: ${episode.title}', name: logName);

        videoLocalPath =
            await _repository.getLocalPathForDownload(episode.videoUrl!);
        final videoExtension = _getVideoExtension(episode.videoUrl!);
        videoLocalPath =
            videoLocalPath.replaceAll(RegExp(r'\.[^.]+$'), '.$videoExtension');
        videoFile = File(videoLocalPath);

        final videoClient = http.Client();
        try {
          final videoResponse = await videoClient.send(
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
                _downloadProgress[episode.audioUrl] = progress;
                final percent = (progress * 100).round();
                if (percent >= lastLoggedPercent + 25 &&
                    percent <= 100) {
                  log('Download progress (video): ${episode.title} - $percent%',
                      name: logName);
                  lastLoggedPercent = percent;
                }
                notifyListeners();
              }
            }

            await videoSink.flush();
            await videoSink.close();
          } catch (e) {
            await videoSink.close();
            rethrow;
          }

          log('Video download completed: ${episode.title}', name: logName);
        } catch (videoError, videoStackTrace) {
          // FULL FAILURE: Delete audio, cleanup, rethrow
          log('Video download failed - rolling back',
              name: logName, error: videoError, stackTrace: videoStackTrace);

          if (await savedFile.exists()) {
            await savedFile.delete();
          }
          if (await videoFile.exists()) {
            await videoFile.delete();
          }
          await _repository.remove(episode.audioUrl);

          rethrow;
        } finally {
          videoClient.close();
        }
      }

      await _repository.addEpisode(
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

      log(
        'Download completed: ${episode.title}, size: $downloadedBytes bytes',
        name: logName,
      );

      await getDownloads();
    } catch (e, stackTrace) {
      if (_cancelling.contains(episode.audioUrl)) {
        log('Download cancelled: ${episode.title}', name: logName);
      } else {
        log(
          'Failed to download episode',
          name: logName,
          error: e,
          stackTrace: stackTrace,
        );
        _error = e.toString();

        if (localPath != null) {
          try {
            final partialFile = File(localPath);
            if (await partialFile.exists()) {
              await partialFile.delete();
              log('Cleaned up partial file: $localPath', name: logName);
            }
          } catch (cleanupError) {
            log('Failed to clean up partial file',
                name: logName, error: cleanupError);
          }
        }
      }
      notifyListeners();
    } finally {
      _downloading.remove(episode.audioUrl);
      _downloadProgress.remove(episode.audioUrl);
      _activeClients.remove(episode.audioUrl);
      client.close();
      notifyListeners();
      _processQueue();
    }
  }

  Future<void> cancelDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl) && !_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
      return;
    }

    final queuedIndex = _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      log('Removed from queue: $audioUrl', name: logName);
      notifyListeners();
      return;
    }

    _cancelling.add(audioUrl);
    _downloading.remove(audioUrl);
    _downloadProgress.remove(audioUrl);
    notifyListeners();

    final client = _activeClients.remove(audioUrl);
    if (client != null) {
      client.close();
      log('Cancelled download for: $audioUrl', name: logName);
    }

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final episode = await _repository.getByAudioUrl(audioUrl);
      if (episode != null) {
        final file = File(episode.localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _repository.remove(audioUrl);
      }
    } catch (e) {
      log(
        'Failed to clean up cancelled download',
        name: logName,
        error: e,
      );
    } finally {
      _cancelling.remove(audioUrl);
    }

    notifyListeners();
    _processQueue();
  }

  Future<void> _processQueue() async {
    while (_downloadQueue.isNotEmpty && _downloading.length < _maxConcurrentDownloads) {
      final episode = _downloadQueue.removeAt(0);
      log('Processing queued download: ${episode.title}', name: logName);
      download(episode);
    }
    notifyListeners();
  }

  Future<void> remove(String audioUrl) async {
    try {
      await _repository.remove(audioUrl);
      await getDownloads();
    } catch (e, stackTrace) {
      log(
        'Failed to remove download',
        name: logName,
        error: e,
        stackTrace: stackTrace,
      );
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      _isLoading = true;
      notifyListeners();

      for (final url in List.from(_downloading)) {
        await cancelDownload(url);
      }

      _downloadQueue.clear();

      for (final download in List.from(_downloads)) {
        await remove(download.audioUrl);
      }

      log('Cleared all downloads', name: logName);
    } catch (e, stackTrace) {
      log('Failed to clear all downloads', name: logName, error: e, stackTrace: stackTrace);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getTotalDownloadSize() {
    int totalSize = 0;
    for (final download in _downloads) {
      totalSize += download.fileSize;
    }
    return totalSize;
  }

  PodcastEpisode toPodcastEpisode(OfflineEpisode data) {
    return PodcastEpisode(
      title: data.title,
      description: data.description,
      audioUrl: data.audioUrl,
      videoUrl: data.videoUrl,
      imageUrl: data.imageUrl,
      podcastTitle: data.podcastTitle,
      podcastRSS: data.podcastRSS,
      duration: Duration(seconds: data.duration),
      publicationDate: data.publicationDate,
    );
  }
}
