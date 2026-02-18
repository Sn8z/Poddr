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

    for (final rss in toAdd) {
      try {
        final fullPodcast = await _podcastRepository.getFeed(rss);

        final newEpisodes = fullPodcast.episodes;

        _episodes.addAll(newEpisodes);
        _loadedFeeds.add(rss);
      } catch (e, st) {
        log("Failed to fetch $rss", name: logName, error: e, stackTrace: st);
      }
    }

    _sortAndLimit();

    _isLoading = false;
    notifyListeners();
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
