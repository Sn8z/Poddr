import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/subscriptions/subscriptions_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/data/sync/sync_repository.dart';
import 'package:poddr/data/tags/drift_tags_repository.dart';
import 'package:poddr/data/tags/tags_repository.dart';
import 'package:poddr/models/podcast.dart';

class SubscriptionProvider extends ChangeNotifier {
  final String logName = "SubscriptionProvider";
  final IPodcastRepository _podcastRepository;
  final ISubscriptionRepository _subscriptionRepository;
  final ISyncRepository _syncRepository;
  final ITagsRepository _tagsRepository;

  List<Podcast> _subscriptions = [];
  List<Podcast> get subscriptions => _subscriptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider({
    IPodcastRepository? podcastRepository,
    ISubscriptionRepository? subscriptionRepository,
    ISyncRepository? syncRepository,
    ITagsRepository? tagsRepository,
  })  : _podcastRepository = podcastRepository ?? ITunesPodcastRepository(),
        _subscriptionRepository =
            subscriptionRepository ?? DriftSubscriptionRepository(),
        _syncRepository = syncRepository ?? DriftSyncRepository(),
        _tagsRepository = tagsRepository ?? DriftTagsRepository() {
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

      final subscriptionId = await _subscriptionRepository.addSubscription(
        podcast.title,
        rss,
        podcast.description,
        podcast.author,
        podcast.image,
      );

      for (final genre in podcast.tags) {
        if (genre.isNotEmpty) {
          final tag = await _tagsRepository.getOrCreate(genre);
          await _tagsRepository.linkTagToSubscription(tag.id, subscriptionId);
        }
      }

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
        tags: podcast.tags,
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
    List<String>? tags,
    bool fromSync = false,
  }) async {
    try {
      final subscriptionId = await _subscriptionRepository.addSubscription(
        title ?? '',
        rss,
        description ?? '',
        author ?? '',
        image ?? '',
      );

      if (tags != null) {
        for (final genre in tags) {
          if (genre.isNotEmpty) {
            final tag = await _tagsRepository.getOrCreate(genre);
            await _tagsRepository.linkTagToSubscription(tag.id, subscriptionId);
          }
        }
      }

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

  Future<void> removeSubscription(String rss, {bool fromSync = false}) async {
    try {
      log("Removing $rss", name: logName);
      final subscriptionId =
          await _subscriptionRepository.getSubscriptionIdByRss(rss);
      if (subscriptionId != null) {
        final tags =
            await _tagsRepository.getTagsForSubscription(subscriptionId);
        for (final tag in tags) {
          await _tagsRepository.unlinkTagFromSubscription(
              tag.id, subscriptionId);
        }
      }
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
