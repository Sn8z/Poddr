import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/exceptions.dart';
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

  AsyncState<List<Podcast>> _subscriptionsState = const AsyncLoading();
  AsyncState<List<Podcast>> get subscriptionsState => _subscriptionsState;

  bool get isLoading =>
      _subscriptionsState is AsyncInitial ||
      _subscriptionsState is AsyncLoading;

  static const int _maxEpisodes = 50;
  List<PodcastEpisode> _latestEpisodes = [];
  List<PodcastEpisode> get latestEpisodes => _latestEpisodes;

  Set<String> _loadedFeeds = {};
  final Set<String> _failedFeeds = {};
  Set<String> get failedFeeds => Set.unmodifiable(_failedFeeds);
  int get failedFeedCount => _failedFeeds.length;

  String? _lastError;
  String? get lastError => _lastError;

  bool _isLoadingLatest = false;
  bool get isLoadingLatest => _isLoadingLatest;
  bool _disposed = false;

  StreamSubscription<List<Podcast>>? _watchSubscription;

  SubscriptionProvider({
    IPodcastRepository? podcastRepository,
    ISubscriptionRepository? subscriptionRepository,
    ISyncRepository? syncRepository,
  })  : _podcastRepository = podcastRepository ?? ITunesPodcastRepository(),
        _subscriptionRepository =
            subscriptionRepository ?? DriftSubscriptionRepository(),
        _syncRepository = syncRepository ?? DriftSyncRepository() {
    _listenToSubscriptions();
  }

  void _listenToSubscriptions() {
    _watchSubscription?.cancel();
    _watchSubscription = _subscriptionRepository.watchAllSubscriptions().listen(
      (subs) => unawaited(_onSubscriptionsChanged(subs)),
      onError: (Object e, StackTrace stackTrace) {
        error('Failed to watch subscriptions',
            name: logName, error: e, stackTrace: stackTrace);
        _subscriptionsState = const AsyncError(
          'Your subscriptions could not be loaded. Please try again.',
        );
        _notify();
      },
    );
  }

  Future<void> _onSubscriptionsChanged(List<Podcast> subs) async {
    if (_disposed) return;

    _subscriptions = subs;

    if (_disposed) return;

    _subscriptionsState = AsyncData(subs);
    _notify();

    try {
      await _updateLatestEpisodes();
    } catch (e, stackTrace) {
      error('Failed to update latest episodes',
          name: logName, error: e, stackTrace: stackTrace);
    }
  }

  /// Reloads subscriptions after a read failure.
  Future<void> retrySubscriptions() async {
    if (_disposed) return;
    _subscriptionsState = const AsyncLoading();
    _notify();
    _listenToSubscriptions();
  }

  @override
  void dispose() {
    _disposed = true;
    _watchSubscription?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> addSubscription({
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
        try {
          await _syncRepository.addPendingSubscriptionAction(rss, 'add');
        } catch (e, stackTrace) {
          error('Failed to queue sync action',
              name: logName, error: e, stackTrace: stackTrace);
        }
      }

      info("Added subscription $rss", name: logName);
      _lastError = null;
      await _addFeedEpisodes(rss);
      return true;
    } catch (e, stackTrace) {
      error('Failed to add subscription',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = friendlyErrorMessage(e);
      return false;
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
      error('Failed to add subscription silently',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = friendlyErrorMessage(e);
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
        try {
          await _syncRepository.addPendingSubscriptionAction(rss, 'add');
        } catch (e, stackTrace) {
          error('Failed to queue sync action',
              name: logName, error: e, stackTrace: stackTrace);
        }
      }

      info("Added subscription $rss", name: logName);
      _lastError = null;
      await _addFeedEpisodes(rss);
      return true;
    } catch (e, stackTrace) {
      error('Failed to add subscription directly',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = friendlyErrorMessage(e);
      return false;
    }
  }

  Future<void> refresh({bool force = false}) async {
    if (force) _failedFeeds.clear();
    await _updateLatestEpisodes();
  }

  /// Retries every feed that failed to refresh.
  Future<bool> retryFailedFeeds() async {
    if (_failedFeeds.isEmpty) return true;
    _failedFeeds.clear();
    _lastError = null;

    try {
      await _updateLatestEpisodes();
    } catch (e, stackTrace) {
      error('Failed to retry feeds',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = 'Some feeds could not be refreshed. Please try again.';
      _notify();
      return false;
    }

    if (_failedFeeds.isNotEmpty) {
      _lastError = 'Some feeds could not be refreshed. Please try again.';
      _notify();
      return false;
    }
    return true;
  }

  Future<bool> retryFeed(String rss) async {
    _failedFeeds.remove(rss);
    _loadedFeeds.remove(rss);
    _lastError = null;

    try {
      await _updateLatestEpisodes();
    } catch (e, stackTrace) {
      error('Failed to retry feed $rss',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = 'This feed could not be refreshed. Please try again.';
      _notify();
      return false;
    }

    if (_failedFeeds.contains(rss)) {
      _lastError = 'This feed could not be refreshed. Please try again.';
      _notify();
      return false;
    }
    return true;
  }

  PodcastEpisode? findEpisodeByUrl(String audioUrl) {
    for (final episode in _latestEpisodes) {
      if (episode.audioUrl == audioUrl) return episode;
    }
    return null;
  }

  Future<bool> removeSubscription(String rss, {bool fromSync = false}) async {
    try {
      info("Removing $rss", name: logName);

      await _subscriptionRepository.removeSubscription(rss);

      if (!fromSync) {
        try {
          await _syncRepository.addPendingSubscriptionAction(rss, 'remove');
        } catch (e, stackTrace) {
          error('Failed to queue sync action',
              name: logName, error: e, stackTrace: stackTrace);
        }
      }

      info("Finished removing $rss", name: logName);
      _lastError = null;
      _dropFeedEpisodes(rss);
      return true;
    } catch (e, stackTrace) {
      error('Failed to remove subscription',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = friendlyErrorMessage(e);
      return false;
    }
  }

  bool _isSubscribed(String rss) {
    return _subscriptions.any((sub) => sub.rss == rss || sub.newFeedUrl == rss);
  }

  Future<void> _addFeedEpisodes(String rss) async {
    _loadedFeeds.add(rss);
    final result = await _fetchFeed(rss);
    if (result == null) {
      _loadedFeeds.remove(rss);
      _failedFeeds.add(rss);
      return;
    }
    if (!_isSubscribed(result.rss) && !_isSubscribed(rss)) return;
    _latestEpisodes.addAll(result.episodes);
    _loadedFeeds.add(result.rss);
    _sortAndLimit();
    _notify();
  }

  void _dropFeedEpisodes(String rss) {
    _latestEpisodes.removeWhere((ep) => ep.podcastRSS == rss);
    _loadedFeeds.remove(rss);
    _failedFeeds.remove(rss);
    _notify();
  }

  Future<void> _updateLatestEpisodes() async {
    final newSubs = _subscriptions;
    final newRssSet = newSubs.map((p) => p.rss).whereType<String>().toSet();

    if (newRssSet.isEmpty && _loadedFeeds.isNotEmpty) {
      _latestEpisodes = [];
      _loadedFeeds = {};
      _failedFeeds.clear();
      _notify();
      return;
    }

    final added = newRssSet.difference(_loadedFeeds).difference(_failedFeeds);
    final removed = _loadedFeeds.difference(newRssSet);

    if (added.isEmpty && removed.isEmpty) return;

    _isLoadingLatest = true;
    _notify();

    try {
      if (removed.isNotEmpty) {
        _latestEpisodes.removeWhere((ep) => removed.contains(ep.podcastRSS));
        _loadedFeeds.removeAll(removed);
        _failedFeeds.removeAll(removed);
      }

      for (final rss in added) {
        _loadedFeeds.add(rss);
      }
      final fetched = await Future.wait(
        added.map((rss) async => (rss: rss, result: await _fetchFeed(rss))),
      );

      for (final entry in fetched) {
        final result = entry.result;
        if (result == null) {
          _loadedFeeds.remove(entry.rss);
          _failedFeeds.add(entry.rss);
          continue;
        }
        if (!_isSubscribed(result.rss) && !_isSubscribed(entry.rss)) {
          _loadedFeeds.remove(entry.rss);
          continue;
        }
        _latestEpisodes.addAll(result.episodes);
        _loadedFeeds.add(result.rss);
      }

      _sortAndLimit();
    } finally {
      _isLoadingLatest = false;
      _notify();
    }
  }

  Future<_FeedResult?> _fetchFeed(String rss) async {
    try {
      final fullPodcast = await _podcastRepository.getFeed(rss);

      String effectiveRss = rss;
      final newFeedUrl = fullPodcast.newFeedUrl;

      final known = _subscriptions.where((sub) => sub.rss == rss).firstOrNull;
      if (known == null ||
          known.broken ||
          known.title != fullPodcast.title ||
          known.description != fullPodcast.description ||
          known.author != fullPodcast.author ||
          known.image != fullPodcast.image ||
          (newFeedUrl != null && newFeedUrl != rss)) {
        await _subscriptionRepository.updateSubscription(
          rss: rss,
          title: fullPodcast.title,
          description: fullPodcast.description,
          author: fullPodcast.author,
          imageUrl: fullPodcast.image,
          newRss: (newFeedUrl != null && newFeedUrl != rss) ? newFeedUrl : null,
        );
      }

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
    final seen = <String>{};
    _latestEpisodes =
        _latestEpisodes.where((episode) => seen.add(episode.audioUrl)).toList();

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
