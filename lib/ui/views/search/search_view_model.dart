import 'package:flutter/material.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class SearchViewModel extends ChangeNotifier {
  final logName = "SearchViewModel";

  final IPodcastRepository _podcastRepository;

  List<Podcast> searchResults = [];
  List<String> searchHistory = [];
  List<String> searchSuggestions = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SearchViewModel({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository();

  Future<void> searchPodcast(String query) async {
    _isLoading = true;
    notifyListeners();

    searchResults = await _podcastRepository.search(query);

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Podcast>> getCharts(String code, String genre) async {
    return _podcastRepository.getCharts(code, genre);
  }

  Future<Podcast> getFeed(String rss) async {
    return _podcastRepository.getFeed(rss);
  }

  void addToHistory(String query) {
    searchHistory.add(query);
    notifyListeners();
  }

  void clearHistory() {
    searchHistory = [];
    notifyListeners();
  }
}
