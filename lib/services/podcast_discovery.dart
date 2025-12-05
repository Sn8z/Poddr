import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/data/itunes_countries.dart';
import 'package:poddr/data/itunes_genres.dart';

class PodcastDiscoveryProvider extends ChangeNotifier {
  static const String logName = "PodcastDiscoveryProvider";

  final IPodcastRepository _podcastRepository;
  final ISettingsRepository _settingsRepository =
      SharedPrefSettingsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _countryCode = '';
  String get countryCode => _countryCode;
  String get country {
    final country = itunesCountries.firstWhere(
      (element) => element['code'] == _countryCode,
      orElse: () => {'code': 'us', 'name': 'United States'},
    );
    return country['name'] ?? '';
  }

  List<Map<String, String>> get countries => itunesCountries;

  String _genreID = '';
  String get genreID => _genreID;
  String get genre {
    final genre = itunesGenres.firstWhere(
      (element) => element['id'] == _genreID,
      orElse: () => {'id': '', 'genre': 'All'},
    );
    return genre['genre'] ?? '';
  }

  List<Map<String, String>> get genres => itunesGenres;

  List<Podcast> charts = [];

  PodcastDiscoveryProvider({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository() {
    _init();
  }

  Future<void> _init() async {
    log("Initializing PodcastDiscoveryProvider", name: logName);
    _countryCode = await _settingsRepository.getCountryCode();
    _genreID = await _settingsRepository.getGenreID();
    await getCharts();
  }

  void setCountry(String code) async {
    _countryCode = code;
    await getCharts();
    await _settingsRepository.saveCountryCode(code);
    log("Set country to: $code", name: logName);
  }

  void setGenre(String genre) async {
    _genreID = genre;
    await getCharts();
    await _settingsRepository.saveGenreID(genre);
    log("Set genre to: $genre", name: logName);
  }

  Future<void> getCharts() async {
    log("Fetching charts for country: $_countryCode and genre: $_genreID",
        name: logName);
    _isLoading = true;
    notifyListeners();

    charts = await _podcastRepository.getCharts(_countryCode, _genreID);

    _isLoading = false;
    notifyListeners();
  }
}
