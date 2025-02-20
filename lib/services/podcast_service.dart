import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/podcast.dart';

class PodcastService {
  final String baseUrl = "https://itunes.apple.com";
  final http.Client _http = http.Client();

  PodcastService();

  Future<List<PodcastFeed>> search(String query) async {
    final List<PodcastFeed> feeds = [];
    try {
      final searchUrl = "$baseUrl/search?term=$query&media=podcast";
      debugPrint("Searching for $searchUrl");
      final response = await _http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (var item in data['results']) {
          final feed = PodcastFeed.fromItunes(item);
          feeds.add(feed);
        }
        return feeds;
      } else {
        throw Exception("Search return code ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Could not search");
    }
  }

  Future<List<PodcastFeed>> getCharts(String country, String genre) async {
    final List<PodcastFeed> feeds = [];
    try {
      final chartsUrl =
          "$baseUrl/$country/rss/toppodcasts/limit=50/explicit=true/genre=$genre/json";
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
            final feed = PodcastFeed.fromItunes(result);
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
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Could not get charts");
    }
  }

  Future<PodcastFeed> getFeed(String rss) async {
    try {
      debugPrint("Getting feed $rss");
      final response = await _http.get(Uri.parse(rss));
      debugPrint("Feed return code ${response.statusCode}");
      if (response.statusCode == 200) {
        return PodcastFeed.fromXml(response.body);
      } else {
        debugPrint("Feed return code ${response.statusCode}");
        throw Exception("Could not get feed");
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      throw Exception("Something went wrong when getting the feed");
    }
  }
}
