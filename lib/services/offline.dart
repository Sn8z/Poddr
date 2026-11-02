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

enum DownloadState { idle, queued, downloading, failed, downloaded }

typedef DownloadView = ({
  DownloadState state,
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
  final Set<String> _downloading = {};
  final Set<String> _cancelling = {};
  final Map<String, PoddrHttpClient> _activeClients = {};
  final Map<String, PodcastEpisode> _activeEpisodes = {};
  final List<PodcastEpisode> _downloadQueue = [];

  final Map<String, ({PodcastEpisode episode, String error})> _failed = {};
  Map<String, PodcastEpisode> get failedEpisodes => Map.unmodifiable({
        for (final failure in _failed.entries)
          failure.key: failure.value.episode,
      });
  int get failedDownloadCount => _failed.length;

  static const int _maxDownloadAttempts = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 600);

  String? _lastError;
  String? get lastError => _lastError;

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

  int _queuePosition(String audioUrl) {
    return _downloadQueue.indexWhere((e) => e.audioUrl == audioUrl) + 1;
  }

  DownloadView downloadView(String audioUrl) {
    final error = _failed[audioUrl]?.error;

    if (_downloading.contains(audioUrl)) {
      return (
        state: DownloadState.downloading,
        progress: _downloadProgress[audioUrl] ?? 0,
        queuePosition: 0,
        error: error,
      );
    }

    if (_downloadQueue.any((e) => e.audioUrl == audioUrl)) {
      return (
        state: DownloadState.queued,
        progress: 0,
        queuePosition: _queuePosition(audioUrl),
        error: error,
      );
    }

    if (_failed.containsKey(audioUrl)) {
      return (
        state: DownloadState.failed,
        progress: 0,
        queuePosition: 0,
        error: error,
      );
    }

    if (_downloads.any((d) => d.audioUrl == audioUrl)) {
      return (
        state: DownloadState.downloaded,
        progress: 0,
        queuePosition: 0,
        error: error,
      );
    }

    return (
      state: DownloadState.idle,
      progress: 0,
      queuePosition: 0,
      error: error,
    );
  }

  Future<String?> getLocalPath(String audioUrl) async {
    return await _repository.getLocalPath(audioUrl);
  }

  Future<String?> getVideoLocalPath(String audioUrl) async {
    return await _repository.getVideoLocalPath(audioUrl);
  }

  void _trackProgress(String audioUrl, String title, double rawProgress) {
    final progress = rawProgress.clamp(0.0, 1.0);
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
    _failed.remove(audioUrl);
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
        final wasInterrupted = _cancelling.contains(audioUrl);

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

        if (_cancelling.contains(audioUrl)) {
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
        info('Added to download queue: ${episode.title}', name: logName);
        _notify();
      }
      return;
    }

    _downloading.add(audioUrl);
    _activeEpisodes[audioUrl] = episode;
    _failed.remove(audioUrl);
    _lastError = null;
    _downloadProgress[audioUrl] = 0.0;
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
      _failed.remove(audioUrl);
    } on DownloadCancelledException {
      info('Download cancelled: ${episode.title}', name: logName);
    } catch (e, stackTrace) {
      if (_cancelling.contains(audioUrl)) {
        info('Download cancelled: ${episode.title}', name: logName);
      } else {
        error('Failed to download episode',
            name: logName, error: e, stackTrace: stackTrace);
        _failed[audioUrl] = (episode: episode, error: friendlyErrorMessage(e));
        _lastError = friendlyErrorMessage(e);
      }
      _notify();
    } finally {
      _downloading.remove(audioUrl);
      _activeClients.remove(audioUrl);
      _cancelling.remove(audioUrl);
      _activeEpisodes.remove(audioUrl);
      if (!_failed.containsKey(audioUrl)) {
        _clearTransferState(audioUrl);
      }
      client.close();
      _notify();
      _processQueue();
    }
  }

  Future<void> retryFailedDownloads() async {
    final episodes = [for (final failure in _failed.values) failure.episode];
    if (episodes.isEmpty) return;

    _failed.clear();
    _lastError = null;
    _notify();

    for (final episode in episodes) {
      await download(episode);
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
      _notify();
      return;
    }

    final episode = _activeEpisodes[audioUrl];
    _cancelling.add(audioUrl);
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

  void _processQueue() {
    while (_downloadQueue.isNotEmpty &&
        _downloading.length < _maxConcurrentDownloads) {
      final episode = _downloadQueue.removeAt(0);
      info('Processing queued download: ${episode.title}', name: logName);
      unawaited(download(episode));
    }
    _notify();
  }

  Future<bool> remove(String audioUrl) async {
    try {
      await _repository.remove(audioUrl);
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

      _activeEpisodes.clear();
      _failed.clear();
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
