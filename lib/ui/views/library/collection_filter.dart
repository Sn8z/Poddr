import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/services/collections.dart';

class CollectionFilter extends ChangeNotifier {
  static const String logName = "CollectionFilter";
  final CollectionsProvider _collections;

  Set<int> _collectionIds = const {};
  Set<String> _rss = const {};
  StreamSubscription<Set<String>>? _subscription;
  bool _disposed = false;

  CollectionFilter(this._collections);

  Set<int> get collectionIds => _collectionIds;

  bool includes(String? rss) {
    if (_collectionIds.isEmpty) return true;
    return rss != null && _rss.contains(rss);
  }

  void update(Set<int> ids) {
    _subscription?.cancel();
    _subscription = null;
    _collectionIds = ids;
    _rss = const {};
    _notify();

    if (ids.isEmpty) return;

    _subscription = _collections.watchRssInCollections(ids).listen(
      (rss) {
        _rss = rss;
        _notify();
      },
      onError: (Object e, StackTrace stackTrace) {
        error('Failed to watch collection membership',
            name: logName, error: e, stackTrace: stackTrace);
      },
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
