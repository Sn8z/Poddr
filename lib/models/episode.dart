import 'package:xml/xml.dart';

class PodcastEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final String duration;
  final String? guid;
  final String? publicationDate;
  final String? imageUrl;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    this.guid,
    this.publicationDate,
    this.imageUrl,
  });

  factory PodcastEpisode.fromXml(XmlElement episode, String? image) {
    return PodcastEpisode(
      title: episode.findElements('title').firstOrNull?.innerText ?? '',
      description:
          episode.findElements('description').firstOrNull?.innerText ?? '',
      audioUrl:
          episode.findElements('enclosure').firstOrNull?.getAttribute('url') ??
              '',
      duration:
          episode.findElements('itunes:duration').firstOrNull?.innerText ?? '',
      guid: episode.findElements('guid').firstOrNull?.innerText,
      publicationDate:
          episode.findElements('pubDate').firstOrNull?.innerText ?? '',
      imageUrl: episode
              .findElements('itunes:image')
              .firstOrNull
              ?.getAttribute('href') ??
          image,
    );
  }

  factory PodcastEpisode.fromItunes(Map<String, dynamic> data) {
    return PodcastEpisode(
      title: data['title'],
      description: data['subtitle'],
      audioUrl: data['feedUrl'],
      duration: data['duration'],
      guid: data['guid'],
      publicationDate: data['releaseDate'] ?? data['pubDate'] ?? '',
      imageUrl: data['artworkUrl600'],
    );
  }
}
