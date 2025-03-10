import 'package:flutter/material.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class SearchProvider extends ChangeNotifier {
  final IPodcastRepository _podcastRepository = ITunesPodcastRepository();
  List<Podcast> searchResults = [];
  List<String> searchHistory = [];
  List<String> searchSuggestions = [];
  bool isSearching = false;

  Future<void> searchPodcast(String query) async {
    isSearching = true;
    notifyListeners();
    searchResults = await _podcastRepository.search(query);
    isSearching = false;
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
    searchHistory.clear();
    notifyListeners();
  }
}
