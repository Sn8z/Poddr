import 'package:flutter/widgets.dart';
import 'package:poddr/models/episode.dart';
import 'package:poddr/services/subscriptions.dart';

enum EpisodeSortField {
  publicationDate('Publication Date'),
  title('Title'),
  duration('Duration');

  const EpisodeSortField(this.label);
  final String label;
}

enum SortDirection {
  ascending('Ascending'),
  descending('Descending');

  const SortDirection(this.label);
  final String label;
}

class LatestEpisodesViewModel extends ChangeNotifier {
  final SubscriptionProvider _source;

  String _filter = '';
  String get filter => _filter;

  EpisodeSortField _sortField = EpisodeSortField.publicationDate;
  String get sortField => _sortField.label;

  SortDirection _sortDirection = SortDirection.descending;
  String get sortDirection => _sortDirection.label;

  LatestEpisodesViewModel(this._source) {
    _source.addListener(notifyListeners);
  }

  List<PodcastEpisode> get episodes {
    var list = List<PodcastEpisode>.from(_source.latestEpisodes);

    if (_filter.isNotEmpty) {
      final q = _filter.toLowerCase();
      list = list.where((e) => _matchesFilter(e, q)).toList();
    }

    list.sort(_comparator);
    return list;
  }

  bool _matchesFilter(PodcastEpisode e, String q) {
    return (e.title ?? '').toLowerCase().contains(q) ||
        (e.author ?? '').toLowerCase().contains(q) ||
        (e.podcastTitle ?? '').toLowerCase().contains(q) ||
        (e.description ?? '').toLowerCase().contains(q);
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void setSort({
    EpisodeSortField? field,
    SortDirection? direction,
  }) {
    if (field != null) _sortField = field;
    if (direction != null) _sortDirection = direction;
    notifyListeners();
  }

  int _comparator(PodcastEpisode a, PodcastEpisode b) {
    int result;

    switch (_sortField) {
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

    return _sortDirection == SortDirection.ascending ? result : -result;
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    super.dispose();
  }
}
