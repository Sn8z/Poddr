import 'package:flutter/foundation.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/data/collections/drift_collections_repository.dart';
import 'package:poddr/data/collections/collections_repository.dart';
import 'package:poddr/models/collection.dart';

class CollectionsProvider extends ChangeNotifier {
  final String logName = "CollectionsProvider";
  final ICollectionsRepository _repository;

  List<PodcastCollection> _collections = [];
  List<PodcastCollection> get collections => _collections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<PodcastCollection>> get collectionsStream => _repository.watchAllCollections();

  Stream<List<PodcastCollection>> watchCollectionsForSubscription(int subscriptionId) {
    return _repository.watchCollectionsForSubscription(subscriptionId);
  }

  CollectionsProvider({ICollectionsRepository? repository})
      : _repository = repository ?? DriftCollectionsRepository() {
    loadCollections();
  }

  Future<void> loadCollections() async {
    try {
      _isLoading = true;
      notifyListeners();

      _collections = await _repository.getAllCollections();
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PodcastCollection?> createCollection(String name, {int? color}) async {
    try {
      final collection = await _repository.createCollection(name, color: color);
      return collection;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> updateCollectionName(int id, String name) async {
    try {
      await _repository.updateCollectionName(id, name);
      return true;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> updateCollectionColor(int id, int color) async {
    try {
      await _repository.updateCollectionColor(id, color);
      return true;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> deleteCollection(int id) async {
    try {
      await _repository.deleteCollection(id);
      return true;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> addSubscriptionToCollection(int subscriptionId, int collectionId) async {
    try {
      await _repository.linkCollectionToSubscription(collectionId, subscriptionId);
      return true;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> removeSubscriptionFromCollection(int subscriptionId, int collectionId) async {
    try {
      await _repository.unlinkCollectionFromSubscription(collectionId, subscriptionId);
      return true;
    } catch (e, stackTrace) {
      error(e.toString(),
          name: logName, error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
