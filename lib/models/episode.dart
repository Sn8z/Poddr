import 'dart:io';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class PodcastEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final Duration? duration;
  final DateTime? publicationDate;
  final String? imageUrl;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    this.duration = Duration.zero,
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
      duration: _parseDuration(
          episode.findElements('itunes:duration').firstOrNull?.innerText),
      publicationDate: _parseDateTime(
          episode.findElements('pubDate').firstOrNull?.innerText ?? ''),
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
      duration: _parseDuration(data['duration']),
      publicationDate:
          _parseDateTime(data['releaseDate'] ?? data['pubDate'] ?? ''),
      imageUrl: data['artworkUrl600'],
    );
  }
}

Duration _parseDuration(String? text) {
  if (text == null) return Duration.zero;

  List<String> parts = text.split(':').reversed.toList();
  int seconds = 0;

  if (parts.isNotEmpty) seconds += int.tryParse(parts[0]) ?? 0;
  if (parts.length > 1) seconds += (int.tryParse(parts[1]) ?? 0) * 60;
  if (parts.length > 2) seconds += (int.tryParse(parts[2]) ?? 0) * 3600;

  return Duration(seconds: seconds);
}

DateTime? _parseDateTime(String? text) {
  if (text == null || text.isEmpty) return null;

  try {
    final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
    return dateFormat.parse(text);
  } catch (_) {
    try {
      return DateTime.parse(text);
    } catch (_) {
      try {
        return HttpDate.parse(text);
      } catch (_) {
        return null;
      }
    }
  }
}
