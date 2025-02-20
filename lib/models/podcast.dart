import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';
import 'episode.dart';

class PodcastFeed {
  final String? title;
  final String? description;
  final String? image;
  final String? author;
  final String? rss;
  final String? link;
  final String? language;
  final String? copyright;
  final bool explicit;
  final List<String> tags;
  final List<PodcastEpisode> episodes;

  PodcastFeed({
    this.title,
    this.description,
    this.image,
    this.author,
    this.rss,
    this.link,
    this.language,
    this.copyright,
    this.explicit = false,
    this.tags = const [],
    this.episodes = const [],
  });

  factory PodcastFeed.fromXml(String rss) {
    final xml = XmlDocument.parse(rss);
    final channel = xml.findAllElements('channel').firstOrNull;
    if (channel == null) throw Exception("Invalid RSS");

    //TODO: create a function that returns imageURL
    final imagee = channel
        .findElements('image')
        .firstOrNull
        ?.findElements('url')
        .firstOrNull
        ?.innerText;

    final imageee =
        channel.findElements('itunes:image').firstOrNull?.getAttribute('href');

    final image = imagee ?? imageee;

    final feed = PodcastFeed(
      title: channel.findElements('title').firstOrNull?.innerText,
      description: channel.findElements('description').firstOrNull?.innerText,
      image: image,
      author: channel.findElements('author').firstOrNull?.innerText,
      link: channel.findElements('link').firstOrNull?.innerText,
      language: channel.findElements('language').firstOrNull?.innerText,
      copyright: channel.findElements('copyright').firstOrNull?.innerText,
      explicit: _parseExplicit(
          channel.findElements('itunes:explicit').firstOrNull?.innerText),
      rss: channel.findElements('atom:link').firstOrNull?.getAttribute('href'),
      tags: [],
      episodes: channel
          .findElements('item')
          .map((e) => PodcastEpisode.fromXml(e, image))
          .toList(),
    );

    return feed;
  }

  factory PodcastFeed.fromItunes(Map<String, dynamic> data) {
    return PodcastFeed(
      title: data['collectionName'] ?? 'Missing name',
      description: data['collectionDescription'],
      image: data['artworkUrl600'],
      author: data['author'],
      link: data['feedUrl'],
      language: data['language'],
      copyright: data['copyright'],
      explicit: _parseExplicit(data['explicit']),
      rss: data['feedUrl'],
      tags: [data['primaryGenreName'] ?? ''],
      episodes:
          data['episodes']?.map((e) => PodcastEpisode.fromItunes(e)).toList() ??
              [],
    );
  }

  static bool _parseExplicit(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final strValue = value.toString().toLowerCase();
    return strValue == 'true' || strValue == 'yes' || strValue == 'explicit';
  }
}
