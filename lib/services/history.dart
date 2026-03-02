import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';

class HistoryProvider extends ChangeNotifier {
  final logName = "HistoryProvider";

  final IHistoryRepository _historyRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> _history = [];
  List<PodcastEpisode> get history => _history;

  HistoryProvider({IHistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? DriftHistoryRepository();


  Future<void> getHistory() async {
    try {
      _isLoading = true;
      notifyListeners();

      _history = await _historyRepository.getHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(
    String audioUrl,
    String title,
    String description,
    String imageUrl,
    String podcastTitle,
    String podcastRSS,
    int position,
    int duration,
  ) async {
    try {
      final newItem = await _historyRepository.addHistory(
        audioUrl,
        title,
        description,
        imageUrl,
        podcastTitle,
        podcastRSS,
        position,
        duration,
      );
      if (newItem != null) {
        _history.insert(0, newItem);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>?> getProgress(String audioUrl) async {
    try {
      return await _historyRepository.getProgress(audioUrl);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Stream<ListeningHistoryData?> getProgressStream(String audioUrl) {
    try {
      return _historyRepository.getProgressStream(audioUrl);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return const Stream.empty();
    }
  }

  Future<void> removeHistory(String audioUrl) async {
    try {
      await _historyRepository.removeHistory(audioUrl);
      _history.removeWhere((ep) => ep.audioUrl == audioUrl);
      notifyListeners();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }
}
