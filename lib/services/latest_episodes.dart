import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';

class LatestEpisodesProvider extends ChangeNotifier {
  final String logName = "LatestEpisodesProvider";

  final IPodcastRepository _podcastRepository;

  SubscriptionProvider? _subscriptionProvider;

  List<PodcastEpisode> _episodes = [];
  List<PodcastEpisode> get episodes => _episodes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LatestEpisodesProvider({IPodcastRepository? podcastRepository})
      : _podcastRepository = podcastRepository ?? ITunesPodcastRepository();

  void update(SubscriptionProvider subscriptionProvider) {
    _subscriptionProvider = subscriptionProvider;
    _getNewEpisodes();
  }

  Future<void> _getNewEpisodes() async {
    if (_subscriptionProvider == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final List<Podcast> subscriptions = _subscriptionProvider!.subscriptions;
      final List<PodcastEpisode> episodes = [];

      for (final Podcast podcast in subscriptions) {
        if (podcast.rss == null) continue;

        try {
          final Podcast fullPodcast =
              await _podcastRepository.getFeed(podcast.rss!);
          episodes.addAll(fullPodcast.episodes);
        } catch (error, stackTrace) {
          log(
            "Error fetching episodes for ${podcast.rss}",
            name: logName,
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      final validEpisodes =
          episodes.where((ep) => ep.publicationDate != null).toList();

      validEpisodes
          .sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));

      _episodes = validEpisodes.take(100).toList();
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
}
