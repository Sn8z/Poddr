import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/podcast/itunes_podcast_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/data/sync/sync_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const String logName = "SubscriptionProvider";

  final IPodcastRepository _podcastRepository;
  final ISubscriptionRepository _subscriptionRepository;
  final ISyncRepository _syncRepository;

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  Map<String, int> _subscriptionIdByRss = {};
  Map<String, int> get subscriptionIdByRss => _subscriptionIdByRss;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const int _maxEpisodes = 50;
  List<PodcastEpisode> _latestEpisodes = [];
  List<PodcastEpisode> get latestEpisodes => _latestEpisodes;

  Set<String> _loadedFeeds = {};
  bool _isLoadingLatest = false;
  bool get isLoadingLatest => _isLoadingLatest;

  SubscriptionProvider({
    IPodcastRepository? podcastRepository,
    ISubscriptionRepository? subscriptionRepository,
    ISyncRepository? syncRepository,
  })  : _podcastRepository = podcastRepository ?? ITunesPodcastRepository(),
        _subscriptionRepository =
            subscriptionRepository ?? DriftSubscriptionRepository(),
        _syncRepository = syncRepository ?? DriftSyncRepository() {
    _getSubscriptions();
  }

  Future<void> _getSubscriptions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _subscriptions = await _subscriptionRepository.getSubscriptions();
      _subscriptionIdByRss =
          await _subscriptionRepository.getAllSubscriptionIds();
      await _updateLatestEpisodes();
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubscription({
    required String rss,
    bool fromSync = false,
  }) async {
    try {
      final Podcast podcast = await _podcastRepository.getFeed(rss);

      await _subscriptionRepository.addSubscription(
        podcast.title,
        rss,
        podcast.description,
        podcast.author,
        podcast.image,
      );

      if (!fromSync) {
        await _syncRepository.addPendingSubscriptionAction(rss, 'add');
      }

      await _getSubscriptions();
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    } finally {
      info("Added subscription $rss", name: logName);
    }
  }

  Future<bool> addSubscriptionSilent({
    required String rss,
    bool fromSync = false,
  }) async {
    try {
      final Podcast podcast = await _podcastRepository.getFeed(rss);

      return await addSubscriptionDirect(
        rss: rss,
        title: podcast.title,
        description: podcast.description,
        author: podcast.author,
        image: podcast.image,
        fromSync: fromSync,
      );
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> addSubscriptionDirect({
    required String rss,
    String? title,
    String? description,
    String? author,
    String? image,
    bool fromSync = false,
  }) async {
    try {
      await _subscriptionRepository.addSubscription(
        title ?? '',
        rss,
        description ?? '',
        author ?? '',
        image ?? '',
      );

      if (!fromSync) {
        await _syncRepository.addPendingSubscriptionAction(rss, 'add');
      }

      await _getSubscriptions();
      return true;
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> refresh() async {
    await _getSubscriptions();
  }

  Future<int?> getSubscriptionId(String rss) async {
    return await _subscriptionRepository.getSubscriptionIdByRss(rss);
  }

  Stream<int?> watchSubscriptionId(String rss) {
    return _subscriptionRepository.watchSubscriptionIdByRss(rss);
  }

  Future<void> removeSubscription(String rss, {bool fromSync = false}) async {
    try {
      info("Removing $rss", name: logName);

      await _subscriptionRepository.removeSubscription(rss);

      if (!fromSync) {
        await _syncRepository.addPendingSubscriptionAction(rss, 'remove');
      }

      await _getSubscriptions();
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
    } finally {
      info("Finished removing $rss", name: logName);
    }
  }

  Future<void> _updateLatestEpisodes() async {
    final newSubs = _subscriptions;
    final newRssSet = newSubs.map((p) => p.rss).whereType<String>().toSet();

    if (newRssSet.isEmpty && _loadedFeeds.isNotEmpty) {
      _latestEpisodes = [];
      _loadedFeeds = {};
      notifyListeners();
      return;
    }

    final added = newRssSet.difference(_loadedFeeds);
    final removed = _loadedFeeds.difference(newRssSet);

    if (added.isEmpty && removed.isEmpty) return;

    _isLoadingLatest = true;
    notifyListeners();

    if (removed.isNotEmpty) {
      _latestEpisodes.removeWhere((ep) => removed.contains(ep.podcastRSS));
      _loadedFeeds.removeAll(removed);
    }

    final results = await Future.wait(
      added.map((rss) => _fetchFeed(rss)),
    );

    for (final result in results) {
      if (result != null) {
        _latestEpisodes.addAll(result.episodes);
        _loadedFeeds.add(result.rss);
      }
    }

    _sortAndLimit();

    _isLoadingLatest = false;
    notifyListeners();
  }

  Future<_FeedResult?> _fetchFeed(String rss) async {
    try {
      final fullPodcast = await _podcastRepository.getFeed(rss);

      String effectiveRss = rss;
      final newFeedUrl = fullPodcast.newFeedUrl;

      await _subscriptionRepository.updateSubscription(
        rss: rss,
        title: fullPodcast.title,
        description: fullPodcast.description,
        author: fullPodcast.author,
        imageUrl: fullPodcast.image,
        newRss: (newFeedUrl != null && newFeedUrl != rss) ? newFeedUrl : null,
      );

      if (newFeedUrl != null && newFeedUrl != rss) {
        effectiveRss = newFeedUrl;
      }

      return _FeedResult(effectiveRss, fullPodcast.episodes);
    } catch (e, st) {
      error("Failed to fetch $rss", name: logName, error: e, stackTrace: st);
      await _subscriptionRepository.markAsBroken(rss);
      return null;
    }
  }

  void _sortAndLimit() {
    _latestEpisodes.sort((a, b) {
      final dateA = a.publicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.publicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    if (_latestEpisodes.length > _maxEpisodes) {
      _latestEpisodes = _latestEpisodes.take(_maxEpisodes).toList();
    }
  }
}

class _FeedResult {
  final String rss;
  final List<PodcastEpisode> episodes;
  _FeedResult(this.rss, this.episodes);
}
