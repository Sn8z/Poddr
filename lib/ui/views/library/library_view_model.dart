import 'package:flutter/widgets.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/views/library/collection_filter.dart';

class LibraryViewModel extends ChangeNotifier {
  final SubscriptionProvider _subscriptionProvider;
  final CollectionFilter _collectionFilter;

  final TextEditingController filterController = TextEditingController();

  String _filter = '';
  String get filter => _filter;

  PodcastSortField _sortField = PodcastSortField.title;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.ascending;
  String get sortDirection => _sortDirection.label;

  Set<int> get selectedCollectionIds => _collectionFilter.collectionIds;

  LibraryViewModel(
      this._subscriptionProvider, CollectionsProvider collectionsProvider)
      : _collectionFilter = CollectionFilter(collectionsProvider) {
    _subscriptionProvider.addListener(notifyListeners);
    _collectionFilter.addListener(notifyListeners);
  }

  List<Podcast> get subscriptions {
    final podcasts = _subscriptionProvider.subscriptions
        .where((p) => _collectionFilter.includes(p.rss))
        .toList();

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
    _collectionFilter.dispose();
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
    _collectionFilter.update(ids);
  }
}
