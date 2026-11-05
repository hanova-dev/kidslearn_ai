import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/providers.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/reading/controllers/story_viewer_provider.dart';

import '../../fakes/fake_story_repository.dart';

Story makeStory(String id, StoryStatus status, bool approved) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: '',
    promptValue: 'Sharing',
    title: 'Story $id',
    moralValue: 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: status,
    approved: approved,
    createdAt: DateTime(2026, 11, 1),
  );
}

Scene makeScene(String storyId) {
  return Scene(
    id: '$storyId-scene-1',
    storyId: storyId,
    sequenceNumber: 1,
    text: 'Hello.',
    imagePrompt: '',
    imagePath: null,
    imageSource: null,
  );
}

void main() {
  late FakeStoryRepository stories;
  late ProviderContainer container;

  // ── A container with a fake story repository ──
  setUp(() {
    stories = FakeStoryRepository();
    for (final story in [
      makeStory('approved', StoryStatus.ready, true),
      makeStory('not-approved', StoryStatus.ready, false),
      makeStory('failed', StoryStatus.failed, true),
    ]) {
      stories.stories[story.id] = story;
      stories.scenes[story.id] = [makeScene(story.id)];
    }
    stories.stories['no-scenes'] = makeStory(
      'no-scenes',
      StoryStatus.ready,
      true,
    );
    container = ProviderContainer(
      overrides: [storyRepositoryProvider.overrideWithValue(stories)],
    );
  });
  tearDown(() => container.dispose());

  // ── Only approved READY stories reach the child (FR-STORY-07) ──
  test('an approved READY story loads with its scenes', () async {
    final data = await container.read(storyViewerProvider('approved').future);

    expect(data!.story.id, 'approved');
    expect(data.scenes.length, 1);
  });

  test('not approved, not READY, missing or empty stories give null', () async {
    for (final id in ['not-approved', 'failed', 'missing', 'no-scenes']) {
      final data = await container.read(storyViewerProvider(id).future);
      expect(data, isNull, reason: id);
    }
  });
}
