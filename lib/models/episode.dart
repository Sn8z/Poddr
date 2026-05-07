import 'package:audio_service/audio_service.dart';

class PodcastEpisode {
  final String? title;
  final String? description;
  final String audioUrl;
  final String? videoUrl;
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

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  PodcastEpisode({
    this.title,
    this.description,
    required this.audioUrl,
    this.videoUrl,
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

  PodcastEpisode copyWith({
    String? title,
    String? description,
    String? audioUrl,
    String? videoUrl,
    String? podcastTitle,
    String? podcastRSS,
    String? author,
    Duration? duration,
    DateTime? publicationDate,
    String? imageUrl,
    List<Map<String, String>>? transcripts,
    List<Map<String, String>>? soundbites,
    List<Map<String, String>>? persons,
    String? season,
    String? episodeNumber,
    bool? isTrailer,
    String? license,
    Map<String, String>? location,
    String? contentEncoded,
    bool? block,
    Map<String, dynamic>? value,
    List<Map<String, String>>? music,
  }) {
    return PodcastEpisode(
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      podcastRSS: podcastRSS ?? this.podcastRSS,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      publicationDate: publicationDate ?? this.publicationDate,
      imageUrl: imageUrl ?? this.imageUrl,
      transcripts: transcripts ?? this.transcripts,
      soundbites: soundbites ?? this.soundbites,
      persons: persons ?? this.persons,
      season: season ?? this.season,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      isTrailer: isTrailer ?? this.isTrailer,
      license: license ?? this.license,
      location: location ?? this.location,
      contentEncoded: contentEncoded ?? this.contentEncoded,
      block: block ?? this.block,
      value: value ?? this.value,
      music: music ?? this.music,
    );
  }

  factory PodcastEpisode.fromMediaItem({required MediaItem mediaItem}) {
    return PodcastEpisode(
      title: mediaItem.title,
      description: mediaItem.extras?['description'] ?? '',
      podcastRSS: mediaItem.extras?['podcastRSS'],
      podcastTitle: mediaItem.artist,
      author: mediaItem.album,
      audioUrl: mediaItem.extras?['audioUrl'] ?? mediaItem.id,
      videoUrl: mediaItem.extras?['videoUrl'],
      duration: mediaItem.duration,
      publicationDate: mediaItem.extras?['publicationDate'] != null
          ? DateTime.tryParse(mediaItem.extras?['publicationDate'])
          : null,
      imageUrl: mediaItem.artUri?.toString(),
    );
  }

  @override
  String toString() {
    return 'PodcastEpisode{title: $title, description: $description, audioUrl: $audioUrl, videoUrl: $videoUrl, podcastTitle: $podcastTitle, podcastRSS: $podcastRSS, author: $author, duration: $duration, publicationDate: $publicationDate, imageUrl: $imageUrl}';
  }
}
