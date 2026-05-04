import 'package:audio_service/audio_service.dart';

class PodcastEpisode {
  final String? title;
  final String? description;
  final String audioUrl;
  final String? podcastTitle;
  final String? podcastRSS;
  final String? author;
  final Duration? duration;
  final DateTime? publicationDate;
  final String? imageUrl;

  // Podcast 2.0 fields
  final List<Map<String, String>> transcripts;
  final List<Map<String, String>> soundbites;
  final List<Map<String, String>> persons;
  final String? season;
  final String? episodeNumber;
  final bool isTrailer;
  final String? license;
  final Map<String, String>? location;

  // Additional fields
  final String? contentEncoded;
  final bool block;
  final Map<String, dynamic>? value;
  final List<Map<String, String>> music;

  PodcastEpisode({
    this.title,
    this.description,
    required this.audioUrl,
    this.podcastTitle,
    this.podcastRSS,
    this.author,
    this.duration,
    this.publicationDate,
    this.imageUrl,
    this.transcripts = const [],
    this.soundbites = const [],
    this.persons = const [],
    this.season,
    this.episodeNumber,
    this.isTrailer = false,
    this.license,
    this.location,
    this.contentEncoded,
    this.block = false,
    this.value,
    this.music = const [],
  });

  factory PodcastEpisode.fromMediaItem({required MediaItem mediaItem}) {
    return PodcastEpisode(
      title: mediaItem.title,
      description: mediaItem.extras?['description'] ?? '',
      podcastRSS: mediaItem.extras?['podcastRSS'],
      podcastTitle: mediaItem.artist,
      author: mediaItem.album,
      audioUrl: mediaItem.id,
      duration: mediaItem.duration,
      publicationDate: mediaItem.extras?['publicationDate'] != null
          ? DateTime.tryParse(mediaItem.extras?['publicationDate'])
          : null,
      imageUrl: mediaItem.artUri?.toString(),
    );
  }

  @override
  String toString() {
    return 'PodcastEpisode{title: $title, description: $description, audioUrl: $audioUrl, podcastTitle: $podcastTitle, podcastRSS: $podcastRSS, author: $author, duration: $duration, publicationDate: $publicationDate, imageUrl: $imageUrl}';
  }
}
