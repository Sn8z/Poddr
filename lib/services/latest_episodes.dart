import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/services/subscriptions.dart';

class LatestEpisodesProvider extends ChangeNotifier {
  final String logName = "LatestEpisodesProvider";

  final SubscriptionProvider _subscriptionProvider;

  final IPodcastRepository _podcastRepository = ITunesPodcastRepository();

  List<PodcastEpisode> _episodes = [];
  List<PodcastEpisode> get episodes => _episodes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LatestEpisodesProvider(this._subscriptionProvider) {
    _subscriptionProvider.addListener(_handleSubscriptionChange);
    fetchNewEpisodes();
  }

  void _handleSubscriptionChange() {
    fetchNewEpisodes();
  }

  Future<void> fetchNewEpisodes() async {
    setLoading(true);

    try {
      final List<Podcast> subscriptions = _subscriptionProvider.subscriptions;
      final List<PodcastEpisode> episodes = [];

      for (final Podcast podcast in subscriptions) {
        final Podcast fullPodcast =
            await _podcastRepository.getFeed(podcast.rss!);

        final List<PodcastEpisode> podcastEpisodes = fullPodcast.episodes;

        episodes.addAll(podcastEpisodes);
      }

      episodes.sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));

      _episodes = episodes.take(100).toList();
      notifyListeners();
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
