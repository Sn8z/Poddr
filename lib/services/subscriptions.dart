import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/profile.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final IPodcastRepository _podcastRepository;
  final ISubscriptionRepository _subscriptionRepository;

  ProfileProvider? _profileProvider;
  int? _currentProfileId;

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

  void update(ProfileProvider? profileProvider) {
    _profileProvider = profileProvider;

    final newId = _profileProvider?.currentProfile?.id;

    if (newId != _currentProfileId) {
      _currentProfileId = newId;

      if (newId != null) {
        _getSubscriptions();
      } else {
        _subscriptions = [];
        notifyListeners();
      }
    }
  }

  Future<void> _getSubscriptions() async {
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _subscriptions =
          await _subscriptionRepository.getSubscriptions(profileId);
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
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      final Podcast podcast = await _podcastRepository.getFeed(rss);

      await _subscriptionRepository.addSubscription(
        podcast.title,
        rss,
        podcast.description,
        podcast.author,
        podcast.image,
        profileId,
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
    final profileId = _currentProfileId;
    if (profileId == null) return false;

    try {
      final Podcast podcast = await _podcastRepository.getFeed(rss);

      await _subscriptionRepository.addSubscription(
        podcast.title,
        rss,
        podcast.description,
        podcast.author,
        podcast.image,
        profileId,
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
    final profileId = _currentProfileId;
    if (profileId == null) return;

    try {
      log("Removing $rss", name: logName);
      await _subscriptionRepository.removeSubscription(profileId, rss);
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
