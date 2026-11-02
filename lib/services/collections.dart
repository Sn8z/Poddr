import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:poddr/core/async_state.dart';
import 'package:poddr/core/exceptions.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/collections/drift_collections_repository.dart';
import 'package:poddr/data/collections/collections_repository.dart';
import 'package:poddr/models/collection.dart';

class CollectionsProvider extends ChangeNotifier {
  static const String logName = "CollectionsProvider";
  final ICollectionsRepository _repository;

  AsyncState<List<PodcastCollection>> _collectionsState = const AsyncLoading();
  AsyncState<List<PodcastCollection>> get collectionsState => _collectionsState;

  String? _lastError;
  String? get lastError => _lastError;

  StreamSubscription<List<PodcastCollection>>? _watchSubscription;
  bool _disposed = false;

  CollectionsProvider({ICollectionsRepository? repository})
      : _repository = repository ?? DriftCollectionsRepository() {
    _listen();
  }

  void _listen() {
    _watchSubscription?.cancel();
    _watchSubscription = _repository.watchAllCollections().listen(
      (collections) {
        _collectionsState = AsyncData(collections);
        _notify();
      },
      onError: (Object e, StackTrace stackTrace) {
        error('Failed to watch collections',
            name: logName, error: e, stackTrace: stackTrace);
        _collectionsState = AsyncError(
          e is PoddrException
              ? e.userMessage
              : 'Collections could not be loaded. Please try again.',
        );
        _notify();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _watchSubscription?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void retryCollections() {
    _collectionsState = const AsyncLoading();
    _notify();
    _listen();
  }

  Stream<List<PodcastCollection>> watchCollectionsForRss(String rss) {
    return _repository.watchCollectionsForRss(rss).transform(
      StreamTransformer.fromHandlers(
        handleError: (errorObject, stackTrace, sink) {
          error(
            'Failed to watch collections for $rss',
            name: logName,
            error: errorObject,
            stackTrace: stackTrace,
          );
          sink.addError(errorObject, stackTrace);
        },
      ),
    );
  }

  Stream<Set<String>> watchRssInCollections(Set<int> collectionIds) {
    return _repository.watchRssInCollections(collectionIds);
  }

  Future<bool> createCollection(String name, {int? color}) async {
    try {
      await _repository.createCollection(name, color: color);
      _lastError = null;
      return true;
    } on PoddrException catch (e, stackTrace) {
      error('Failed to create collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e.userMessage;
      _notify();
      return false;
    } catch (e, stackTrace) {
      error('Failed to create collection unexpectedly',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = 'The collection could not be created. Please try again.';
      _notify();
      return false;
    }
  }

  Future<bool> updateCollectionName(int id, String name) async {
    try {
      await _repository.updateCollectionName(id, name);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to rename collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection could not be renamed. Please try again.';
      _notify();
      return false;
    }
  }

  Future<bool> updateCollectionColor(int id, int color) async {
    try {
      await _repository.updateCollectionColor(id, color);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to update collection color',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection color could not be updated. Please try again.';
      _notify();
      return false;
    }
  }

  Future<bool> deleteCollection(int id) async {
    try {
      await _repository.deleteCollection(id);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to delete collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection could not be deleted. Please try again.';
      _notify();
      return false;
    }
  }

  Future<bool> addToCollection(int collectionId, String rss) async {
    try {
      await _repository.linkCollectionToSubscription(collectionId, rss);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to add subscription to collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The podcast could not be added to this collection. '
              'Please try again.';
      _notify();
      return false;
    }
  }

  Future<bool> removeFromCollection(int collectionId, String rss) async {
    try {
      await _repository.unlinkCollectionFromSubscription(collectionId, rss);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to remove subscription from collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The podcast could not be removed from this collection. '
              'Please try again.';
      _notify();
      return false;
    }
  }
}
