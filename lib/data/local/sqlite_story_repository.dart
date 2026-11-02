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
}
