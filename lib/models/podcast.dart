import 'episode.dart';
import 'podcast_metadata.dart';

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
  final bool broken;

  // Podcast 2.0 fields
  final bool locked;
  final List<FundingLink> funding;
  final ChapterLink? chapters;
  final List<Person> persons;
  final Location? location;
  final String? podcastGuid;
  final String? medium;
  final bool block;

  // Categories from standard RSS <category> tags
  final List<RssCategory>? categories;

  const Podcast({
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
    this.broken = false,
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

  @override
  String toString() {
    return 'Podcast{title: $title, author: $author, episodes: ${episodes.length}, broken: $broken, locked: $locked, funding: ${funding.length}}';
  }
}
