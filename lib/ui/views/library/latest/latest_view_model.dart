import 'package:flutter/widgets.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/utils/sort_fields.dart';

class LatestEpisodesViewModel extends ChangeNotifier {
  final SubscriptionProvider _source;
  final CollectionsProvider _collectionsProvider;

  String _filter = '';
  String get filter => _filter;

  EpisodeSortField _sortField = EpisodeSortField.publicationDate;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  Set<int> _selectedCollectionIds = {};
  Set<int> get selectedCollectionIds => _selectedCollectionIds;

  LatestEpisodesViewModel(this._source, this._collectionsProvider) {
    _source.addListener(notifyListeners);
    _collectionsProvider.addListener(notifyListeners);
  }

  List<PodcastEpisode> get episodes {
    var episodes = _source.latestEpisodes;

    if (_selectedCollectionIds.isNotEmpty) {
      final idByRss = _source.subscriptionIdByRss;
      final subToCol = _collectionsProvider.subscriptionToCollections;
      episodes = episodes.where((e) {
        final subId = idByRss[e.podcastRSS ?? ''];
        if (subId == null) return false;
        final collectionIds = subToCol[subId] ?? {};
        return _selectedCollectionIds.any((id) => collectionIds.contains(id));
      }).toList();
    }

    return filterAndSortEpisodes(
      episodes: episodes,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
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

  void setCollectionFilter(Set<int> ids) {
    _selectedCollectionIds = ids;
    notifyListeners();
  }

  void clearCollectionFilter() {
    _selectedCollectionIds = {};
    notifyListeners();
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    _collectionsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
