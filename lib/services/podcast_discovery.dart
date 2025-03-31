import 'package:flutter/material.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/data/itunes_countries.dart';
import 'package:poddr/data/itunes_genres.dart';

class PodcastDiscoveryProvider extends ChangeNotifier {
  final IPodcastRepository _podcastRepository = ITunesPodcastRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _country = 'us';
  String get country => _country;
  List<Map<String, String>> get countries => itunesCountries;

  String _genre = '';
  String get genre => _genre;
  List<Map<String, String>> get genres => itunesGenres;

  List<Podcast> charts = [];

  PodcastDiscoveryProvider() {
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
    charts = await _podcastRepository.getCharts(_country, _genre);
    _isLoading = false;
    notifyListeners();
  }
}
