import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/http_client.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/data/parsers/podcast_parser.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/models/podcast.dart';

class ITunesPodcastRepository implements IPodcastRepository {
  static const int maxFeedBytes = 5 * 1024 * 1024;
  static const String _host = 'itunes.apple.com';
  static const String _defaultCountry = 'us';
  final String logName = "ItunesPodcastRepository";
  final PoddrHttpClient _http = PoddrHttpClient.shared;

  Never _throwForStatus(int statusCode, String action) {
    if (statusCode == 404) {
      throw NotFoundException('$action: resource not found');
    }
    if (statusCode == 408 || statusCode == 429 || statusCode >= 500) {
      throw ServerErrorException(
        statusCode,
        '$action failed with status $statusCode',
      );
    }
    throw ApiException(
      '$action failed with status $statusCode',
      userMessage: 'The podcast service rejected the request. '
          'Please try again.',
    );
  }

  @override
  Future<List<Podcast>> search(String query) async {
    final searchUrl = Uri.https(_host, '/search', {
      'term': query,
      'media': 'podcast',
    });
    debug("Searching for $searchUrl", name: logName);

    final response = await _http.get(searchUrl);
    if (response.statusCode != 200) {
      _throwForStatus(response.statusCode, 'Search');
    }

    try {
      final data = json.decode(response.body);
      return (data['results'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .where((item) => _hasFeedUrl(item))
          .map((item) => _podcastFromSearchResult(item))
          .toList();
    } catch (e) {
      throw ApiException(
        'Could not parse search response: $e',
        userMessage: 'Search results could not be read. Please try again.',
      );
    }
  }

  @override
  Future<List<Podcast>> getCharts(String country, String genre) async {
    final resolvedCountry =
        country.trim().isEmpty ? _defaultCountry : country.trim();
    final resolvedGenre = genre.trim();
    final chartsUrl = Uri(
      scheme: 'https',
      host: _host,
      pathSegments: [
        resolvedCountry,
        'rss',
        'toppodcasts',
        'limit=50',
        'explicit=true',
        if (resolvedGenre.isNotEmpty) 'genre=$resolvedGenre',
        'json',
      ],
    );
    debug("Checking charts for $chartsUrl", name: logName);

    final response = await _http.get(chartsUrl);
    if (response.statusCode != 200) {
      _throwForStatus(response.statusCode, 'Charts');
    }

    try {
      final data = json.decode(response.body);
      final entries = data['feed']?['entry'] as List<dynamic>?;
      if (entries == null || entries.isEmpty) return [];

      final ids = entries
          .map((e) => e['id']?['attributes']?['im:id'])
          .where((id) => id != null)
          .join(',');

      final lookupUrl = Uri.https(_host, '/lookup', {
        'id': ids,
        'entity': 'podcast',
      });
      final lookupResponse = await _http.get(lookupUrl);

      if (lookupResponse.statusCode != 200) {
        _throwForStatus(lookupResponse.statusCode, 'Charts lookup');
      }

      final lookupData = json.decode(lookupResponse.body);
      final results = lookupData['results'] as List<dynamic>?;
      if (results == null) return [];

      return results
          .whereType<Map<String, dynamic>>()
          .where((result) => _hasFeedUrl(result))
          .map((result) => _podcastFromSearchResult(result))
          .toList();
    } catch (e) {
      if (e is PoddrException) rethrow;
      throw ApiException(
        'Could not parse charts response: $e',
        userMessage: 'Charts could not be loaded. Please try again.',
      );
    }
  }

  static bool _hasFeedUrl(Map<String, dynamic> item) {
    final feedUrl = item['feedUrl'] as String?;
    return feedUrl != null && feedUrl.trim().isNotEmpty;
  }

  static Podcast _podcastFromSearchResult(Map<String, dynamic> item) {
    return Podcast(
      rss: item['feedUrl'],
      title: item['trackName'] ?? item['trackCensoredName'],
      image: item['artworkUrl600'] ?? item['artworkUrl100'],
      author: item['artistName'],
    );
  }

  @override
  Future<Podcast> getFeed(String rss) async {
    debug("Getting feed $rss", name: logName);

    final response = await _http.get(Uri.parse(rss));
    debug("Feed return code ${response.statusCode}", name: logName);

    if (response.statusCode != 200) {
      _throwForStatus(response.statusCode, 'Feed $rss');
    }

    final feedSize = response.contentLength ?? response.bodyBytes.length;
    if (feedSize > maxFeedBytes) {
      debug('Rejected $rss with $feedSize bytes', name: logName);
      throw ApiException(
        'Feed too large ($feedSize bytes): $rss',
        userMessage: 'This podcast feed is too large to load.',
      );
    }

    try {
      final content = response.body;
      return await compute((_) => PoddrPodcastParser.parse(content, rss), null);
    } catch (e) {
      if (e is PoddrException) rethrow;
      throw ApiException(
        'Could not parse feed $rss: $e',
        userMessage: 'This podcast feed could not be read.',
      );
    }
  }
}
