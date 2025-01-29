import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:poddr/services/podcast_service.dart';

class PodcastDiscoveryProvider extends ChangeNotifier {
  final PodcastService _podcastService;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _country = 'us';
  String get country => _country;

  String _genre = '';
  String get genre => _genre;

  SearchResult charts = SearchResult(items: []);

  PodcastDiscoveryProvider()
      : _podcastService = PodcastService(),
        super() {
    getCharts();
  }

  void setCountry(String code) {
    _country = code;
    notifyListeners();
    getCharts();
  }

  void setGenre(String genre) {
    _genre = genre;
    notifyListeners();
    getCharts();
  }

  Future<void> getCharts() async {
    _isLoading = true;
    notifyListeners();
    charts = await _podcastService.getCharts(_country, _genre);
    _isLoading = false;
    notifyListeners();
  }
}
