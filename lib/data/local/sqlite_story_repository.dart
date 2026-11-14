import 'package:sqflite/sqflite.dart';

import '../models/narrative_result.dart';
import '../models/scene.dart';
import '../models/story.dart';
import '../models/story_status.dart';
import '../story_repository.dart';

/// [StoryRepository] that keeps stories and scenes in local SQLite.
class SqliteStoryRepository implements StoryRepository {
  SqliteStoryRepository(this._db);

  final Database _db;

  // ── Save draft ──
  @override
  Future<void> saveDraft(Story story) async {
    if (story.status != StoryStatus.draft) {
      throw StateError('A new story must start as DRAFT.');
    }
    await _db.insert('stories', story.toMap());
  }

  // ── Change status (the lifecycle rules live in StoryStatus) ──
  @override
  Future<void> updateStatus(String storyId, StoryStatus status) async {
    final story = await getStory(storyId);
    if (story == null) {
      throw StateError('Story $storyId not found.');
    }
    if (!story.status.canMoveTo(status)) {
      throw StateError(
        'Cannot move story from ${story.status.dbValue} to ${status.dbValue}.',
      );
    }
    await _db.update(
      'stories',
      {'status': status.dbValue},
      where: 'story_id = ?',
      whereArgs: [storyId],
    );
  }

  // ── Save the model's story and scenes in one transaction ──
  @override
  Future<void> saveNarrative(String storyId, NarrativeResult narrative) async {
    await _db.transaction((txn) async {
      await txn.update(
        'stories',
        {
          'title': narrative.title,
          'moral_value': narrative.moralValue,
          'character_sheet': narrative.characterSheet,
        },
        where: 'story_id = ?',
        whereArgs: [storyId],
      );
      await txn.delete('scenes', where: 'story_id = ?', whereArgs: [storyId]);
      for (var i = 0; i < narrative.scenes.length; i++) {
        final scene = Scene(
          id: '$storyId-scene-${i + 1}',
          storyId: storyId,
          sequenceNumber: i + 1,
          text: narrative.scenes[i].text,
          imagePrompt: narrative.scenes[i].imagePrompt,
          imagePath: null,
          imageSource: null,
          motion: narrative.scenes[i].motion,
        );
        await txn.insert('scenes', scene.toMap());
      }
    });
  }

  // ── Save a scene picture's file path ──
  @override
  Future<void> saveSceneImage(
    String sceneId,
    String imagePath,
    String source,
  ) async {
    await _db.update(
      'scenes',
      {'image_path': imagePath, 'image_source': source},
      where: 'scene_id = ?',
      whereArgs: [sceneId],
    );
  }

  // ── Approve ──
  @override
  Future<void> setApproved(String storyId, bool approved) async {
    await _db.update(
      'stories',
      {'approved': approved ? 1 : 0},
      where: 'story_id = ?',
      whereArgs: [storyId],
    );
  }

  // ── Delete story and its scenes in one transaction ──
  @override
  Future<void> deleteStory(String storyId) async {
    await _db.transaction((txn) async {
      await txn.delete('scenes', where: 'story_id = ?', whereArgs: [storyId]);
      await txn.delete('stories', where: 'story_id = ?', whereArgs: [storyId]);
    });
  }

  // ── Load ──
  @override
  Future<Story?> getStory(String storyId) async {
    final rows = await _db.query(
      'stories',
      where: 'story_id = ?',
      whereArgs: [storyId],
    );
    if (rows.isEmpty) {
      return null;
    }
    return Story.fromMap(rows.first);
  }

  @override
  Future<List<Scene>> getScenes(String storyId) async {
    final rows = await _db.query(
      'scenes',
      where: 'story_id = ?',
      whereArgs: [storyId],
      orderBy: 'sequence_number ASC',
    );
    final scenes = <Scene>[];
    for (final row in rows) {
      scenes.add(Scene.fromMap(row));
    }
    return scenes;
  }

  @override
  Future<List<Story>> getStoriesForParent(String parentId) async {
    final rows = await _db.query(
      'stories',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'created_at DESC',
    );
    final stories = <Story>[];
    for (final row in rows) {
      stories.add(Story.fromMap(row));
    }
    return stories;
  }

  @override
  Future<List<Story>> getApprovedStoriesForChild(String childId) async {
    final rows = await _db.query(
      'stories',
      where: 'child_id = ? AND approved = 1 AND status = ?',
      whereArgs: [childId, StoryStatus.ready.dbValue],
      orderBy: 'created_at ASC',
    );
    final stories = <Story>[];
    for (final row in rows) {
      stories.add(Story.fromMap(row));
    }
    return stories;
  }

  // ── Mark stories stopped by an app close as FAILED ──
  @override
  Future<int> failInterruptedStories() async {
    return _db.update(
      'stories',
      {'status': StoryStatus.failed.dbValue},
      where: 'status = ? OR status = ?',
      whereArgs: [StoryStatus.draft.dbValue, StoryStatus.generating.dbValue],
    );
  }
}
