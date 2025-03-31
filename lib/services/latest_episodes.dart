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

      episodes.sort((a, b) => b.publicationDate!.compareTo(a.publicationDate!));

      _episodes = episodes.take(100).toList();
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionProvider.removeListener(_handleSubscriptionChange);
    super.dispose();
  }
}
