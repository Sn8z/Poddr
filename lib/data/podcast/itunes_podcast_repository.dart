import 'dart:convert';
import 'dart:isolate';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/data/parsers/podcast_parser.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class ITunesPodcastRepository implements IPodcastRepository {
  final String logName = "ItunesPodcastRepository";
  final String baseUrl = "https://itunes.apple.com";
  final PoddrHttpClient _http = PoddrHttpClient();

  @override
  Future<List<Podcast>> search(String query) async {
    try {
      final searchUrl = "$baseUrl/search?term=$query&media=podcast";
      debug("Searching for $searchUrl", name: logName);
      final response = await _http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final feeds = <Podcast>[];
        for (var item in data['results']) {
          final Podcast feed = Podcast(
            rss: item['feedUrl'],
            title: item['trackName'] ?? item['trackCensoredName'],
            image: item['artworkUrl600'] ?? item['artworkUrl100'],
            author: item['artistName'],
          );
          feeds.add(feed);
        }
        return feeds;
      } else {
        throw ApiException("Search return code ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Podcast>> getCharts(String country, String genre) async {
    try {
      final chartsUrl =
          "$baseUrl/$country/rss/toppodcasts/limit=50/explicit=true/genre=$genre/json";
      debug("Checking charts for $chartsUrl", name: logName);
      final response = await _http.get(Uri.parse(chartsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final entries = data['feed']?['entry'] as List<dynamic>?;
        if (entries == null || entries.isEmpty) return [];

        final ids = entries
            .map((e) => e['id']?['attributes']?['im:id'])
            .where((id) => id != null)
            .join(',');

        final lookupUrl = "$baseUrl/lookup?id=$ids&entity=podcast";
        final lookupResponse = await _http.get(Uri.parse(lookupUrl));

        if (lookupResponse.statusCode == 200) {
          final lookupData = json.decode(lookupResponse.body);
          final results = lookupData['results'] as List<dynamic>?;
          if (results == null) return [];
          final feeds = <Podcast>[];
          for (var result in results) {
            final Podcast feed = Podcast(
              rss: result['feedUrl'],
              title: result['trackName'] ?? result['trackCensoredName'],
              image: result['artworkUrl600'] ?? result['artworkUrl100'],
              author: result['artistName'],
            );
            feeds.add(feed);
          }
          return feeds;
        } else {
          throw ApiException("Could not get lookup");
        }
      } else {
        throw ApiException("Could not get charts");
      }
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Podcast> getFeed(String rss) async {
    try {
      debug("Getting feed $rss", name: logName);

      final response = await _http.get(Uri.parse(rss));
      debug("Feed return code ${response.statusCode}", name: logName);

      if (response.statusCode == 200) {
        final content = response.body;
        return await Isolate.run(() => PoddrPodcastParser.parse(content, rss));
      } else {
        error("Feed return code ${response.statusCode}", name: logName);
        throw ApiException("Could not get feed");
      }
    } catch (e, stackTrace) {
      error(e.toString(), name: logName, error: e, stackTrace: stackTrace);
      if (e is ApiException) rethrow;
      throw ApiException("Something went wrong when getting the feed");
    }
  }
}
