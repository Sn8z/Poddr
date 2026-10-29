import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/podcast/itunes_podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class SearchViewModel extends ChangeNotifier {
  final logName = "SearchViewModel";

  final IPodcastRepository _podcastRepository;

  List<String> searchHistory = [];
  List<String> searchSuggestions = [];

  AsyncState<List<Podcast>> _searchState = const AsyncInitial();
  AsyncState<List<Podcast>> get searchState => _searchState;

  String? _lastQuery;

  SearchViewModel({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository();

  Future<void> searchPodcast(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchState = const AsyncInitial();
      notifyListeners();
      return;
    }

    _lastQuery = trimmed;
    _searchState = const AsyncLoading();
    notifyListeners();

    try {
      final results = await _podcastRepository.search(trimmed);
      _searchState = AsyncData(results);
    } on PoddrException catch (e, stackTrace) {
      error("Search failed", name: logName, error: e, stackTrace: stackTrace);
      _searchState = AsyncError(e.userMessage);
    } catch (e, stackTrace) {
      error("Search failed unexpectedly",
          name: logName, error: e, stackTrace: stackTrace);
      _searchState = const AsyncError(
        'Something went wrong. Please try again.',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> retrySearch() async {
    final query = _lastQuery;
    if (query == null) return;
    await searchPodcast(query);
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
