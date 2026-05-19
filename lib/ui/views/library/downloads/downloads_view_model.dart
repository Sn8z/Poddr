import 'package:flutter/widgets.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/ui/utils/sort_fields.dart';

class DownloadsViewModel extends ChangeNotifier {
  final OfflineProvider _offlineProvider;
  final MediaProvider _mediaProvider;
  final SubscriptionProvider _subscriptionProvider;
  final CollectionsProvider _collectionsProvider;

  String _filter = '';
  String get filter => _filter;

  OfflineEpisodeSortField _sortField = OfflineEpisodeSortField.downloadedAt;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  Set<int> _selectedCollectionIds = {};
  Set<int> get selectedCollectionIds => _selectedCollectionIds;

  DownloadsViewModel(this._offlineProvider, this._mediaProvider,
      this._subscriptionProvider, this._collectionsProvider) {
    _offlineProvider.addListener(notifyListeners);
    _subscriptionProvider.addListener(notifyListeners);
    _collectionsProvider.addListener(notifyListeners);
  }

  List<OfflineEpisode> get downloads {
    var downloads = _offlineProvider.downloads;

    if (_selectedCollectionIds.isNotEmpty) {
      final idByRss = _subscriptionProvider.subscriptionIdByRss;
      final subToCol = _collectionsProvider.subscriptionToCollections;
      downloads = downloads.where((d) {
        final subId = idByRss[d.podcastRSS];
        if (subId == null) return false;
        final collectionIds = subToCol[subId] ?? {};
        return _selectedCollectionIds.any((id) => collectionIds.contains(id));
      }).toList();
    }

    return filterAndSortOfflineEpisodes(
      episodes: downloads,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
  }

  bool get isLoading => _offlineProvider.isLoading;
  Map<String, double> get downloadProgress => _offlineProvider.downloadProgress;
  Set<String> get downloading => _offlineProvider.downloading;
  List<PodcastEpisode> get downloadQueue => _offlineProvider.downloadQueue;

  void loadMedia({
    required String audioUrl,
    required String episodeTitle,
    required String podcastTitle,
    required String podcastRSS,
    String? description,
    String? artUri,
    String? album,
    String? artist,
    String? videoUrl,
  }) {
    _mediaProvider.loadMedia(
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      episodeTitle: episodeTitle,
      podcastTitle: podcastTitle,
      podcastRSS: podcastRSS,
      description: description,
      artUri: artUri,
      album: album,
      artist: artist,
    );
  }

  PodcastEpisode? toPodcastEpisode(OfflineEpisode data) {
    return _offlineProvider.toPodcastEpisode(data);
  }

  void remove(String audioUrl) {
    _offlineProvider.remove(audioUrl);
  }

  void clearAllDownloads() {
    _offlineProvider.clearAll();
  }

  int getQueuePosition(String audioUrl) {
    return _offlineProvider.getQueuePosition(audioUrl);
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void setSort({
    OfflineEpisodeSortField? field,
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
    _offlineProvider.removeListener(notifyListeners);
    _subscriptionProvider.removeListener(notifyListeners);
    _collectionsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
