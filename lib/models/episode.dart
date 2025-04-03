import 'dart:io';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class PodcastEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final String? podcastTitle;
  final String? podcastRSS;
  final String? author;
  final Duration? duration;
  final DateTime? publicationDate;
  final String? imageUrl;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    this.podcastTitle,
    this.podcastRSS,
    this.author,
    this.duration = Duration.zero,
    this.publicationDate,
    this.imageUrl,
  });

  factory PodcastEpisode.fromXml({
    required XmlElement episode,
    String? image,
    String? podcastTitle,
    String? podcastRSS,
    String? author,
  }) {
    return PodcastEpisode(
      title: _parseTitle(episode) ?? '',
      description: _parseDescription(episode) ?? '',
      podcastRSS: podcastRSS,
      podcastTitle: podcastTitle,
      author: author,
      audioUrl: _parseAudioUrl(episode) ?? '',
      duration: _parseDuration(episode),
      publicationDate: _parsePubDate(episode),
      imageUrl: _parseImageUrl(episode) ?? image,
    );
  }

  @override
  String toString() {
    return 'PodcastEpisode{title: $title, description: $description, audioUrl: $audioUrl, podcastTitle: $podcastTitle, podcastRSS: $podcastRSS, author: $author, duration: $duration, publicationDate: $publicationDate, imageUrl: $imageUrl}';
  }
}

String? _parseTitle(XmlElement episode) {
  final title = episode.findElements('title').firstOrNull;
  return title?.innerText;
}

String? _parseDescription(XmlElement episode) {
  final description = episode.findElements('description').firstOrNull;
  return description?.innerText;
}

String? _parseAudioUrl(XmlElement episode) {
  final audioUrl = episode.findElements('enclosure').firstOrNull;
  return audioUrl?.getAttribute('url');
}

Duration _parseDuration(XmlElement episode) {
  final duration = episode.findElements('itunes:duration').firstOrNull;
  final durationText = duration?.innerText;
  if (durationText == null) return Duration.zero;

  List<String> parts = durationText.split(':').reversed.toList();
  int seconds = 0;

  if (parts.isNotEmpty) seconds += int.tryParse(parts[0]) ?? 0;
  if (parts.length > 1) seconds += (int.tryParse(parts[1]) ?? 0) * 60;
  if (parts.length > 2) seconds += (int.tryParse(parts[2]) ?? 0) * 3600;

  return Duration(seconds: seconds);
}

DateTime? _parsePubDate(XmlElement episode) {
  final pubDate = episode.findElements('pubDate').firstOrNull;
  final pubDateText = pubDate?.innerText;
  if (pubDateText == null || pubDateText.isEmpty) return null;

  try {
    final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
    return dateFormat.parse(pubDateText);
  } catch (_) {
    try {
      return DateTime.parse(pubDateText);
    } catch (_) {
      try {
        return HttpDate.parse(pubDateText);
      } catch (_) {
        return null;
      }
    }
  }
}

String? _parseImageUrl(XmlElement episode) {
  final image = episode.findElements('itunes:image').firstOrNull;
  return image?.getAttribute('href');
}
