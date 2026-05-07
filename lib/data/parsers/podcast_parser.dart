import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:poddr/models/podcast.dart';
import 'package:poddr/models/episode.dart';

class PoddrPodcastParser {
  static final _dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');

  static Podcast parse(String xmlString, String rssUrl) {
    try {
      final doc = XmlDocument.parse(xmlString);

      final root = doc.rootElement;

      final channel = root.findElements('channel').firstOrNull;
      if (channel != null) {
        return _parsePodcast(channel, rssUrl);
      }

      if (root.name.local == 'feed') {
        return _parseAtomFeed(root, rssUrl);
      }

      final feed = root.findElements('feed').firstOrNull;
      if (feed != null) {
        return _parseAtomFeed(feed, rssUrl);
      }

      throw Exception("$rssUrl is not a valid RSS or Atom feed");
    } on XmlParserException catch (e) {
      throw Exception("Failed to parse XML from $rssUrl: ${e.message}");
    } catch (e) {
      throw Exception("Failed to parse podcast from $rssUrl: $e");
    }
  }

  static DateTime? _parseDateRobust(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    final trimmedDate = dateString.trim();

    try {
      return DateTime.parse(trimmedDate);
    } catch (_) {}

    String cleanedDate = _sanitizeRssDate(trimmedDate);

    try {
      return _dateFormat.parse(cleanedDate);
    } catch (_) {}

    try {
      final fallbackFormat = DateFormat('dd MMM yyyy HH:mm:ss Z');
      final noDayString =
          cleanedDate.replaceFirst(RegExp(r'^[a-zA-Z]+,\s+'), '');
      return fallbackFormat.parse(noDayString);
    } catch (_) {}

    return null;
  }

  static String _sanitizeRssDate(String dateString) {
    String cleaned = dateString;

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    final Map<String, String> tzMap = {
      'GMT': '+0000',
      'UT': '+0000',
      'UTC': '+0000',
      'EST': '-0500',
      'EDT': '-0400',
      'CST': '-0600',
      'CDT': '-0500',
      'MST': '-0700',
      'MDT': '-0600',
      'PST': '-0800',
      'PDT': '-0700',
      'Z': '+0000',
    };

    tzMap.forEach((key, value) {
      if (cleaned.endsWith(' $key')) {
        cleaned = cleaned.replaceRange(
            cleaned.length - key.length, cleaned.length, value);
      }
    });

    return cleaned;
  }

  static String? _findElementText(XmlElement element, List<String> names) {
    for (final name in names) {
      final found = element.findElements(name).firstOrNull?.innerText.trim();
      if (found != null && found.isNotEmpty) return found;
    }
    return null;
  }

  static String? _findElementAttr(
    XmlElement element,
    List<String> names,
    String attr,
  ) {
    for (final name in names) {
      final found = element.findElements(name).firstOrNull?.getAttribute(attr);
      if (found != null && found.isNotEmpty) return found;
    }
    return null;
  }

  static Podcast _parseAtomFeed(XmlElement feed, String rssUrl) {
    final title = _findElementText(feed, ['atom:title', 'title']);
    final author = _findElementText(feed, ['atom:author', 'author']);

    return Podcast(
      title: title,
      description: _findElementText(
          feed, ['atom:subtitle', 'atom:summary', 'subtitle', 'description']),
      image: _parseAtomImage(feed),
      author: author,
      link: _findElementAttr(feed, ['atom:link'], 'href'),
      language: _findElementText(feed, ['atom:language', 'language']),
      copyright: _findElementText(feed, ['atom:rights', 'rights', 'copyright']),
      explicit: false,
      rss: rssUrl,
      episodes: feed
          .findElements('entry')
          .map(
            (entry) => _parseAtomEntry(
              entry,
              podcastTitle: title,
              podcastRSS: rssUrl,
              author: author,
            ),
          )
          .toList(),
    );
  }

  static String? _parseAtomImage(XmlElement feed) {
    final icon = feed.findElements('icon').firstOrNull?.innerText.trim();
    if (icon != null && icon.isNotEmpty) return icon;

    final logo = feed.findElements('logo').firstOrNull?.innerText.trim();
    if (logo != null && logo.isNotEmpty) return logo;

    return null;
  }

  static PodcastEpisode _parseAtomEntry(
    XmlElement entry, {
    String? podcastTitle,
    String? podcastRSS,
    String? author,
  }) {
    return PodcastEpisode(
      title: _findElementText(entry, ['atom:title', 'title']),
      description: _findElementText(entry, [
        'atom:summary',
        'atom:content',
        'summary',
        'content',
        'description',
      ]),
      podcastRSS: podcastRSS,
      podcastTitle: podcastTitle,
      author: author ?? _findElementText(entry, ['atom:author', 'author']),
      audioUrl: _parseAtomLink(entry, 'enclosure') ?? '',
      videoUrl: _parseVideoUrl(entry),
      duration: _parseDuration(entry),
      publicationDate: _parseAtomPublished(entry),
      imageUrl: _parseEpisodeImageUrl(entry),
    );
  }

  static String? _parseAtomLink(XmlElement entry, String rel) {
    for (final link in entry.findElements('link')) {
      if (link.getAttribute('rel') == rel) {
        return link.getAttribute('href');
      }
    }
    return entry.findElements('link').firstOrNull?.getAttribute('href');
  }

  static DateTime? _parseAtomPublished(XmlElement entry) {
    final text = _findElementText(
        entry, ['atom:published', 'published', 'atom:updated', 'updated']);
    return _parseDateRobust(text);
  }

  static Podcast _parsePodcast(
    XmlElement channel,
    String rss,
  ) {
    final image = _parseImage(channel);
    final title = _parseTitle(channel);
    final author = _parseAuthor(channel);

    return Podcast(
      title: title,
      description: _parseDescription(channel),
      image: image,
      author: author,
      link: _parseLink(channel),
      language: _parseLanguage(channel),
      copyright: _parseCopyright(channel),
      explicit: _parseExplicit(channel),
      rss: rss,
      episodes: channel
          .findElements('item')
          .map((episode) => _parseEpisode(
                episode,
                image: image,
                podcastTitle: title,
                podcastRSS: rss,
                author: author,
              ))
          .toList(),
      newFeedUrl: _parseNewFeedUrl(channel),
      locked: _parseLocked(channel),
      funding: _parseFunding(channel),
      chapters: _parseChapters(channel),
      persons: _parsePersons(channel),
      location: _parseLocation(channel),
      podcastGuid: _parsePodcastGuid(channel),
      medium: _parseMedium(channel),
      block: _parseBlock(channel),
      categories: _parseCategories(channel),
    );
  }

  static PodcastEpisode _parseEpisode(
    XmlElement item, {
    String? image,
    String? podcastTitle,
    String? podcastRSS,
    String? author,
  }) {
    return PodcastEpisode(
      title: _parseEpisodeTitle(item),
      description: _parseEpisodeDescription(item),
      podcastRSS: podcastRSS,
      podcastTitle: podcastTitle,
      author: author,
      audioUrl: _parseAudioUrl(item) ?? '',
      videoUrl: _parseVideoUrl(item),
      duration: _parseDuration(item),
      publicationDate: _parsePubDate(item),
      imageUrl: _parseEpisodeImageUrl(item) ?? image,
      transcripts: _parseTranscripts(item),
      soundbites: _parseSoundbites(item),
      persons: _parsePersons(item),
      season: _parseSeason(item),
      episodeNumber: _parseEpisodeNumber(item),
      isTrailer: item.findElements('podcast:trailer').firstOrNull != null,
      license: _parseLicense(item),
      location: _parseLocation(item),
      contentEncoded: _parseContentEncoded(item),
      block: _parseEpisodeBlock(item),
      value: _parseValue(item),
      music: _parseMusic(item),
    );
  }

  static String? _parseTitle(XmlElement channel) {
    return _findElementText(
        channel, ['title', 'itunes:title', 'podcast:title']);
  }

  static String? _parseDescription(XmlElement channel) {
    return _findElementText(channel, [
      'description',
      'itunes:summary',
      'podcast:summary',
      'podcast:description',
    ]);
  }

  static String? _parseImage(XmlElement channel) {
    final standardImage = channel
        .findElements('image')
        .firstOrNull
        ?.findElements('url')
        .firstOrNull
        ?.innerText
        .trim();
    if (standardImage != null && standardImage.isNotEmpty) return standardImage;

    final itunesImage =
        channel.findElements('itunes:image').firstOrNull?.getAttribute('href');
    if (itunesImage != null && itunesImage.isNotEmpty) return itunesImage;

    return channel
        .findElements('podcast:image')
        .firstOrNull
        ?.getAttribute('href');
  }

  static String? _parseAuthor(XmlElement channel) {
    return _findElementText(
        channel, ['author', 'itunes:author', 'podcast:author']);
  }

  static String? _parseLink(XmlElement channel) {
    return channel.findElements('link').firstOrNull?.innerText.trim();
  }

  static String? _parseLanguage(XmlElement channel) {
    return channel.findElements('language').firstOrNull?.innerText.trim();
  }

  static String? _parseCopyright(XmlElement channel) {
    return channel.findElements('copyright').firstOrNull?.innerText.trim();
  }

  static bool _parseExplicit(XmlElement channel) {
    final value =
        _findElementText(channel, ['itunes:explicit', 'podcast:explicit']);
    if (value == null) return false;
    final strValue = value.toLowerCase();
    return strValue == 'true' || strValue == 'yes' || strValue == 'explicit';
  }

  static String? _parseNewFeedUrl(XmlElement channel) {
    return _findElementText(
        channel, ['itunes:new-feed-url', 'podcast:new-feed-url']);
  }

  static bool _parseLocked(XmlElement element) {
    final value =
        element.findElements('podcast:locked').firstOrNull?.innerText.trim();
    if (value == null) return false;
    return value.toLowerCase() == 'yes';
  }

  static List<Map<String, String>> _parseFunding(XmlElement element) {
    return element
        .findElements('podcast:funding')
        .map(
          (e) => {
            'url': e.getAttribute('url') ?? '',
            'title': e.innerText.trim(),
          },
        )
        .toList();
  }

  static Map<String, String>? _parseChapters(XmlElement element) {
    final chapters = element.findElements('podcast:chapters').firstOrNull;
    if (chapters == null) return null;

    return {
      'url': chapters.getAttribute('url') ?? '',
      'type': chapters.getAttribute('type') ?? '',
    };
  }

  static List<Map<String, String>> _parsePersons(XmlElement element) {
    return element
        .findElements('podcast:person')
        .map(
          (e) => {
            'name': e.innerText.trim(),
            'role': e.getAttribute('role') ?? '',
            'img': e.getAttribute('img') ?? '',
            'href': e.getAttribute('href') ?? '',
            'group': e.getAttribute('group') ?? '',
          },
        )
        .toList();
  }

  static Map<String, String>? _parseLocation(XmlElement element) {
    final location = element.findElements('podcast:location').firstOrNull;
    if (location == null) return null;

    return {
      'name': location.innerText.trim(),
      'geo': location.getAttribute('geo') ?? '',
      'osm': location.getAttribute('osm') ?? '',
      'country': location.getAttribute('country') ?? '',
      'rel': location.getAttribute('rel') ?? 'subject',
    };
  }

  static String? _parsePodcastGuid(XmlElement element) {
    return element.findElements('podcast:guid').firstOrNull?.innerText.trim();
  }

  static String? _parseMedium(XmlElement element) {
    return element.findElements('podcast:medium').firstOrNull?.innerText.trim();
  }

  static bool _parseBlock(XmlElement element) {
    final block = _findElementText(element, ['podcast:block', 'itunes:block']);
    if (block == null) return false;
    final value = block.toLowerCase();
    return value == 'yes' || value == 'true';
  }

  static List<Map<String, dynamic>>? _parseCategories(XmlElement channel) {
    final categories = <Map<String, dynamic>>[];

    for (final category in channel.findElements('category')) {
      final text = category.innerText.trim();
      if (text.isNotEmpty) {
        categories.add({
          'text': text,
          'domain': category.getAttribute('domain') ?? '',
        });
      }
    }

    return categories.isNotEmpty ? categories : null;
  }

  static String? _parseEpisodeTitle(XmlElement item) {
    return _findElementText(item, ['title', 'itunes:title', 'podcast:title']);
  }

  static String? _parseEpisodeDescription(XmlElement item) {
    return _findElementText(item, [
      'description',
      'itunes:summary',
      'itunes:subtitle',
      'podcast:description',
    ]);
  }

  static String? _parseVideoUrl(XmlElement item) {
    for (final enclosure in item.findElements('enclosure')) {
      final type = enclosure.getAttribute('type')?.toLowerCase() ?? '';
      if (type.startsWith('video/')) {
        final url = enclosure.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }

    for (final media in item.findElements('media:content')) {
      final type = media.getAttribute('type')?.toLowerCase() ?? '';
      if (type.startsWith('video/')) {
        final url = media.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }

    for (final link in item.findElements('link')) {
      if (link.getAttribute('rel') == 'enclosure') {
        final type = link.getAttribute('type')?.toLowerCase() ?? '';
        if (type.startsWith('video/')) {
          final href = link.getAttribute('href');
          if (href != null && href.isNotEmpty) return href;
        }
      }
    }

    for (final altEnclosure in item.findElements('podcast:alternateEnclosure')) {
      final type = altEnclosure.getAttribute('type')?.toLowerCase() ?? '';
      if (type.startsWith('video/')) {
        final source = altEnclosure
            .findElements('podcast:source')
            .firstOrNull
            ?.getAttribute('url');
        if (source != null && source.isNotEmpty) return source;
      }
    }

    return null;
  }

  static String? _parseAudioUrl(XmlElement item) {
    final enclosure =
        item.findElements('enclosure').firstOrNull?.getAttribute('url');
    if (enclosure != null && enclosure.isNotEmpty) return enclosure;

    final media =
        item.findElements('media:content').firstOrNull?.getAttribute('url');
    if (media != null && media.isNotEmpty) return media;

    final altEnclosure =
        item.findElements('podcast:alternateEnclosure').firstOrNull;
    if (altEnclosure != null) {
      final source = altEnclosure
          .findElements('podcast:source')
          .firstOrNull
          ?.getAttribute('url');
      if (source != null && source.isNotEmpty) return source;
    }

    for (final link in item.findElements('link')) {
      if (link.getAttribute('rel') == 'enclosure') {
        final href = link.getAttribute('href');
        if (href != null && href.isNotEmpty) return href;
      }
    }

    return null;
  }

  static Duration? _parseDuration(XmlElement item) {
    final durationText = _findElementText(item, [
      'itunes:duration',
      'podcast:duration',
    ]);
    if (durationText == null || durationText.isEmpty) return null;

    final parts = durationText.split(':').reversed.toList();
    int seconds = 0;

    if (parts.isNotEmpty) seconds += int.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) seconds += (int.tryParse(parts[1]) ?? 0) * 60;
    if (parts.length > 2) seconds += (int.tryParse(parts[2]) ?? 0) * 3600;

    return Duration(seconds: seconds);
  }

  static DateTime? _parsePubDate(XmlElement item) {
    final pubDateText = _findElementText(item, [
      'pubDate',
      'atom:published',
      'atom:updated',
      'dc:date',
      'published',
      'updated',
    ]);
    return _parseDateRobust(pubDateText);
  }

  static String? _parseEpisodeImageUrl(XmlElement item) {
    final itunes =
        item.findElements('itunes:image').firstOrNull?.getAttribute('href');
    if (itunes != null && itunes.isNotEmpty) return itunes;

    final thumbnail =
        item.findElements('media:thumbnail').firstOrNull?.getAttribute('url');
    if (thumbnail != null && thumbnail.isNotEmpty) return thumbnail;

    final group = item.findElements('media:group').firstOrNull;
    if (group != null) {
      final groupThumb = group
          .findElements('media:thumbnail')
          .firstOrNull
          ?.getAttribute('url');
      if (groupThumb != null && groupThumb.isNotEmpty) return groupThumb;
    }

    final podcastImg =
        item.findElements('podcast:image').firstOrNull?.getAttribute('href');
    if (podcastImg != null && podcastImg.isNotEmpty) return podcastImg;

    for (final content in item.findElements('media:content')) {
      if (content.getAttribute('medium') == 'image') {
        final url = content.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }

    if (group != null) {
      for (final content in group.findElements('media:content')) {
        if (content.getAttribute('medium') == 'image') {
          final url = content.getAttribute('url');
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }

    return null;
  }

  static List<Map<String, String>> _parseTranscripts(XmlElement item) {
    return item
        .findElements('podcast:transcript')
        .map(
          (e) => {
            'url': e.getAttribute('url') ?? '',
            'type': e.getAttribute('type') ?? '',
            'language': e.getAttribute('language') ?? '',
          },
        )
        .toList();
  }

  static List<Map<String, String>> _parseSoundbites(XmlElement item) {
    return item
        .findElements('podcast:soundbite')
        .map(
          (e) => {
            'start': e.getAttribute('startTime') ?? '',
            'duration': e.getAttribute('duration') ?? '',
            'title': e.innerText.trim(),
          },
        )
        .toList();
  }

  static String? _parseSeason(XmlElement item) {
    return _findElementText(item, ['itunes:season', 'podcast:season']);
  }

  static String? _parseEpisodeNumber(XmlElement item) {
    return _findElementText(item, ['itunes:episode', 'podcast:episode']);
  }

  static String? _parseLicense(XmlElement item) {
    return item.findElements('podcast:license').firstOrNull?.innerText.trim();
  }

  static String? _parseContentEncoded(XmlElement item) {
    return item.findElements('content:encoded').firstOrNull?.innerText.trim();
  }

  static bool _parseEpisodeBlock(XmlElement item) {
    return _parseBlock(item);
  }

  static Map<String, dynamic>? _parseValue(XmlElement element) {
    final valueElement = element.findElements('podcast:value').firstOrNull;
    if (valueElement == null) return null;

    final value = <String, dynamic>{
      'type': valueElement.getAttribute('type') ?? '',
      'method': valueElement.getAttribute('method') ?? '',
      'suggested': valueElement.getAttribute('suggested') ?? '',
      'recipients': <Map<String, String>>[],
    };

    for (final recipient
        in valueElement.findElements('podcast:valueRecipient')) {
      (value['recipients'] as List<Map<String, String>>).add({
        'name': recipient.getAttribute('name') ?? '',
        'type': recipient.getAttribute('type') ?? '',
        'address': recipient.getAttribute('address') ?? '',
        'split': recipient.getAttribute('split') ?? '',
        'fee': recipient.getAttribute('fee') ?? '',
      });
    }

    return value;
  }

  static List<Map<String, String>> _parseMusic(XmlElement item) {
    return item
        .findElements('podcast:music')
        .map(
          (e) => {
            'startTime': e.getAttribute('startTime') ?? '',
            'endTime': e.getAttribute('endTime') ?? '',
            'title': e.getAttribute('title') ?? '',
            'album': e.getAttribute('album') ?? '',
            'artist': e.getAttribute('artist') ?? '',
            'track': e.getAttribute('track') ?? '',
            'url': e.getAttribute('url') ?? '',
          },
        )
        .toList();
  }
}
