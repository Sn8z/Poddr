import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/data/history/history_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/profile.dart';

class HistoryProvider extends ChangeNotifier {
  final logName = "HistoryProvider";

  final IHistoryRepository _historyRepository;

  ProfileProvider? _profileProvider;
  int? _currentProfileId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PodcastEpisode> _history = [];
  List<PodcastEpisode> get history => _history;

  HistoryProvider({IHistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? DriftHistoryRepository();

  void update(ProfileProvider? profileProvider) {
    _profileProvider = profileProvider;

    final newId = _profileProvider?.currentProfile?.id;

    if (newId != _currentProfileId) {
      _currentProfileId = newId;

      if (newId != null) {
        getHistory();
      } else {
        _history = [];
        notifyListeners();
      }
    }
  }

  Future<void> getHistory() async {
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      _setLoading(true);
      _history = await _historyRepository.getHistory(profileId);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    } finally {
      notifyListeners();
      _setLoading(false);
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
    final profileId = _currentProfileId;
    if (profileId == null) return;

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
        profileId,
      );
      await getHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateProgress(
      String audioUrl, int position, int duration) async {
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      await _historyRepository.updateProgress(
        profileId,
        audioUrl,
        position,
        duration,
      );
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>?> getProgress(String audioUrl) async {
    final profileId = _currentProfileId;
    if (profileId == null) return null;

    try {
      return await _historyRepository.getProgress(profileId, audioUrl);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Stream<ListeningHistoryData?> getProgressStream(String audioUrl) {
    final profileId = _currentProfileId;
    if (profileId == null) return const Stream.empty();

    try {
      return _historyRepository.getProgressStream(profileId, audioUrl);
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return const Stream.empty();
    }
  }

  Future<void> removeHistory(String audioUrl) async {
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      await _historyRepository.removeHistory(profileId, audioUrl);
      getHistory();
    } catch (e, stackTrace) {
      log(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
