import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/models/country.dart';
import 'package:poddr/models/genre.dart';
import 'package:poddr/data/countries/country_repository.dart';
import 'package:poddr/data/countries/itunes_country_repository.dart';
import 'package:poddr/data/genres/genre_repository.dart';
import 'package:poddr/data/genres/itunes_genre_repository.dart';

class DiscoverViewModel extends ChangeNotifier {
  static const String logName = "DiscoverViewModel";

  final IPodcastRepository _podcastRepository;
  final ISettingsRepository _settingsRepository;
  final ICountryRepository _countryRepository;
  final IGenreRepository _genreRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _countryCode = '';
  String get countryCode => _countryCode;
  String get country {
    final country = _countryRepository.getCountries().firstWhere(
      (element) => element.code == _countryCode,
      orElse: () => const Country(code: 'us', name: 'United States'),
    );
    return country.name;
  }

  List<Country> get countries => _countryRepository.getCountries();

  String _genreID = '';
  String get genreID => _genreID;
  String get genre {
    final genre = _genreRepository.getGenres().firstWhere(
      (element) => element.id == _genreID,
      orElse: () => const Genre(id: '', name: 'All'),
    );
    return genre.name;
  }

  List<Genre> get genres => _genreRepository.getGenres();

  List<Podcast> charts = [];

  DiscoverViewModel({
    IPodcastRepository? podcastRepository,
    ISettingsRepository? settingsRepository,
    ICountryRepository? countryRepository,
    IGenreRepository? genreRepository,
  })  : _podcastRepository = podcastRepository ?? ITunesPodcastRepository(),
        _settingsRepository =
            settingsRepository ?? SharedPrefSettingsRepository(),
        _countryRepository = countryRepository ?? ItunesCountryRepository(),
        _genreRepository = genreRepository ?? ItunesGenreRepository() {
    _init();
  }

  Future<void> _init() async {
    debug("Initializing DiscoverViewModel", name: logName);
    _countryCode = await _settingsRepository.getCountryCode();
    _genreID = await _settingsRepository.getGenreID();
    await getCharts();
  }

  void setCountry(String code) async {
    _countryCode = code;
    await getCharts();
    await _settingsRepository.saveCountryCode(code);
    info("Set country to: $code", name: logName);
  }

  void setGenre(String genre) async {
    _genreID = genre;
    await getCharts();
    await _settingsRepository.saveGenreID(genre);
    info("Set genre to: $genre", name: logName);
  }

  Future<void> getCharts() async {
    debug(
        "Fetching charts for country: $_countryCode and genre: $_genreID",
        name: logName);
    _isLoading = true;
    notifyListeners();

    charts = await _podcastRepository.getCharts(_countryCode, _genreID);

    _isLoading = false;
    notifyListeners();
  }
}
