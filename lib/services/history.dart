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
    _listen();
  }

  void _listen() {
    _isLoading = true;
    _watchSubscription?.cancel();
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

  void retryHistory() {
    _historyState = const AsyncLoading();
    _notify();
    _listen();
  }

  Future<void> upsertProgress(
    String audioUrl, {
    required int position,
    required int duration,
    bool markFinished = true,
    String? title,
    String? description,
    String? imageUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? videoUrl,
  }) async {
    try {
      await _historyRepository.upsertProgress(
        audioUrl,
        position: position,
        duration: duration,
        markFinished: markFinished,
        title: title,
        description: description,
        imageUrl: imageUrl,
        podcastTitle: podcastTitle,
        podcastRSS: podcastRSS,
        videoUrl: videoUrl,
      );
    } catch (e) {
      warning('Failed to save progress: $e', name: logName);
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

      final existingDuration = existing?.duration ?? 0;
      final effectiveDuration = duration > 0
          ? duration
          : (existingDuration > 0
              ? existingDuration
              : episode?.duration?.inSeconds ?? 0);

      await upsertProgress(
        audioUrl,
        position: position,
        duration: effectiveDuration,
        markFinished: false,
        title: episode == null ? null : (episode.title ?? ''),
        description: episode == null ? null : (episode.description ?? ''),
        imageUrl: episode == null ? null : (episode.imageUrl ?? ''),
        podcastTitle: episode == null ? null : (episode.podcastTitle ?? ''),
        podcastRSS: episode == null ? null : (episode.podcastRSS ?? ''),
        videoUrl: episode?.videoUrl,
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

  Stream<EpisodeProgress?> watchProgressByAudioUrl(String audioUrl) {
    try {
      return _historyRepository.watchProgressByAudioUrl(audioUrl);
    } catch (e, stackTrace) {
      error('Failed to watch progress',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Watch progress detail: $e', name: logName);
      return const Stream.empty();
    }
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
