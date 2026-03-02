import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/tags/tags_repository.dart';
import 'package:poddr/models/tag.dart';

class DriftTagsRepository implements ITagsRepository {
  final PoddrDatabase database = PoddrDatabase();

  DriftTagsRepository();

  int _generateRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    const saturation = 0.6;
    const lightness = 0.5;
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor().toARGB32();
  }

  @override
  Future<PodcastTag> createTag(String name, {int? color}) async {
    final trimmedName = name.trim();
    final tagColor = color ?? _generateRandomColor();

    final newTagId = await database.into(database.tags).insert(
          TagsCompanion.insert(
            name: trimmedName,
            color: tagColor,
          ),
        );

    final newTag = await (database.select(database.tags)
          ..where((t) => t.id.equals(newTagId)))
        .getSingle();

    return PodcastTag(
      id: newTag.id,
      name: newTag.name,
      color: newTag.color,
    );
  }

  @override
  Future<PodcastTag?> getTagById(int id) async {
    final tag = await (database.select(database.tags)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (tag == null) return null;
    return PodcastTag(id: tag.id, name: tag.name, color: tag.color);
  }

  @override
  Future<PodcastTag?> getTagByName(String name) async {
    final trimmedName = name.trim();
    final tag = await (database.select(database.tags)
          ..where((t) => t.name.equals(trimmedName)))
        .getSingleOrNull();
    if (tag == null) return null;
    return PodcastTag(id: tag.id, name: tag.name, color: tag.color);
  }

  @override
  Future<List<PodcastTag>> getAllTags() async {
    final allTags = await database.select(database.tags).get();
    return allTags.map((t) => PodcastTag(id: t.id, name: t.name, color: t.color)).toList();
  }

  @override
  Future<List<PodcastTag>> getTagsForSubscription(int subscriptionId) async {
    final query = database.select(database.tags).join([
      innerJoin(
        database.subscriptionTags,
        database.subscriptionTags.tagId.equalsExp(database.tags.id),
      ),
    ])
      ..where(database.subscriptionTags.subscriptionId.equals(subscriptionId));

    final results = await query.get();
    return results.map((row) {
      final tag = row.readTable(database.tags);
      return PodcastTag(id: tag.id, name: tag.name, color: tag.color);
    }).toList();
  }

  @override
  Future<void> updateTagColor(int id, int color) async {
    await (database.update(database.tags)..where((t) => t.id.equals(id)))
        .write(TagsCompanion(color: Value(color)));
  }

  @override
  Future<void> deleteTag(int id) async {
    await (database.delete(database.subscriptionTags)
          ..where((st) => st.tagId.equals(id)))
        .go();
    await (database.delete(database.tags)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> linkTagToSubscription(int tagId, int subscriptionId) async {
    await database.into(database.subscriptionTags).insert(
          SubscriptionTagsCompanion.insert(
            subscriptionId: subscriptionId,
            tagId: tagId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> unlinkTagFromSubscription(int tagId, int subscriptionId) async {
    await (database.delete(database.subscriptionTags)
          ..where((st) => st.tagId.equals(tagId) & st.subscriptionId.equals(subscriptionId)))
        .go();
  }

  @override
  Future<PodcastTag> getOrCreate(String name) async {
    final existing = await getTagByName(name);
    if (existing != null) {
      return existing;
    }
    return createTag(name);
  }

  @override
  Stream<List<PodcastTag>> watchAllTags() {
    return database.select(database.tags).watch().map(
      (tags) => tags.map((t) => PodcastTag(id: t.id, name: t.name, color: t.color)).toList(),
    );
  }

  @override
  Stream<List<PodcastTag>> watchTagsForSubscription(int subscriptionId) {
    final query = database.select(database.tags).join([
      innerJoin(
        database.subscriptionTags,
        database.subscriptionTags.tagId.equalsExp(database.tags.id),
      ),
    ])
      ..where(database.subscriptionTags.subscriptionId.equals(subscriptionId));

    return query.watch().map(
      (rows) => rows.map((row) {
        final tag = row.readTable(database.tags);
        return PodcastTag(id: tag.id, name: tag.name, color: tag.color);
      }).toList(),
    );
  }
}
