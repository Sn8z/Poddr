import 'package:flutter/material.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/models/episode.dart';

class HistoryProvider extends ChangeNotifier {
  final IHistoryRepository _historyRepository = DriftHistoryRepository();

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
    } catch (e) {
      debugPrint('Error loading history: $e');
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
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  Future<void> updateProgress(
      String audioUrl, int position, int duration) async {
    try {
      await _historyRepository.updateProgress(audioUrl, position, duration);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  Future<Map<String, dynamic>?> getProgress(String guid) async {
    try {
      return await _historyRepository.getProgress(guid);
    } catch (e) {
      debugPrint('Error getting progress: $e');
      return null;
    }
  }

  Future<void> removeHistory(String guid) async {
    try {
      await _historyRepository.removeHistory(guid);
      await getHistory();
    } catch (e) {
      debugPrint('Error removing history: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
