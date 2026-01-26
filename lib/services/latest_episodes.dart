import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';

class LatestEpisodesProvider extends ChangeNotifier {
  final String logName = "LatestEpisodesProvider";
  final IPodcastRepository _podcastRepository;

  SubscriptionProvider? _subscriptionProvider;
  List<String>? _lastSubscriptionRss;
  static const int _maxEpisodes = 100;

  List<PodcastEpisode> _episodes = [];
  List<PodcastEpisode> get episodes => _episodes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LatestEpisodesProvider({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository();

  void update(SubscriptionProvider subscriptionProvider) {
    _subscriptionProvider = subscriptionProvider;

    final currentRssUrls = _subscriptionProvider!.subscriptions
        .where((p) => p.rss != null)
        .map((p) => p.rss!)
        .toList()
      ..sort();

    final lastRss = _lastSubscriptionRss?..sort();

    if (_lastSubscriptionRss == null ||
        !_listsEqual(currentRssUrls, lastRss!)) {
      log("Subscription list changed, refreshing episodes", name: logName);
      _lastSubscriptionRss = currentRssUrls;
      _getNewEpisodes();
    } else {
      log("Subscription list unchanged, skipping refresh", name: logName);
    }
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _getNewEpisodes() async {
    if (_subscriptionProvider == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final List<Podcast> subscriptions = _subscriptionProvider!.subscriptions;
      log("Fetching episodes for ${subscriptions.length} subscriptions",
          name: logName);

      final futures = <Future<Podcast>>[];
      for (final podcast in subscriptions) {
        if (podcast.rss == null) continue;

        futures.add(
          _podcastRepository
              .getFeed(podcast.rss!)
              .catchError((error, stackTrace) {
            log(
              "Error fetching episodes for ${podcast.rss}",
              name: logName,
              error: error,
              stackTrace: stackTrace,
            );

            return Podcast(
              title: podcast.title,
              rss: podcast.rss,
              author: podcast.author,
              image: podcast.image,
              description: podcast.description,
              episodes: [],
            );
          }),
        );
      }

      final results = await Future.wait(futures);
      log("Fetched ${results.length} podcast feeds in parallel", name: logName);

      _episodes = _processAndSortEpisodes(results);

      log("Total episodes processed: ${_episodes.length}", name: logName);
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PodcastEpisode> _processAndSortEpisodes(List<Podcast> podcasts) {
    log("Processing episodes from ${podcasts.length} podcasts", name: logName);

    final allEpisodes = <PodcastEpisode>[];
    for (final podcast in podcasts) {
      for (final episode in podcast.episodes) {
        if (episode.publicationDate != null) {
          allEpisodes.add(episode);
        }
      }
    }

    log("Found ${allEpisodes.length} valid episodes", name: logName);

    allEpisodes
        .sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));

    return allEpisodes.take(_maxEpisodes).toList();
  }

  Future<void> refresh() async {
    await _getNewEpisodes();
  }
}
