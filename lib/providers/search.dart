import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:poddr/services/podcast_service.dart';

class SearchProvider extends ChangeNotifier {
  final PodcastService _podcastService = PodcastService();
  SearchResult searchResults = SearchResult();
  List<String> searchHistory = [];
  List<String> searchSuggestions = [];
  bool isSearching = false;

  Future<void> searchPodcast(String query) async {
    isSearching = true;
    notifyListeners();
    searchResults = await _podcastService.search(query);
    isSearching = false;
    notifyListeners();
  }

  Future<SearchResult> getCharts(String? code, String? genre) async {
    return _podcastService.getCharts(code, genre);
  }

  Future<Podcast> getFeed(String rss) async {
    return _podcastService.getFeed(rss);
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
