import 'package:flutter/material.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/data/itunes_countries.dart';
import 'package:poddr/data/itunes_genres.dart';

// TODO: Refactor
class PodcastDiscoveryProvider extends ChangeNotifier {
  final IPodcastRepository _podcastRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _countryCode = 'us';
  String get countryCode => _countryCode;
  String get country {
    final country = itunesCountries.firstWhere(
      (element) => element['code'] == _countryCode,
    );
    return country['name'] ?? '';
  }

  List<Map<String, String>> get countries => itunesCountries;

  String _genreID = '';
  String get genreID => _genreID;
  String get genre {
    final genre = itunesGenres.firstWhere(
      (element) => element['id'] == _genreID,
    );
    return genre['genre'] ?? '';
  }

  List<Map<String, String>> get genres => itunesGenres;

  List<Podcast> charts = [];

  PodcastDiscoveryProvider({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository() {
    getCharts();
  }

  void setCountry(String code) {
    _countryCode = code;
    getCharts();
  }

  void setGenre(String genre) {
    _genreID = genre;
    getCharts();
  }

  Future<void> getCharts() async {
    _isLoading = true;
    notifyListeners();

    charts = await _podcastRepository.getCharts(_countryCode, _genreID);

    _isLoading = false;
    notifyListeners();
  }
}
