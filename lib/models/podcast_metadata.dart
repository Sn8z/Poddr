/// Typed value objects for the optional Podcast 2.0 metadata.
///
/// These are small, immutable records: they carry no behaviour and are only
/// used to describe parsed feed data.
library;

/// A transcript reference advertised by an episode.
typedef EpisodeTranscript = ({
  String url,
  String? type,
  String? language,
});

/// A funding link advertised by a podcast.
typedef FundingLink = ({
  String url,
  String title,
});

/// A person credited on a podcast or episode.
typedef Person = ({
  String name,
  String? role,
  String? img,
  String? href,
  String? group,
});

/// A reference to the chapters document advertised by a podcast.
typedef ChapterLink = ({
  String url,
  String? type,
});

/// A geographic location associated with a podcast or episode.
typedef Location = ({
  String name,
  String? geo,
  String? osm,
  String? country,
  String rel,
});

/// A standard RSS category.
typedef RssCategory = ({
  String text,
  String? domain,
});

/// A soundbite marker within an episode.
typedef Soundbite = ({
  String title,
  Duration? start,
  Duration? duration,
});

/// A music segment within an episode.
typedef MusicSegment = ({
  String? title,
  Duration? startTime,
  Duration? endTime,
  String? album,
  String? artist,
  String? track,
  String? url,
});

/// A recipient of a Podcast 2.0 value split.
typedef ValueRecipient = ({
  String? name,
  String? type,
  String? address,
  String? split,
  String? fee,
});

/// The Podcast 2.0 value block of an episode.
typedef ValueBlock = ({
  String? type,
  String? method,
  double? suggested,
  List<ValueRecipient> recipients,
});
