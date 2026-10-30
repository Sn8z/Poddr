import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/utils/sort_fields.dart';

class LibraryViewModel extends ChangeNotifier {
  final SubscriptionProvider _subscriptionProvider;
  final CollectionsProvider _collectionsProvider;

  final TextEditingController filterController = TextEditingController();

  String _filter = '';
  String get filter => _filter;

  PodcastSortField _sortField = PodcastSortField.title;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.ascending;
  String get sortDirection => _sortDirection.label;

  Set<int> _selectedCollectionIds = {};
  Set<int> get selectedCollectionIds => _selectedCollectionIds;

  LibraryViewModel(this._subscriptionProvider, this._collectionsProvider) {
    _subscriptionProvider.addListener(notifyListeners);
    _collectionsProvider.addListener(notifyListeners);
  }

  List<Podcast> get subscriptions {
    var podcasts = _subscriptionProvider.subscriptions;

    if (_selectedCollectionIds.isNotEmpty) {
      final idByRss = _subscriptionProvider.subscriptionIdByRss;
      final subToCol = _collectionsProvider.subscriptionToCollections;
      podcasts = podcasts.where((p) {
        final subId = idByRss[p.rss ?? ''];
        if (subId == null) return false;
        final collectionIds = subToCol[subId] ?? {};
        return _selectedCollectionIds.any((id) => collectionIds.contains(id));
      }).toList();
    }

    return filterAndSortPodcasts(
      podcasts: podcasts,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
  }

  AsyncState<List<Podcast>> get subscriptionsState =>
      _subscriptionProvider.subscriptionsState;

  bool get isLoading => _subscriptionProvider.isLoading;

  String? get lastError => _subscriptionProvider.lastError;

  Future<bool> addSubscription({required String rss}) async {
    return _subscriptionProvider.addSubscription(rss: rss);
  }

  Future<bool> retrySubscription(String rss) async {
    return _subscriptionProvider.retryFeed(rss);
  }

  Future<void> retrySubscriptions() {
    return _subscriptionProvider.retrySubscriptions();
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
    _subscriptionProvider.removeListener(notifyListeners);
    _collectionsProvider.removeListener(notifyListeners);
    filterController.dispose();
    super.dispose();
  }

  void setSort({
    PodcastSortField? field,
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
}
