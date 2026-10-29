import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/podcast/itunes_podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/ui/utils/sort_fields.dart';

class PodcastViewModel extends ChangeNotifier {
  final IPodcastRepository _podcastRepository;

  AsyncState<Podcast> _podcastState = const AsyncInitial();
  AsyncState<Podcast> get podcastState => _podcastState;

  Podcast? get podcast => switch (_podcastState) {
        AsyncData(:final value) => value,
        _ => null,
      };

  bool get isLoading => _podcastState is AsyncLoading;

  String? _currentRss;
  String? get currentRss => _currentRss;

  final TextEditingController filterController = TextEditingController();

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
    final podcast = this.podcast;
    if (podcast == null) return [];
    return filterAndSortEpisodes(
      episodes: podcast.episodes,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
  }

  Future<void> getPodcast(String rss, {bool force = false}) async {
    if (!force && _currentRss == rss) return;

    _currentRss = rss;
    _podcastState = const AsyncLoading();
    notifyListeners();

    try {
      final podcast = await _podcastRepository.getFeed(rss);
      _podcastState = AsyncData(podcast);
    } on PoddrException catch (e, stackTrace) {
      error('Failed to load podcast',
          name: 'PodcastViewModel', error: e, stackTrace: stackTrace);
      _podcastState = AsyncError(e.userMessage);
    } catch (e, stackTrace) {
      error('Failed to load podcast unexpectedly',
          name: 'PodcastViewModel', error: e, stackTrace: stackTrace);
      _podcastState = const AsyncError(
        'This podcast could not be loaded. Please try again.',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> retry() async {
    final rss = _currentRss;
    if (rss == null) return;
    await getPodcast(rss, force: true);
  }

  void setFilter(String value) {
    _filter = value;
    if (filterController.text != value) {
      filterController.text = value;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
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
