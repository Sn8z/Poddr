import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final IPodcastRepository _podcastRepository;
  final ISubscriptionRepository _subscriptionRepository;

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider(
      {IPodcastRepository? podcastRepository,
      ISubscriptionRepository? subscriptionRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository(),
        _subscriptionRepository =
            subscriptionRepository ?? DriftSubscriptionRepository();

  Future<void> _getSubscriptions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _subscriptions =
          await _subscriptionRepository.getSubscriptions();
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

  Future<void> removeSubscription(String rss) async {
    try {
      log("Removing $rss", name: logName);
      await _subscriptionRepository.removeSubscription(rss);
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
