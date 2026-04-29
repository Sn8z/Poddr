import 'package:flutter/material.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/offline_episode.dart';

class DownloadsViewModel extends ChangeNotifier {
  final OfflineProvider _offlineProvider;
  final MediaProvider _mediaProvider;

  DownloadsViewModel(this._offlineProvider, this._mediaProvider) {
    _offlineProvider.addListener(notifyListeners);
  }

  List<OfflineEpisode> get downloads => _offlineProvider.downloads;
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
  }) {
    _mediaProvider.loadMedia(
      audioUrl: audioUrl,
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

  @override
  void dispose() {
    _offlineProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
