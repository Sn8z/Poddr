import 'package:poddr/models/offline_episode.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/models/podcast.dart';

enum EpisodeSortField {
  publicationDate('Publication Date'),
  title('Title'),
  duration('Duration');

  const EpisodeSortField(this.label);
  final String label;
}

enum PodcastSortField {
  title('Title'),
  author('Author');

  const PodcastSortField(this.label);
  final String label;
}

enum OfflineEpisodeSortField {
  downloadedAt('Downloaded Date'),
  title('Title'),
  duration('Duration'),
  publicationDate('Publication Date');

  const OfflineEpisodeSortField(this.label);
  final String label;
}

enum SortDirection {
  ascending('Ascending'),
  descending('Descending');

  const SortDirection(this.label);
  final String label;
}

bool _matchesEpisodeFilter(PodcastEpisode e, String q) {
  return (e.title ?? '').toLowerCase().contains(q) ||
      (e.author ?? '').toLowerCase().contains(q) ||
      (e.podcastTitle ?? '').toLowerCase().contains(q) ||
      (e.description ?? '').toLowerCase().contains(q);
}

bool _matchesOfflineEpisodeFilter(OfflineEpisode e, String q) {
  return (e.title).toLowerCase().contains(q) ||
      (e.podcastTitle).toLowerCase().contains(q) ||
      (e.description).toLowerCase().contains(q);
}

bool _matchesPodcastFilter(Podcast p, String q) {
  return (p.title ?? '').toLowerCase().contains(q) ||
      (p.author ?? '').toLowerCase().contains(q);
}

int _episodeComparator(
    PodcastEpisode a, PodcastEpisode b, EpisodeSortField field,
    SortDirection direction) {
  int result;

  switch (field) {
    case EpisodeSortField.publicationDate:
      final ad = a.publicationDate;
      final bd = b.publicationDate;
      if (ad == null && bd == null) {
        result = 0;
      } else if (ad == null) {
        result = 1;
      } else if (bd == null) {
        result = -1;
      } else {
        result = ad.compareTo(bd);
      }
      break;

    case EpisodeSortField.title:
      result = (a.title ?? '').compareTo(b.title ?? '');
      break;

    case EpisodeSortField.duration:
      final ad = a.duration ?? Duration.zero;
      final bd = b.duration ?? Duration.zero;
      result = ad.compareTo(bd);
      break;
  }

  return direction == SortDirection.ascending ? result : -result;
}

int _offlineEpisodeComparator(OfflineEpisode a, OfflineEpisode b,
    OfflineEpisodeSortField field, SortDirection direction) {
  int result;

  switch (field) {
    case OfflineEpisodeSortField.downloadedAt:
      result = a.downloadedAt.compareTo(b.downloadedAt);
      break;

    case OfflineEpisodeSortField.title:
      result = a.title.compareTo(b.title);
      break;

    case OfflineEpisodeSortField.duration:
      result = a.duration.compareTo(b.duration);
      break;

    case OfflineEpisodeSortField.publicationDate:
      final ad = a.publicationDate;
      final bd = b.publicationDate;
      if (ad == null && bd == null) {
        result = 0;
      } else if (ad == null) {
        result = 1;
      } else if (bd == null) {
        result = -1;
      } else {
        result = ad.compareTo(bd);
      }
      break;
  }

  return direction == SortDirection.ascending ? result : -result;
}

int _podcastComparator(
    Podcast a, Podcast b, PodcastSortField field, SortDirection direction) {
  int result;

  switch (field) {
    case PodcastSortField.title:
      result = (a.title ?? '').compareTo(b.title ?? '');
      break;

    case PodcastSortField.author:
      result = (a.author ?? '').compareTo(b.author ?? '');
      break;
  }

  return direction == SortDirection.ascending ? result : -result;
}

List<PodcastEpisode> filterAndSortEpisodes({
  required List<PodcastEpisode> episodes,
  required String filter,
  required EpisodeSortField sortField,
  required SortDirection sortDirection,
}) {
  var list = List<PodcastEpisode>.from(episodes);

  if (filter.isNotEmpty) {
    final q = filter.toLowerCase();
    list = list.where((e) => _matchesEpisodeFilter(e, q)).toList();
  }

  list.sort((a, b) =>
      _episodeComparator(a, b, sortField, sortDirection));
  return list;
}

List<OfflineEpisode> filterAndSortOfflineEpisodes({
  required List<OfflineEpisode> episodes,
  required String filter,
  required OfflineEpisodeSortField sortField,
  required SortDirection sortDirection,
}) {
  var list = List<OfflineEpisode>.from(episodes);

  if (filter.isNotEmpty) {
    final q = filter.toLowerCase();
    list = list.where((e) => _matchesOfflineEpisodeFilter(e, q)).toList();
  }

  list.sort((a, b) =>
      _offlineEpisodeComparator(a, b, sortField, sortDirection));
  return list;
}

List<Podcast> filterAndSortPodcasts({
  required List<Podcast> podcasts,
  required String filter,
  required PodcastSortField sortField,
  required SortDirection sortDirection,
}) {
  var list = List<Podcast>.from(podcasts);

  if (filter.isNotEmpty) {
    final q = filter.toLowerCase();
    list = list.where((p) => _matchesPodcastFilter(p, q)).toList();
  }

  list.sort((a, b) => _podcastComparator(a, b, sortField, sortDirection));
  return list;
}
