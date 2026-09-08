import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';

enum DownloadStatus { queued, downloading, paused, failed }

class OfflineProvider extends ChangeNotifier {
  static const String logName = "OfflineProvider";

  final IOfflineRepository _repository;

  List<OfflineEpisode> _downloads = [];
  List<OfflineEpisode> get downloads => _downloads;

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => _downloadProgress;

  final Set<String> _downloading = {};
  Set<String> get downloading => _downloading;

  final Set<String> _paused = {};
  Set<String> get paused => _paused;

  final Set<String> _cancelling = {};
  final Map<String, PoddrHttpClient> _activeClients = {};
  final Map<String, PodcastEpisode> _activeEpisodes = {};
  final List<PodcastEpisode> _downloadQueue = [];
  List<PodcastEpisode> get downloadQueue => _downloadQueue;

  final Map<String, DownloadStatus> _statuses = {};
  Map<String, DownloadStatus> get downloadStatus => _statuses;

  final Map<String, String> _statusErrors = {};
  Map<String, String> get downloadErrors => _statusErrors;

  final Map<String, double> _speeds = {};
  Map<String, double> get downloadSpeeds => _speeds;

  final Map<String, Duration> _etas = {};
  Map<String, Duration> get downloadEtas => _etas;

  final Map<String, double> _lastProgress = {};
  final Map<String, DateTime> _lastProgressTime = {};
  final Map<String, double> _notifiedProgress = {};

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
    try {
      final reclaimed = await _repository.sweepDownloadDir();
      if (reclaimed > 0) {
        info('Reclaimed $reclaimed orphaned files', name: logName);
      }
    } catch (e) {
      error('Failed to sweep download directory', name: logName);
      debug('Sweep detail: $e', name: logName);
    }
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

  void _trackProgress(String audioUrl, String title, double rawProgress) {
    final progress = rawProgress.clamp(0.0, 1.0);
    final now = DateTime.now();
    final previous = _lastProgress[audioUrl];
    final previousTime = _lastProgressTime[audioUrl];
    if (previous != null && previousTime != null) {
      final elapsed = now.difference(previousTime).inMilliseconds / 1000;
      if (elapsed >= 0.5) {
        final speed = (progress - previous) / elapsed;
        if (speed > 0) {
          _speeds[audioUrl] = speed;
          _etas[audioUrl] = Duration(seconds: ((1 - progress) / speed).ceil());
        }
        _lastProgress[audioUrl] = progress;
        _lastProgressTime[audioUrl] = now;
      }
    } else {
      _lastProgress[audioUrl] = progress;
      _lastProgressTime[audioUrl] = now;
    }
    _downloadProgress[audioUrl] = progress;
    final lastNotified = _notifiedProgress[audioUrl] ?? -1.0;
    if ((progress - lastNotified).abs() >= 0.01 || progress >= 1.0) {
      _notifiedProgress[audioUrl] = progress;
      final percent = (progress * 100).round();
      if (percent % 25 == 0 && percent <= 100) {
        debug('Download progress: $title - $percent%', name: logName);
      }
      notifyListeners();
    }
  }

  void _clearTransferState(String audioUrl) {
    _downloadProgress.remove(audioUrl);
    _statuses.remove(audioUrl);
    _statusErrors.remove(audioUrl);
    _speeds.remove(audioUrl);
    _etas.remove(audioUrl);
    _lastProgress.remove(audioUrl);
    _lastProgressTime.remove(audioUrl);
    _notifiedProgress.remove(audioUrl);
  }

  Future<void> download(PodcastEpisode episode) async {
    final audioUrl = episode.audioUrl;
    if (_downloading.contains(audioUrl)) return;

    final queuedIndex =
        _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      notifyListeners();
    }

    if (_downloading.length >= _maxConcurrentDownloads) {
      if (!_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
        _downloadQueue.add(episode);
        _statuses[audioUrl] = DownloadStatus.queued;
        info('Added to download queue: ${episode.title}', name: logName);
        notifyListeners();
      }
      return;
    }

    final existing = await _repository.getByAudioUrl(audioUrl);
    if (existing != null) {
      final localFile = File(existing.localPath);
      if (await localFile.exists()) {
        info('Episode already downloaded: ${episode.title}', name: logName);
        return;
      }
      await _repository.remove(audioUrl);
    }

    _downloading.add(audioUrl);
    _activeEpisodes[audioUrl] = episode;
    _paused.remove(audioUrl);
    _statuses[audioUrl] = DownloadStatus.downloading;
    _statusErrors.remove(audioUrl);
    _downloadProgress.putIfAbsent(audioUrl, () => 0.0);
    notifyListeners();

    final client = PoddrHttpClient();
    _activeClients[audioUrl] = client;

    try {
      await _repository.downloadEpisode(
        episode,
        onProgress: (progress) =>
            _trackProgress(audioUrl, episode.title ?? '', progress),
        isCancelled: () => _cancelling.contains(audioUrl),
        client: client,
      );

      info('Download completed: ${episode.title}', name: logName);
      _statuses.remove(audioUrl);
      _statusErrors.remove(audioUrl);
      await getDownloads();
    } on DownloadCancelledException {
      if (_paused.contains(audioUrl)) {
        _statuses[audioUrl] = DownloadStatus.paused;
        info('Download paused: ${episode.title}', name: logName);
      } else {
        info('Download cancelled: ${episode.title}', name: logName);
      }
    } catch (e, stackTrace) {
      if (_paused.contains(audioUrl)) {
        _statuses[audioUrl] = DownloadStatus.paused;
        info('Download paused: ${episode.title}', name: logName);
      } else if (_cancelling.contains(audioUrl)) {
        info('Download cancelled: ${episode.title}', name: logName);
      } else {
        error('Failed to download episode',
            name: logName, error: e, stackTrace: stackTrace);
        _statuses[audioUrl] = DownloadStatus.failed;
        _statusErrors[audioUrl] = e.toString();
        _error = e.toString();
      }
      notifyListeners();
    } finally {
      _downloading.remove(audioUrl);
      _activeClients.remove(audioUrl);
      _cancelling.remove(audioUrl);
      if (!_paused.contains(audioUrl)) {
        _activeEpisodes.remove(audioUrl);
      }
      if (!_paused.contains(audioUrl) &&
          _statuses[audioUrl] != DownloadStatus.failed) {
        _clearTransferState(audioUrl);
      }
      client.close();
      notifyListeners();
      _processQueue();
    }
  }

  Future<void> pauseDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl)) return;
    _paused.add(audioUrl);
    _cancelling.add(audioUrl);
    _activeClients[audioUrl]?.close();
    _activeClients.remove(audioUrl);
    notifyListeners();
  }

  Future<void> resumeDownload(PodcastEpisode episode) async {
    _paused.remove(episode.audioUrl);
    _statuses.remove(episode.audioUrl);
    _statusErrors.remove(episode.audioUrl);
    _lastProgress.remove(episode.audioUrl);
    _lastProgressTime.remove(episode.audioUrl);
    await download(episode);
  }

  Future<void> cancelDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl) &&
        !_paused.contains(audioUrl) &&
        !_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
      return;
    }

    final queuedIndex =
        _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      _statuses.remove(audioUrl);
      info('Removed from queue: $audioUrl', name: logName);
      notifyListeners();
      return;
    }

    final episode = _activeEpisodes[audioUrl];
    _cancelling.add(audioUrl);
    _paused.remove(audioUrl);
    _activeClients[audioUrl]?.close();
    _activeClients.remove(audioUrl);
    _downloading.remove(audioUrl);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      if (episode != null) {
        await _repository.discardPartials(episode);
      }
      final row = await _repository.getByAudioUrl(audioUrl);
      if (row != null) {
        final file = File(row.localPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _repository.remove(audioUrl);
      }
      _clearTransferState(audioUrl);
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
      _paused.remove(audioUrl);
      _clearTransferState(audioUrl);
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

      for (final url in List.from(_paused)) {
        final episode = _activeEpisodes[url];
        if (episode != null) {
          await _repository.discardPartials(episode);
        }
        _clearTransferState(url);
      }
      _paused.clear();
      _activeEpisodes.clear();
      _statuses.clear();
      _statusErrors.clear();

      for (final queued in List.from(_downloadQueue)) {
        _clearTransferState(queued.audioUrl);
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
