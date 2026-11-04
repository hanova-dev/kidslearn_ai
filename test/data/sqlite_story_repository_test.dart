import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/local/app_database.dart';
import 'package:kidslearn_ai/data/local/sqlite_story_repository.dart';
import 'package:kidslearn_ai/data/models/narrative_result.dart';
import 'package:kidslearn_ai/data/models/narrative_scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Story makeDraft(String id) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: "Zayan doesn't want to share",
    promptValue: 'Sharing',
    title: '',
    moralValue: '',
    language: 'en',
    characterSheet: '',
    seed: 42,
    status: StoryStatus.draft,
    approved: false,
    createdAt: DateTime(2026, 10, 28, 12),
  );
}

NarrativeResult makeNarrative(int sceneCount) {
  return NarrativeResult(
    title: 'Mango Learns to Share',
    moralValue: 'Sharing',
    characterSheet: 'Mango is an orange fox with a green scarf.',
    scenes: [
      for (var i = 1; i <= sceneCount; i++)
        NarrativeScene(text: 'Sentence $i.', imagePrompt: 'Picture $i.'),
    ],
  );
}

void main() {
  late Database db;
  late SqliteStoryRepository repository;

  // ── Fresh in-memory database (version 2) for every test ──
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.version,
        onCreate: AppDatabase.createTables,
      ),
    );
    repository = SqliteStoryRepository(db);
  });
  tearDown(() => db.close());

  // ── Draft first (FR-STORY-03) ──
  test('a draft is saved and read back with its prompt', () async {
    await repository.saveDraft(makeDraft('s1'));

    final story = await repository.getStory('s1');

    expect(story!.status, StoryStatus.draft);
    expect(story.promptText, "Zayan doesn't want to share");
    expect(story.approved, isFalse);
  });

  test('saveDraft refuses a story that is not DRAFT', () async {
    final notDraft = Story.fromMap({
      ...makeDraft('s2').toMap(),
      'status': StoryStatus.ready.dbValue,
    });

    expect(() => repository.saveDraft(notDraft), throwsStateError);
  });

  // ── Lifecycle (FR-STORY-04) ──
  test('DRAFT → GENERATING → READY is stored', () async {
    await repository.saveDraft(makeDraft('s3'));

    await repository.updateStatus('s3', StoryStatus.generating);
    await repository.updateStatus('s3', StoryStatus.ready);

    expect((await repository.getStory('s3'))!.status, StoryStatus.ready);
  });

  test('an illegal move throws and the status does not change', () async {
    await repository.saveDraft(makeDraft('s4'));

    await expectLater(
      repository.updateStatus('s4', StoryStatus.ready),
      throwsStateError,
    );
    expect((await repository.getStory('s4'))!.status, StoryStatus.draft);
  });

  // ── Narrative and scenes ──
  test('saveNarrative stores the title and scenes in reading order', () async {
    await repository.saveDraft(makeDraft('s5'));

    await repository.saveNarrative('s5', makeNarrative(6));

    final story = await repository.getStory('s5');
    final scenes = await repository.getScenes('s5');
    expect(story!.title, 'Mango Learns to Share');
    expect(story.characterSheet, contains('orange fox'));
    expect(scenes.length, 6);
    expect(scenes.first.sequenceNumber, 1);
    expect(scenes.last.text, 'Sentence 6.');
    expect(scenes.first.imagePath, isNull);
  });

  test('regenerating replaces the old scenes', () async {
    await repository.saveDraft(makeDraft('s6'));
    await repository.saveNarrative('s6', makeNarrative(6));

    await repository.saveNarrative('s6', makeNarrative(3));

    expect((await repository.getScenes('s6')).length, 3);
  });

  // ── Scene pictures (FR-ILLUS-02) ──
  test('saveSceneImage stores the file path and source', () async {
    await repository.saveDraft(makeDraft('s1'));
    await repository.saveNarrative('s1', makeNarrative(2));

    await repository.saveSceneImage(
      's1-scene-2',
      '/img/s1-scene-2.jpg',
      'FLUX',
    );

    final scenes = await repository.getScenes('s1');
    expect(scenes[0].imagePath, isNull);
    expect(scenes[1].imagePath, '/img/s1-scene-2.jpg');
    expect(scenes[1].imageSource, 'FLUX');
  });

  // ── Approve and delete (FR-STORY-07) ──
  test('setApproved stores the approval', () async {
    await repository.saveDraft(makeDraft('s1'));

    await repository.setApproved('s1', true);
    expect((await repository.getStory('s1'))!.approved, isTrue);

    await repository.setApproved('s1', false);
    expect((await repository.getStory('s1'))!.approved, isFalse);
  });

  test('deleteStory removes the story and its scenes only', () async {
    await repository.saveDraft(makeDraft('s1'));
    await repository.saveNarrative('s1', makeNarrative(2));
    await repository.saveDraft(makeDraft('s2'));

    await repository.deleteStory('s1');

    expect(await repository.getStory('s1'), isNull);
    expect(await repository.getScenes('s1'), isEmpty);
    expect(await repository.getStory('s2'), isNotNull);
  });

  test('an unknown story id gives null', () async {
    expect(await repository.getStory('nope'), isNull);
  });

  // ── Story library (design p9) ──
  test(
    'getStoriesForParent gives the stories of one parent, newest first',
    () async {
      await repository.saveDraft(makeDraft('old'));
      await repository.saveDraft(
        Story.fromMap({
          ...makeDraft('new').toMap(),
          'created_at': DateTime(2026, 11, 4).millisecondsSinceEpoch,
        }),
      );
      await repository.saveDraft(
        Story.fromMap({...makeDraft('other').toMap(), 'parent_id': 'parent-2'}),
      );

      final stories = await repository.getStoriesForParent('parent-1');

      expect(stories.map((story) => story.id).toList(), ['new', 'old']);
    },
  );

  // ── Stories stopped by an app close (decision 023) ──
  test(
    'failInterruptedStories turns DRAFT and GENERATING into FAILED',
    () async {
      await repository.saveDraft(makeDraft('draft'));
      await repository.saveDraft(makeDraft('generating'));
      await repository.updateStatus('generating', StoryStatus.generating);
      await repository.saveDraft(makeDraft('ready'));
      await repository.updateStatus('ready', StoryStatus.generating);
      await repository.updateStatus('ready', StoryStatus.ready);

      final count = await repository.failInterruptedStories();

      expect(count, 2);
      expect((await repository.getStory('draft'))!.status, StoryStatus.failed);
      expect(
        (await repository.getStory('generating'))!.status,
        StoryStatus.failed,
      );
      expect((await repository.getStory('ready'))!.status, StoryStatus.ready);
    },
  );
}
