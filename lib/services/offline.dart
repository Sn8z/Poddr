import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';

class OfflineProvider extends ChangeNotifier {
  static const String logName = "OfflineProvider";

  final IOfflineRepository _repository;

  List<OfflineEpisode> _downloads = [];
  List<OfflineEpisode> get downloads => _downloads;

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => _downloadProgress;

  final Set<String> _downloading = {};
  Set<String> get downloading => _downloading;

  final Set<String> _cancelling = {};
  final Map<String, PoddrHttpClient> _activeClients = {};
  final List<PodcastEpisode> _downloadQueue = [];
  List<PodcastEpisode> get downloadQueue => _downloadQueue;

  final int _maxConcurrentDownloads = 3;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

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
      error('Failed to get downloads',
          name: logName, error: e, stackTrace: stackTrace);
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
        info('Added to download queue: ${episode.title}', name: logName);
        notifyListeners();
      }
      return;
    }

    final existing = await _repository.getByAudioUrl(episode.audioUrl);
    if (existing != null) {
      final localFile = File(existing.localPath);
      if (await localFile.exists()) {
        info('Episode already downloaded: ${episode.title}', name: logName);
        return;
      }
      await _repository.remove(episode.audioUrl);
    }

    _downloading.add(episode.audioUrl);
    _downloadProgress[episode.audioUrl] = 0.0;
    notifyListeners();

    final client = PoddrHttpClient();
    _activeClients[episode.audioUrl] = client;

    try {
      await _repository.downloadEpisode(
        episode,
        onProgress: (progress) {
          _downloadProgress[episode.audioUrl] = progress;
          final percent = (progress * 100).round();
          if (percent % 25 == 0 && percent <= 100) {
            debug('Download progress: ${episode.title} - $percent%',
                name: logName);
          }
          notifyListeners();
        },
        onCancel: () {},
        client: client,
      );

      info('Download completed: ${episode.title}', name: logName);
      await getDownloads();
    } on DownloadCancelledException {
      info('Download cancelled: ${episode.title}', name: logName);
    } catch (e, stackTrace) {
      if (_cancelling.contains(episode.audioUrl)) {
        info('Download cancelled: ${episode.title}', name: logName);
      } else {
        error('Failed to download episode',
            name: logName, error: e, stackTrace: stackTrace);
        _error = e.toString();
      }
      notifyListeners();
    } finally {
      _downloading.remove(episode.audioUrl);
      _downloadProgress.remove(episode.audioUrl);
      client.close();
      _activeClients.remove(episode.audioUrl);
      notifyListeners();
      _processQueue();
    }
  }

  Future<void> cancelDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl) &&
        !_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
      return;
    }

    final queuedIndex =
        _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      info('Removed from queue: $audioUrl', name: logName);
      notifyListeners();
      return;
    }

    _cancelling.add(audioUrl);
    _downloading.remove(audioUrl);
    _downloadProgress.remove(audioUrl);
    notifyListeners();

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
      error('Failed to clean up cancelled download', name: logName, error: e);
    } finally {
      _cancelling.remove(audioUrl);
    }

    notifyListeners();
    _processQueue();
  }

  Future<void> _processQueue() async {
    while (_downloadQueue.isNotEmpty &&
        _downloading.length < _maxConcurrentDownloads) {
      final episode = _downloadQueue.removeAt(0);
      info('Processing queued download: ${episode.title}', name: logName);
      download(episode);
    }
    notifyListeners();
  }

  Future<void> remove(String audioUrl) async {
    try {
      await _repository.remove(audioUrl);
      await getDownloads();
    } catch (e, stackTrace) {
      error('Failed to remove download',
          name: logName, error: e, stackTrace: stackTrace);
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

      info('Cleared all downloads', name: logName);
    } catch (e, stackTrace) {
      error('Failed to clear all downloads',
          name: logName, error: e, stackTrace: stackTrace);
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
