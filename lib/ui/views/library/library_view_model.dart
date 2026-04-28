import 'package:flutter/material.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';

class LibraryViewModel extends ChangeNotifier {
  final SubscriptionProvider _subscriptionProvider;

  LibraryViewModel(this._subscriptionProvider);

  List<Podcast> get subscriptions => _subscriptionProvider.subscriptions;
  bool get isLoading => _subscriptionProvider.isLoading;

  Future<void> addSubscription({required String rss}) async {
    await _subscriptionProvider.addSubscription(rss: rss);
  }
}
