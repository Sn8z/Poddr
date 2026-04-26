import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/data/sync/sync_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final IPodcastRepository _podcastRepository;
  final ISubscriptionRepository _subscriptionRepository;
  final ISyncRepository _syncRepository;

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      log("Added subscription $rss", name: logName);
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
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
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
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
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
      log("Removing $rss", name: logName);

      await _subscriptionRepository.removeSubscription(rss);

      if (!fromSync) {
        await _syncRepository.addPendingSubscriptionAction(rss, 'remove');
      }

      await _getSubscriptions();
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      log("Finished removing $rss", name: logName);
    }
  }
}
