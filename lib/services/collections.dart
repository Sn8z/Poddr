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

  List<PodcastCollection> _collections = [];
  List<PodcastCollection> get collections => _collections;

  AsyncState<List<PodcastCollection>> _collectionsState = const AsyncInitial();
  AsyncState<List<PodcastCollection>> get collectionsState => _collectionsState;

  Map<int, Set<int>> _subscriptionToCollections = {};
  Map<int, Set<int>> get subscriptionToCollections =>
      _subscriptionToCollections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  StreamSubscription? _pairsSubscription;

  final Map<int, Stream<List<PodcastCollection>>> _collectionStreams = {};

  Stream<List<PodcastCollection>> watchCollectionsForSubscription(
      int subscriptionId) {
    return _collectionStreams.putIfAbsent(subscriptionId, () {
      return _repository
          .watchCollectionsForSubscription(subscriptionId)
          .transform(
        StreamTransformer.fromHandlers(
          handleError: (errorObject, stackTrace, sink) {
            error(
              'Failed to watch collections for subscription $subscriptionId',
              name: logName,
              error: errorObject,
              stackTrace: stackTrace,
            );
            sink.addError(errorObject, stackTrace);
          },
        ),
      );
    });
  }

  CollectionsProvider({ICollectionsRepository? repository})
      : _repository = repository ?? DriftCollectionsRepository() {
    loadCollections();
    _initSubscriptionCollectionWatcher();
  }

  void _initSubscriptionCollectionWatcher() {
    _pairsSubscription =
        _repository.watchAllSubscriptionCollectionPairs().listen(
      (pairs) {
        _subscriptionToCollections = pairs;
        notifyListeners();
      },
      onError: (Object e, StackTrace stackTrace) {
        error(
          'Failed to watch collection membership',
          name: logName,
          error: e,
          stackTrace: stackTrace,
        );
      },
    );
  }

  @override
  void dispose() {
    _pairsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCollections() async {
    _isLoading = true;
    _collectionsState = const AsyncLoading();
    notifyListeners();

    try {
      final collections = await _repository.getAllCollections();
      final pairs = await _repository.getAllSubscriptionCollectionPairs();
      _collections = collections;
      _subscriptionToCollections = pairs;
      _collectionsState = AsyncData(collections);
      _lastError = null;
    } on PoddrException catch (e, stackTrace) {
      error('Failed to load collections',
          name: logName, error: e, stackTrace: stackTrace);
      _collectionsState = AsyncError(e.userMessage);
    } catch (e, stackTrace) {
      error('Failed to load collections unexpectedly',
          name: logName, error: e, stackTrace: stackTrace);
      _collectionsState = const AsyncError(
        'Collections could not be loaded. Please try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateCollections(List<PodcastCollection> collections) {
    _collections = collections;
    _collectionsState = AsyncData(collections);
  }

  Future<bool> createCollection(String name, {int? color}) async {
    try {
      final collection = await _repository.createCollection(name, color: color);
      _updateCollections([..._collections, collection]);
      _lastError = null;
      notifyListeners();
      return true;
    } on PoddrException catch (e, stackTrace) {
      error('Failed to create collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e.userMessage;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      error('Failed to create collection unexpectedly',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = 'The collection could not be created. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCollectionName(int id, String name) async {
    try {
      await _repository.updateCollectionName(id, name);
      _updateCollections([
        for (final collection in _collections)
          collection.id == id
              ? collection.copyWith(name: name.trim())
              : collection,
      ]);
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      error('Failed to rename collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection could not be renamed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCollectionColor(int id, int color) async {
    try {
      await _repository.updateCollectionColor(id, color);
      _updateCollections([
        for (final collection in _collections)
          collection.id == id ? collection.copyWith(color: color) : collection,
      ]);
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      error('Failed to update collection color',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection color could not be updated. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCollection(int id) async {
    try {
      await _repository.deleteCollection(id);
      _updateCollections(
        _collections.where((collection) => collection.id != id).toList(),
      );
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      error('Failed to delete collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The collection could not be deleted. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSubscriptionToCollection(
      int subscriptionId, int collectionId) async {
    try {
      await _repository.linkCollectionToSubscription(
          collectionId, subscriptionId);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to add subscription to collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The podcast could not be added to this collection. '
              'Please try again.';
      return false;
    }
  }

  Future<bool> removeSubscriptionFromCollection(
      int subscriptionId, int collectionId) async {
    try {
      await _repository.unlinkCollectionFromSubscription(
          collectionId, subscriptionId);
      _lastError = null;
      return true;
    } catch (e, stackTrace) {
      error('Failed to remove subscription from collection',
          name: logName, error: e, stackTrace: stackTrace);
      _lastError = e is PoddrException
          ? e.userMessage
          : 'The podcast could not be removed from this collection. '
              'Please try again.';
      return false;
    }
  }
}
