import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/subscriptions.dart';

class LatestEpisodesProvider extends ChangeNotifier {
  static const String logName = "LatestEpisodesProvider";
  static const int maxEpisodes = 50;

  final IPodcastRepository _podcastRepository;

  List<PodcastEpisode> _episodes = [];
  List<PodcastEpisode> get episodes => _episodes;

  Set<String> _loadedFeeds = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LatestEpisodesProvider({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository();

  void update(SubscriptionProvider subscriptionProvider) {
    final newSubs = subscriptionProvider.subscriptions;

    final newRssSet = newSubs.map((p) => p.rss).whereType<String>().toSet();

    if (newRssSet.isEmpty && _loadedFeeds.isNotEmpty) {
      _episodes = [];
      _loadedFeeds = {};
      notifyListeners();
      return;
    }

    final added = newRssSet.difference(_loadedFeeds);
    final removed = _loadedFeeds.difference(newRssSet);

    if (added.isEmpty && removed.isEmpty) return;

    _updateEpisodes(added, removed);
  }

  Future<void> _updateEpisodes(Set<String> toAdd, Set<String> toRemove) async {
    _isLoading = true;
    notifyListeners();

    if (toRemove.isNotEmpty) {
      _episodes.removeWhere((ep) => toRemove.contains(ep.podcastRSS));
      _loadedFeeds.removeAll(toRemove);
    }

    final results = await Future.wait(
      toAdd.map((rss) => _fetchFeed(rss)),
    );

    for (final result in results) {
      if (result != null) {
        _episodes.addAll(result.episodes);
        _loadedFeeds.add(result.rss);
      }
    }

    _sortAndLimit();

    _isLoading = false;
    notifyListeners();
  }

  Future<_FeedResult?> _fetchFeed(String rss) async {
    try {
      final fullPodcast = await _podcastRepository.getFeed(rss);
      return _FeedResult(rss, fullPodcast.episodes);
    } catch (e, st) {
      log("Failed to fetch $rss", name: logName, error: e, stackTrace: st);
      return null;
    }
  }

  void _sortAndLimit() {
    _episodes.sort((a, b) {
      final dateA = a.publicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.publicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    if (_episodes.length > maxEpisodes) {
      _episodes = _episodes.take(maxEpisodes).toList();
    }
  }
}

class _FeedResult {
  final String rss;
  final List<PodcastEpisode> episodes;
  _FeedResult(this.rss, this.episodes);
}
