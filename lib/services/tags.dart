import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:poddr/data/tags/drift_tags_repository.dart';
import 'package:poddr/data/tags/tags_repository.dart';
import 'package:poddr/models/tag.dart';

class TagsProvider extends ChangeNotifier {
  final String logName = "TagsProvider";
  final ITagsRepository _repository;

  List<PodcastTag> _tags = [];
  List<PodcastTag> get tags => _tags;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<PodcastTag>> get tagsStream => _repository.watchAllTags();

  TagsProvider({ITagsRepository? repository})
      : _repository = repository ?? DriftTagsRepository();

  Future<void> loadTags() async {
    try {
      _isLoading = true;
      notifyListeners();

      _tags = await _repository.getAllTags();
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PodcastTag?> createTag(String name, {int? color}) async {
    try {
      final tag = await _repository.createTag(name, color: color);
      await loadTags();
      return tag;
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> updateTagName(int id, String name) async {
    try {
      final tag = await _repository.getTagById(id);
      if (tag == null) return false;
      
      final updatedTag = tag.copyWith(name: name);
      await _repository.deleteTag(id);
      await _repository.createTag(updatedTag.name, color: updatedTag.color);
      await loadTags();
      return true;
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> updateTagColor(int id, int color) async {
    try {
      await _repository.updateTagColor(id, color);
      await loadTags();
      return true;
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> deleteTag(int id) async {
    try {
      await _repository.deleteTag(id);
      await loadTags();
      return true;
    } catch (error, stackTrace) {
      log(
        error.toString(),
        name: logName,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
