import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poddr/models/podcast.dart';

abstract class IPodcastRepository {
  Future<List<Podcast>> search(String query);
  Future<List<Podcast>> getCharts(String country, String genre);
  Future<Podcast> getFeed(String rss);
}

class ITunesPodcastRepository implements IPodcastRepository {
  final String logName = "ItunesPodcastRepository";
  final String baseUrl = "https://itunes.apple.com";
  final http.Client _http = http.Client();

  ITunesPodcastRepository();

  @override
  Future<List<Podcast>> search(String query) async {
    final List<Podcast> feeds = [];
    try {
      final searchUrl = "$baseUrl/search?term=$query&media=podcast";
      log("Searching for $searchUrl", name: logName);
      final response = await _http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (var item in data['results']) {
          final feed = Podcast.fromItunes(item);
          feeds.add(feed);
        }
        return feeds;
      } else {
        throw Exception("Search return code ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<Podcast>> getCharts(String country, String genre) async {
    final List<Podcast> feeds = [];
    try {
      final chartsUrl =
          "$baseUrl/$country/rss/toppodcasts/limit=50/explicit=true/genre=$genre/json";
      log("Checking charts for $chartsUrl", name: logName);
      final response = await _http.get(Uri.parse(chartsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final entries = data['feed']?['entry'] as List<dynamic>?;

        if (entries == null) return [];

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
          for (var result in results) {
            final feed = Podcast.fromItunes(result);
            feeds.add(feed);
          }
        } else {
          throw Exception("Could not get lookup");
        }
        return feeds;
      } else {
        throw Exception("Could not get charts");
      }
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<Podcast> getFeed(String rss) async {
    try {
      log("Getting feed $rss", name: logName);
      final response = await _http.get(Uri.parse(rss));
      log("Feed return code ${response.statusCode}", name: logName);
      if (response.statusCode == 200) {
        return Podcast.fromXml(response.body);
      } else {
        log("Feed return code ${response.statusCode}", name: logName);
        throw Exception("Could not get feed");
      }
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception("Something went wrong when getting the feed");
    }
  }
}
