import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/views/library/collection_filter.dart';

class LatestEpisodesViewModel extends ChangeNotifier {
  final SubscriptionProvider _source;
  final CollectionFilter _collectionFilter;

  final TextEditingController filterController = TextEditingController();

  String _filter = '';
  String get filter => _filter;

  EpisodeSortField _sortField = EpisodeSortField.publicationDate;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  Set<int> get selectedCollectionIds => _collectionFilter.collectionIds;

  bool get isLoadingLatest => _source.isLoadingLatest;

  AsyncState<List<Podcast>> get subscriptionsState =>
      _source.subscriptionsState;

  Future<void> retrySubscriptions() => _source.retrySubscriptions();

  LatestEpisodesViewModel(this._source, CollectionsProvider collectionsProvider)
      : _collectionFilter = CollectionFilter(collectionsProvider) {
    _source.addListener(notifyListeners);
    _collectionFilter.addListener(notifyListeners);
  }

  List<PodcastEpisode> get episodes {
    final episodes = _source.latestEpisodes
        .where((e) => _collectionFilter.includes(e.podcastRSS))
        .toList();

    return filterAndSortEpisodes(
      episodes: episodes,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
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
    _source.removeListener(notifyListeners);
    _collectionFilter.dispose();
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

  void setCollectionFilter(Set<int> ids) {
    _collectionFilter.update(ids);
  }
}
