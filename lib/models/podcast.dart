import 'episode.dart';

class Podcast {
  final String? title;
  final String? description;
  final String? image;
  final String? author;
  final String? rss;
  final String? link;
  final String? language;
  final String? copyright;
  final bool explicit;
  final List<PodcastEpisode> episodes;
  final String? newFeedUrl;

  // Podcast 2.0 fields
  final bool locked;
  final List<Map<String, String>> funding;
  final Map<String, String>? chapters;
  final List<Map<String, String>> persons;
  final Map<String, String>? location;
  final String? podcastGuid;
  final String? medium;
  final bool block;

  // Categories from standard RSS <category> tags
  final List<Map<String, dynamic>>? categories;

  Podcast({
    this.title,
    this.description,
    this.image,
    this.author,
    this.rss,
    this.link,
    this.language,
    this.copyright,
    this.explicit = false,
    this.episodes = const [],
    this.newFeedUrl,
    this.locked = false,
    this.funding = const [],
    this.chapters,
    this.persons = const [],
    this.location,
    this.podcastGuid,
    this.medium,
    this.block = false,
    this.categories,
  });

  Podcast copyWith({
    String? title,
    String? description,
    String? image,
    String? author,
    String? rss,
    String? link,
    String? language,
    String? copyright,
    bool? explicit,
    List<PodcastEpisode>? episodes,
    String? newFeedUrl,
    bool? locked,
    List<Map<String, String>>? funding,
    Map<String, String>? chapters,
    List<Map<String, String>>? persons,
    Map<String, String>? location,
    String? podcastGuid,
    String? medium,
    bool? block,
    List<Map<String, dynamic>>? categories,
  }) {
    return Podcast(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      author: author ?? this.author,
      rss: rss ?? this.rss,
      link: link ?? this.link,
      language: language ?? this.language,
      copyright: copyright ?? this.copyright,
      explicit: explicit ?? this.explicit,
      episodes: episodes ?? this.episodes,
      newFeedUrl: newFeedUrl ?? this.newFeedUrl,
      locked: locked ?? this.locked,
      funding: funding ?? this.funding,
      chapters: chapters ?? this.chapters,
      persons: persons ?? this.persons,
      location: location ?? this.location,
      podcastGuid: podcastGuid ?? this.podcastGuid,
      medium: medium ?? this.medium,
      block: block ?? this.block,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() {
    return 'Podcast{title: $title, author: $author, episodes: ${episodes.length}, locked: $locked, funding: ${funding.length}}';
  }
}
