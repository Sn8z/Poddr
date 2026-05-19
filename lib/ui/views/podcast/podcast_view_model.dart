import 'package:flutter/widgets.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/podcast/itunes_podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/utils/sort_fields.dart';

class PodcastViewModel extends ChangeNotifier {
  final IPodcastRepository _podcastRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Podcast? _podcast;
  Podcast? get podcast => _podcast;

  String? _currentRss;
  String? get currentRss => _currentRss;

  String _filter = '';
  String get filter => _filter;

  EpisodeSortField _sortField = EpisodeSortField.publicationDate;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  PodcastViewModel({
    IPodcastRepository? podcastRepository,
    String? initialRss,
  }) : _podcastRepository = podcastRepository ?? ITunesPodcastRepository() {
    if (initialRss != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getPodcast(initialRss);
      });
    }
  }

  List<PodcastEpisode> get episodes {
    if (_podcast == null) return [];
    return filterAndSortEpisodes(
      episodes: _podcast!.episodes,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
  }

  Future<void> getPodcast(String rss) async {
    if (_currentRss == rss) return;

    try {
      _isLoading = true;
      notifyListeners();

      _currentRss = rss;
      _podcast = null;

      _podcast = await _podcastRepository.getFeed(rss);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void setSort({
    EpisodeSortField? field,
    SortDirection? direction,
  }) {
    if (field != null) _sortField = field;
    if (direction != null) _sortDirection = direction;
    notifyListeners();
  }
}
