import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final ISubscriptionRepository _subscriptionRepository =
      DriftSubscriptionRepository();

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
    required String title,
    required String rss,
    String? description,
    String? author,
    String? image,
  }) async {
    try {
      await _subscriptionRepository.addSubscription(
        title,
        rss,
        description,
        author,
        image,
      );
      await _fetchSubscriptions();
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      log("Added subscription $title - $rss", name: logName);
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
