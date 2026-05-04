import 'dart:developer';
import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:poddr/models/podcast.dart';
import 'package:poddr/data/parsers/podcast_parser.dart';

// Top-level function for isolate usage
Podcast _parsePodcastFeed(String xmlString, String rssUrl) {
  return PoddrPodcastParser.parse(xmlString, rssUrl);
}

abstract class IPodcastRepository {
  Future<List<Podcast>> search(String query);
  Future<List<Podcast>> getCharts(String country, String genre);
  Future<Podcast> getFeed(String rss);
}

class ITunesPodcastRepository implements IPodcastRepository {
  final String logName = "ItunesPodcastRepository";
  final String baseUrl = "https://itunes.apple.com";
  final http.Client _http = http.Client();
  final Map<String, _CachedFeed> _feedCache = {};

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
          for (var result in results) {
            final Podcast feed = Podcast(
              rss: result['feedUrl'],
              title: result['trackName'] ?? result['trackCensoredName'],
              image: result['artworkUrl600'] ?? result['artworkUrl100'],
              author: result['artistName'],
            );
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

      final cached = _feedCache[rss];
      if (cached != null && !cached.isExpired) {
        log("Using cached feed for $rss", name: logName);
        return await Isolate.run(() => _parsePodcastFeed(cached.content, rss));
      }

      final headers = <String, String>{};
      if (cached?.etag != null) {
        headers['If-None-Match'] = cached!.etag!;
      }
      if (cached?.lastModified != null) {
        headers['If-Modified-Since'] = cached!.lastModified!;
      }

      final response = await _http.get(Uri.parse(rss), headers: headers);
      log("Feed return code ${response.statusCode}", name: logName);

      if (response.statusCode == 304) {
        log("Feed not modified (304), using cache for $rss", name: logName);
        if (cached != null) {
          return await Isolate.run(() => _parsePodcastFeed(cached.content, rss));
        }
      }

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);

        _feedCache[rss] = _CachedFeed(
          content: content,
          cachedAt: DateTime.now(),
          etag: response.headers['etag'],
          lastModified: response.headers['last-modified'],
        );

        return await Isolate.run(() => _parsePodcastFeed(content, rss));
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

class _CachedFeed {
  final String content;
  final DateTime cachedAt;
  final String? etag;
  final String? lastModified;

  _CachedFeed({
    required this.content,
    required this.cachedAt,
    this.etag,
    this.lastModified,
  });

  bool get isExpired => DateTime.now().difference(cachedAt).inHours >= 1;
}
