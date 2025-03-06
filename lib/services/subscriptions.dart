import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/subscriptions/drift/drift_subscription_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ISubscriptionRepository _subscriptionRepository =
      DriftSubscriptionRepository();

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider() {
    initStream();
  }

  void initStream() async {
    _setLoading(true);
    await _fetchFavourites();
    _setLoading(false);
  }

  Future<void> _fetchFavourites() async {
    try {
      _subscriptions = await _subscriptionRepository.getSubscriptions();
      notifyListeners();
    } catch (error) {
      debugPrint("Error fetching favourites: $error");
    }
  }

  Future<void> addFavourite({
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
      await _fetchFavourites();
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      debugPrint("Finished inserting favourite");
    }
  }

  Future<void> removeFavourite(String rss) async {
    try {
      debugPrint("Removing favourite with rss $rss");
      await _subscriptionRepository.removeSubscription(rss);
      await _fetchFavourites();
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    } finally {
      debugPrint("Finished removing favourite");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
