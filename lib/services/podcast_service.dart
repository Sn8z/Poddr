import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:poddr/utils/itunes_genres.dart';

class PodcastService {
  final Search podcastSearch = Search();

  Future<SearchResult> search(String query) {
    try {
      return podcastSearch.search(
        query,
        explicit: true,
        limit: 30,
      );
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Could not search");
    }
  }

  // TODO: Add proper support for country and genre
  Future<SearchResult> getCharts(String? code, String? genre) async {
    try {
      debugPrint("Country: $code, Genre: $genre");
      return await podcastSearch.charts(
        explicit: true,
        limit: 50,
        country: Country.values.firstWhere(
          (element) => element.code == code,
          orElse: () => Country.unitedStates,
        ),
        genre: podcastGenres
                .firstWhere((element) => element['id'] == genre)['genre'] ??
            "",
      );
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Could not get charts");
    }
  }

  Future<Podcast> getFeed(String rss) {
    try {
      return Podcast.loadFeed(url: rss);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Could not load feed");
    }
  }
}
