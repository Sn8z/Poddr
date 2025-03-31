import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final ISubscriptionRepository _subscriptionRepository =
      DriftSubscriptionRepository();
  final IPodcastRepository _podcastRepository = ITunesPodcastRepository();

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider() {
    _setLoading(true);
    _fetchSubscriptions();
    _setLoading(false);
  }

  Future<void> _fetchSubscriptions() async {
    try {
      _subscriptions = await _subscriptionRepository.getSubscriptions();
      notifyListeners();
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
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
      await _fetchSubscriptions();
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

  Future<void> removeSubscription(String rss) async {
    try {
      log("Removing $rss", name: logName);
      await _subscriptionRepository.removeSubscription(rss);
      await _fetchSubscriptions();
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
