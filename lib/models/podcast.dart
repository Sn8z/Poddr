import 'package:xml/xml.dart';
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
  final List<String> tags;
  final List<PodcastEpisode> episodes;

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
    this.tags = const [],
    this.episodes = const [],
  });

  factory Podcast.fromXml(String data, String rss) {
    final xml = XmlDocument.parse(data);
    final channel = xml.findAllElements('channel').firstOrNull;
    if (channel == null) throw Exception("$rss is not a valid RSS feed");

    final image = _parseImage(channel);
    final title = _parseTitle(channel);
    final author = _parseAuthor(channel);

    final feed = Podcast(
      title: title,
      description: _parseDescription(channel),
      image: image,
      author: author,
      link: _parseLink(channel),
      language: _parseLanguage(channel),
      copyright: _parseCopyright(channel),
      explicit: _parseExplicit(channel),
      rss: rss,
      tags: _parseGenres(channel),
      episodes: channel
          .findElements('item')
          .map(
            (episode) => PodcastEpisode.fromXml(
              episode: episode,
              image: image,
              podcastTitle: title,
              podcastRSS: rss,
              author: author,
            ),
          )
          .toList(),
    );

    return feed;
  }

  @override
  String toString() {
    return 'Podcast{title: $title, description: $description, image: $image, author: $author, rss: $rss, link: $link, language: $language, copyright: $copyright, explicit: $explicit, tags: $tags,}';
  }
}

String? _parseTitle(XmlElement channel) {
  final title = channel.findElements('title').firstOrNull;
  return title?.innerText;
}

String? _parseDescription(XmlElement channel) {
  final description = channel.findElements('description').firstOrNull;
  return description?.innerText;
}

String? _parseImage(XmlElement channel) {
  final standardImage = channel
      .findElements('image')
      .firstOrNull
      ?.findElements('url')
      .firstOrNull
      ?.innerText;

  final itunesImage =
      channel.findElements('itunes:image').firstOrNull?.getAttribute('href');

  return standardImage ?? itunesImage;
}

String? _parseAuthor(XmlElement channel) {
  final author = channel.findElements('author').firstOrNull;
  return author?.innerText;
}

String? _parseLink(XmlElement channel) {
  final link = channel.findElements('link').firstOrNull;
  return link?.innerText;
}

String? _parseLanguage(XmlElement channel) {
  final language = channel.findElements('language').firstOrNull;
  return language?.innerText;
}

String? _parseCopyright(XmlElement channel) {
  final copyright = channel.findElements('copyright').firstOrNull;
  return copyright?.innerText;
}

List<String> _parseGenres(XmlElement channel) {
  final tags = <String>{};

  for (var category in channel.findElements('itunes:category')) {
    final mainCategory = category.getAttribute('text');
    if (mainCategory != null) {
      tags.add(mainCategory);
    }

    for (var subCategory in category.findElements('itunes:category')) {
      final subCategoryText = subCategory.getAttribute('text');
      if (subCategoryText != null) {
        tags.add(subCategoryText);
      }
    }
  }

  for (var category in channel.findElements('category')) {
    final categoryText = category.innerText;
    if (categoryText.isNotEmpty) {
      tags.add(categoryText);
    }
  }
  return tags.toList();
}

bool _parseExplicit(XmlElement channel) {
  final explicit = channel.findElements('itunes:explicit').firstOrNull;
  if (explicit == null) return false;
  final strValue = explicit.innerText.toLowerCase();
  return strValue == 'true' || strValue == 'yes' || strValue == 'explicit';
}
