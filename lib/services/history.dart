import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/models/episode.dart';

class HistoryProvider extends ChangeNotifier {
  final IHistoryRepository _historyRepository = DriftHistoryRepository();
  final logName = "HistoryProvider";

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> _history = [];
  List<PodcastEpisode> get history => _history;

  HistoryProvider() {
    _setLoading(true);
    getHistory();
    _setLoading(false);
  }

  Future<void> getHistory() async {
    _setLoading(true);
    try {
      _history = await _historyRepository.getMostRecentHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
    _setLoading(false);
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
    bool isFinished,
  ) async {
    try {
      await _historyRepository.addHistory(
        audioUrl,
        title,
        description,
        imageUrl,
        podcastTitle,
        podcastRSS,
        position,
        duration,
      );
      await getHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateProgress(
      String audioUrl, int position, int duration) async {
    try {
      await _historyRepository.updateProgress(audioUrl, position, duration);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>?> getProgress(String guid) async {
    try {
      return await _historyRepository.getProgress(guid);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Stream<ListeningHistoryData?> getProgressStream(String guid) {
    try {
      return _historyRepository.getProgressStream(guid);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return const Stream.empty();
    }
  }

  Future<void> removeHistory(String guid) async {
    try {
      await _historyRepository.removeHistory(guid);
      await getHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
