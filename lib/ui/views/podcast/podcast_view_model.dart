import 'package:flutter/material.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class PodcastViewModel extends ChangeNotifier {
  final IPodcastRepository _podcastRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Podcast? _podcast;
  Podcast? get podcast => _podcast;

  String? _currentRss;
  String? get currentRss => _currentRss;

  PodcastViewModel({
    IPodcastRepository? podcastRepository,
    String? initialRss,
  }) : _podcastRepository = podcastRepository ?? ITunesPodcastRepository() {
    if (initialRss != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getPodcast(initialRss);
      });
    }
  }

  Future<void> getPodcast(String rss) async {
    if (_currentRss == rss) return;

    try {
      _isLoading = true;
      notifyListeners();

      _currentRss = rss;
      _podcast = null;

      _podcast = await _podcastRepository.getFeed(rss);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
