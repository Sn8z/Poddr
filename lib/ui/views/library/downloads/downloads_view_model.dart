import 'package:flutter/widgets.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/ui/utils/sort_fields.dart';
import 'package:poddr/ui/views/library/collection_filter.dart';

class DownloadsViewModel extends ChangeNotifier {
  final OfflineProvider _offlineProvider;
  final MediaProvider _mediaProvider;
  final CollectionFilter _collectionFilter;

  final TextEditingController filterController = TextEditingController();

  String _filter = '';
  String get filter => _filter;

  OfflineEpisodeSortField _sortField = OfflineEpisodeSortField.downloadedAt;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  Set<int> get selectedCollectionIds => _collectionFilter.collectionIds;

  DownloadsViewModel(this._offlineProvider, this._mediaProvider,
      CollectionsProvider collectionsProvider)
      : _collectionFilter = CollectionFilter(collectionsProvider) {
    _offlineProvider.addListener(notifyListeners);
    _collectionFilter.addListener(notifyListeners);
  }

  List<OfflineEpisode> get downloads {
    final downloads = _offlineProvider.downloads
        .where((d) => _collectionFilter.includes(d.podcastRSS))
        .toList();

    return filterAndSortOfflineEpisodes(
      episodes: downloads,
      filter: _filter,
      sortField: _sortField,
      sortDirection: _sortDirection,
    );
  }

  bool get isLoading => _offlineProvider.isLoading;

  Future<bool> loadMedia({
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
    return _mediaProvider.loadMedia(
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

  PodcastEpisode toPodcastEpisode(OfflineEpisode data) {
    return _offlineProvider.toPodcastEpisode(data);
  }

  Future<bool> remove(String audioUrl) => _offlineProvider.remove(audioUrl);

  Future<bool> clearAllDownloads() => _offlineProvider.clearAll();

  String? get lastError => _offlineProvider.lastError;
  String? get playbackError => _mediaProvider.lastError;

  void setFilter(String value) {
    _filter = value;
    if (filterController.text != value) {
      filterController.text = value;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _offlineProvider.removeListener(notifyListeners);
    _collectionFilter.dispose();
    filterController.dispose();
    super.dispose();
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
    _collectionFilter.update(ids);
  }
}
