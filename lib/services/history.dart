import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';

class HistoryProvider extends ChangeNotifier {
  static const String logName = "HistoryProvider";

  final IHistoryRepository _historyRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> _history = [];
  List<PodcastEpisode> get history => _history;

  StreamSubscription<List<PodcastEpisode>>? _watchSubscription;
  bool _disposed = false;

  HistoryProvider({IHistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? DriftHistoryRepository() {
    _isLoading = true;
    _watchSubscription = _historyRepository.watchAllHistory().listen(
      (items) {
        _history = items;
        _isLoading = false;
        _notify();
      },
      onError: (e) {
        error('Failed to watch history', name: logName);
        debug('Watch history detail: $e', name: logName);
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
    try {
      _history = await _historyRepository.getHistory();
      _notify();
    } catch (e, stackTrace) {
      error('Failed to get history',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Get history detail: $e', name: logName);
    }
  }

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
    } catch (e, stackTrace) {
      error('Failed to add to history',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Add to history detail: $e', name: logName);
    }
  }

  Future<void> updateProgress(
      String audioUrl, int position, int duration) async {
    try {
      await _historyRepository.updateProgress(
        audioUrl,
        position,
        duration,
      );
    } catch (e) {
      error('Failed to update progress', name: logName);
      debug('Update progress detail: $e', name: logName);
    }
  }

  Future<Map<String, dynamic>?> getProgress(String audioUrl) async {
    try {
      return await _historyRepository.getProgress(audioUrl);
    } catch (e, stackTrace) {
      error('Failed to get progress',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Get progress detail: $e', name: logName);
      return null;
    }
  }

  Stream<ListeningHistoryData?> watchProgressByAudioUrl(String audioUrl) {
    try {
      return _historyRepository.watchProgressByAudioUrl(audioUrl);
    } catch (e, stackTrace) {
      error('Failed to watch progress',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Watch progress detail: $e', name: logName);
      return const Stream.empty();
    }
  }

  Future<void> removeHistory(String audioUrl) async {
    try {
      await _historyRepository.removeHistory(audioUrl);
    } catch (e, stackTrace) {
      error('Failed to remove history',
          name: logName, error: e, stackTrace: stackTrace);
      debug('Remove history detail: $e', name: logName);
    }
  }
}
