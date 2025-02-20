import 'package:flutter/material.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/podcast_service.dart';

class PodcastProvider extends ChangeNotifier {
  final PodcastService _podcastService = PodcastService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PodcastFeed? _podcast;
  PodcastFeed? get podcast => _podcast;

  String? _currentRss;
  String? get currentRss => _currentRss;

  Future<void> getPodcast(String rss) async {
    if (_currentRss == rss) return;
    _currentRss = rss;
    _podcast = null;
    _setLoading(true);

    try {
      _podcast = await _podcastService.getFeed(rss);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
