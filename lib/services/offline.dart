import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:poddr/core/log.dart';
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/offline/offline_repository.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';

enum DownloadStatus { queued, downloading, paused, failed }

enum DownloadUiState { idle, queued, downloading, failed, downloaded }

typedef DownloadView = ({
  DownloadUiState state,
  double progress,
  int queuePosition,
  String? error,
});

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

  final Map<String, PodcastEpisode> _failedEpisodes = {};
  Map<String, PodcastEpisode> get failedEpisodes =>
      Map.unmodifiable(_failedEpisodes);
  int get failedDownloadCount => _failedEpisodes.length;

  static const int _maxDownloadAttempts = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 600);

  String? _lastError;
  String? get lastError => _lastError;

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

  StreamSubscription<List<OfflineEpisode>>? _watchSubscription;
  bool _disposed = false;

  OfflineProvider({IOfflineRepository? repository})
      : _repository = repository ?? DriftOfflineRepository() {
    _init();
  }

  @override
  void dispose() {
    _disposed = true;
    _watchSubscription?.cancel();
    _cancelling.addAll(_downloading);
    for (final client in _activeClients.values) {
      client.close();
    }
    _activeClients.clear();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _init() async {
    _isLoading = true;
    _watchSubscription = _repository.watchAllEpisodes().listen(
      (episodes) {
        _downloads = episodes;
        _isLoading = false;
        if (!_disposed) _notify();
      },
      onError: (e) {
        error('Failed to watch downloads', name: logName);
        debug('Watch downloads detail: $e', name: logName);
        _isLoading = false;
        if (!_disposed) _notify();
      },
    );
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

  DownloadView downloadView(String audioUrl) {
    final error = _statusErrors[audioUrl];

    if (_downloading.contains(audioUrl)) {
      return (
        state: DownloadUiState.downloading,
        progress: _downloadProgress[audioUrl] ?? 0,
        queuePosition: 0,
        error: error,
      );
    }

    if (_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
      return (
        state: DownloadUiState.queued,
        progress: 0,
        queuePosition: getQueuePosition(audioUrl),
        error: error,
      );
    }

    if (_statuses[audioUrl] == DownloadStatus.failed) {
      return (
        state: DownloadUiState.failed,
        progress: 0,
        queuePosition: 0,
        error: error,
      );
    }

    if (_downloads.any((d) => d.audioUrl == audioUrl)) {
      return (
        state: DownloadUiState.downloaded,
        progress: 0,
        queuePosition: 0,
        error: error,
      );
    }

    return (
      state: DownloadUiState.idle,
      progress: 0,
      queuePosition: 0,
      error: error,
    );
  }

  Future<void> getDownloads() async {
    try {
      _isLoading = true;
      _notify();

      _downloads = await _repository.getAll();
    } catch (e, stackTrace) {
      error('Failed to get downloads',
          name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      _notify();
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
      _notify();
    }
  }

  void _clearTransferState(String audioUrl) {
    _downloadProgress.remove(audioUrl);
    _statuses.remove(audioUrl);
    _statusErrors.remove(audioUrl);
    _failedEpisodes.remove(audioUrl);
    _speeds.remove(audioUrl);
    _etas.remove(audioUrl);
    _lastProgress.remove(audioUrl);
    _lastProgressTime.remove(audioUrl);
    _notifiedProgress.remove(audioUrl);
  }

  bool _isTransientDownloadFailure(Object error) {
    if (error is DownloadCancelledException ||
        error is InsufficientSpaceException) {
      return false;
    }
    if (error is NetworkException || error is ServerErrorException) {
      return true;
    }
    if (error is TimeoutException ||
        error is http.ClientException ||
        error is SocketException) {
      return true;
    }
    if (error is DownloadFailedException) {
      final statusCode = error.statusCode;
      if (statusCode == null) return false;
      return statusCode == 408 || statusCode == 429 || statusCode >= 500;
    }
    return false;
  }

  Future<void> _downloadWithRetry(PodcastEpisode episode, String audioUrl,
      PoddrHttpClient client, String title) async {
    for (var attempt = 0;; attempt++) {
      try {
        await _repository.downloadEpisode(
          episode,
          onProgress: (progress) => _trackProgress(audioUrl, title, progress),
          isCancelled: () => _cancelling.contains(audioUrl),
          client: client,
        );
        return;
      } catch (e) {
        final isLastAttempt = attempt >= _maxDownloadAttempts - 1;
        final wasInterrupted =
            _paused.contains(audioUrl) || _cancelling.contains(audioUrl);

        if (isLastAttempt ||
            wasInterrupted ||
            !_isTransientDownloadFailure(e)) {
          rethrow;
        }

        final delay = _baseRetryDelay * (attempt + 1);
        info(
          'Download attempt ${attempt + 1} failed for $title, '
          'retrying in ${delay.inMilliseconds}ms',
          name: logName,
        );
        await Future.delayed(delay);

        if (_paused.contains(audioUrl) || _cancelling.contains(audioUrl)) {
          throw DownloadCancelledException();
        }
      }
    }
  }

  Future<void> download(PodcastEpisode episode) async {
    if (_disposed) return;
    final audioUrl = episode.audioUrl;
    if (_downloading.contains(audioUrl)) return;

    final queuedIndex =
        _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl);
    if (queuedIndex != -1) {
      _downloadQueue.removeAt(queuedIndex);
      _notify();
    }

    if (_downloading.length >= _maxConcurrentDownloads) {
      if (!_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
        _downloadQueue.add(episode);
        _statuses[audioUrl] = DownloadStatus.queued;
        info('Added to download queue: ${episode.title}', name: logName);
        _notify();
      }
      return;
    }

    _downloading.add(audioUrl);
    _activeEpisodes[audioUrl] = episode;
    _paused.remove(audioUrl);
    _failedEpisodes.remove(audioUrl);
    _lastError = null;
    _statuses[audioUrl] = DownloadStatus.downloading;
    _statusErrors.remove(audioUrl);
    _downloadProgress.putIfAbsent(audioUrl, () => 0.0);
    _notify();

    final client = PoddrHttpClient();
    _activeClients[audioUrl] = client;

    try {
      final existing = await _repository.getByAudioUrl(audioUrl);
      if (existing != null) {
        final localFile = File(existing.localPath);
        if (await localFile.exists()) {
          info('Episode already downloaded: ${episode.title}', name: logName);
          _clearTransferState(audioUrl);
          return;
        }
        await _repository.remove(audioUrl);
      }

      await _downloadWithRetry(
        episode,
        audioUrl,
        client,
        episode.title ?? '',
      );

      info('Download completed: ${episode.title}', name: logName);
      _failedEpisodes.remove(audioUrl);
      _statuses.remove(audioUrl);
      _statusErrors.remove(audioUrl);
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
        _statusErrors[audioUrl] = friendlyErrorMessage(e);
        _failedEpisodes[audioUrl] = episode;
        _lastError = friendlyErrorMessage(e);
      }
      _notify();
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
      _notify();
      _processQueue();
    }
  }

  Future<void> pauseDownload(String audioUrl) async {
    if (!_downloading.contains(audioUrl)) return;
    _paused.add(audioUrl);
    _cancelling.add(audioUrl);
    _activeClients[audioUrl]?.close();
    _activeClients.remove(audioUrl);
    _notify();
  }

  Future<void> resumeDownload(PodcastEpisode episode) async {
    _paused.remove(episode.audioUrl);
    _statuses.remove(episode.audioUrl);
    _statusErrors.remove(episode.audioUrl);
    _lastProgress.remove(episode.audioUrl);
    _lastProgressTime.remove(episode.audioUrl);
    await download(episode);
  }

  Future<void> retryFailedDownloads() async {
    final episodes = List<PodcastEpisode>.from(_failedEpisodes.values);
    if (episodes.isEmpty) return;

    for (final episode in episodes) {
      _failedEpisodes.remove(episode.audioUrl);
      _statuses.remove(episode.audioUrl);
      _statusErrors.remove(episode.audioUrl);
    }
    _lastError = null;
    _notify();

    for (final episode in episodes) {
      await download(episode);
    }
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
      _notify();
      return;
    }

    final episode = _activeEpisodes[audioUrl];
    _cancelling.add(audioUrl);
    _paused.remove(audioUrl);
    _activeClients[audioUrl]?.close();
    _activeClients.remove(audioUrl);
    _downloading.remove(audioUrl);
    _notify();

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

    _notify();
    _processQueue();
  }

  Future<void> _processQueue() async {
    while (_downloadQueue.isNotEmpty &&
        _downloading.length < _maxConcurrentDownloads) {
      final episode = _downloadQueue.removeAt(0);
      info('Processing queued download: ${episode.title}', name: logName);
      download(episode);
    }
    _notify();
  }

  Future<bool> remove(String audioUrl) async {
    try {
      await _repository.remove(audioUrl);
      _paused.remove(audioUrl);
      _clearTransferState(audioUrl);
      _lastError = null;
      _notify();
      return true;
    } catch (e, stackTrace) {
      error('Failed to remove download',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = friendlyErrorMessage(e);
      _notify();
      return false;
    }
  }

  Future<bool> clearAll() async {
    var success = true;
    try {
      _isLoading = true;
      _notify();

      for (final url in List.from(_downloading)) {
        await cancelDownload(url);
      }

      for (final url in List.from(_paused)) {
        final episode = _activeEpisodes[url];
        if (episode != null) {
          try {
            await _repository.discardPartials(episode);
          } catch (e, stackTrace) {
            success = false;
            error('Failed to discard partial download',
                name: logName, error: e, stackTrace: stackTrace);
          }
        }
        _clearTransferState(url);
      }
      _paused.clear();
      _activeEpisodes.clear();
      _statuses.clear();
      _statusErrors.clear();
      _failedEpisodes.clear();
      _lastError = null;

      for (final queued in List.from(_downloadQueue)) {
        _clearTransferState(queued.audioUrl);
      }
      _downloadQueue.clear();

      for (final download in List.from(_downloads)) {
        if (!await remove(download.audioUrl)) success = false;
      }

      if (success) {
        info('Cleared all downloads', name: logName);
      }
    } catch (e, stackTrace) {
      success = false;
      _lastError = friendlyErrorMessage(e);
      error('Failed to clear all downloads',
          name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      _notify();
    }
    return success;
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
