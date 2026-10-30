import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/progress.dart';

class HistoryProvider extends ChangeNotifier {
  static const String logName = "HistoryProvider";

  final IHistoryRepository _historyRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> _history = [];
  List<PodcastEpisode> get history => _history;

  AsyncState<List<PodcastEpisode>> _historyState = const AsyncLoading();
  AsyncState<List<PodcastEpisode>> get historyState => _historyState;

  String? _lastError;
  String? get lastError => _lastError;

  StreamSubscription<List<PodcastEpisode>>? _watchSubscription;
  bool _disposed = false;

  HistoryProvider({IHistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? DriftHistoryRepository() {
    _isLoading = true;
    _watchSubscription = _historyRepository.watchAllHistory().listen(
      (items) {
        _history = items;
        _historyState = AsyncData(items);
        _isLoading = false;
        _notify();
      },
      onError: (Object e, StackTrace stackTrace) {
        error('Failed to watch history',
            name: logName, error: e, stackTrace: stackTrace);
        _historyState = AsyncError(
          e is PoddrException
              ? e.userMessage
              : 'Listening history could not be loaded. Please try again.',
        );
        _isLoading = false;
        _notify();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _watchSubscription?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> getHistory() async {
    _isLoading = true;
    _historyState = const AsyncLoading();
    _notify();

    try {
      final items = await _historyRepository.getHistory();
      _history = items;
      _historyState = AsyncData(items);
      _lastError = null;
    } on PoddrException catch (e, stackTrace) {
      error('Failed to get history',
          name: logName, error: e, stackTrace: stackTrace);
      _historyState = AsyncError(e.userMessage);
    } catch (e, stackTrace) {
      error('Failed to get history unexpectedly',
          name: logName, error: e, stackTrace: stackTrace);
      _historyState = const AsyncError(
        'Listening history could not be loaded. Please try again.',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> retryHistory() => getHistory();

  Future<void> addToHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int duration,
    String? videoUrl,
  ) async {
    try {
      await _historyRepository.addHistory(
        audioUrl,
        title,
        description,
        imageUrl,
        podcastTitle,
        podcastRSS,
        duration,
        videoUrl,
      );
    } catch (e) {
      warning('Failed to add to history: $e', name: logName);
      debug('Add to history detail', name: logName);
    }
  }

  Future<void> updateProgress(
    String audioUrl,
    int position,
    int duration, {
    bool markFinished = true,
  }) async {
    try {
      await _historyRepository.updateProgress(
        audioUrl,
        position,
        duration,
        markFinished: markFinished,
      );
    } catch (e) {
      warning('Failed to update progress: $e', name: logName);
    }
  }

  Future<void> applyRemoteProgress({
    required String audioUrl,
    required int position,
    int duration = 0,
    PodcastEpisode? episode,
  }) async {
    try {
      final existing = await _historyRepository.getProgress(audioUrl);

      if (existing == null && episode == null) {
        debug('Skipping remote progress for unknown episode $audioUrl',
            name: logName);
        return;
      }

      if (existing == null && episode != null) {
        await addToHistory(
          episode.audioUrl,
          episode.title ?? '',
          episode.description ?? '',
          episode.imageUrl ?? '',
          episode.podcastTitle ?? '',
          episode.podcastRSS ?? '',
          episode.duration?.inSeconds ?? duration,
          episode.videoUrl,
        );
      }

      final existingDuration = existing?.duration ?? 0;
      final effectiveDuration = duration > 0
          ? duration
          : (existingDuration > 0
              ? existingDuration
              : episode?.duration?.inSeconds ?? 0);

      await _historyRepository.updateProgress(
        audioUrl,
        position,
        effectiveDuration,
        markFinished: false,
      );
    } catch (e) {
      warning('Failed to apply remote progress: $e', name: logName);
    }
  }

  Future<EpisodeProgress?> getProgress(String audioUrl) async {
    try {
      return await _historyRepository.getProgress(audioUrl);
    } on PoddrException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to read progress for $audioUrl: $e',
        userMessage: 'Your listening progress could not be loaded.',
      );
    }
  }

  final Map<String, Stream<EpisodeProgress?>> _progressStreams = {};

  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl) {
    return _progressStreams.putIfAbsent(audioUrl, () {
      try {
        return _historyRepository.watchProgressByAudioUrl(audioUrl);
      } catch (e, stackTrace) {
        error('Failed to watch progress',
            name: logName, error: e, stackTrace: stackTrace);
        debug('Watch progress detail: $e', name: logName);
        return const Stream.empty();
      }
    });
  }

  Future<bool> removeHistory(String audioUrl) async {
    try {
      await _historyRepository.removeHistory(audioUrl);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to remove history',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The episode could not be removed from your history. '
              'Please try again.';
      return false;
    }
  }
}
