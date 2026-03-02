import 'package:poddr/models/tag.dart';

abstract class ITagsRepository {
  Future<PodcastTag> createTag(String name, {int? color});
  Future<PodcastTag> getOrCreate(String name);
  Future<PodcastTag?> getTagById(int id);
  Future<PodcastTag?> getTagByName(String name);
  Future<List<PodcastTag>> getAllTags();
  Future<List<PodcastTag>> getTagsForSubscription(int subscriptionId);
  Future<void> updateTagColor(int id, int color);
  Future<void> deleteTag(int id);
  Future<void> linkTagToSubscription(int tagId, int subscriptionId);
  Future<void> unlinkTagFromSubscription(int tagId, int subscriptionId);

  Stream<List<PodcastTag>> watchAllTags();
  Stream<List<PodcastTag>> watchTagsForSubscription(int subscriptionId);
}
