import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/providers.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_creation_controller.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_story_generator.dart';
import '../../fakes/fake_story_repository.dart';

void main() {
  final zayan = ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Zayan',
    buddyId: 'mango',
    ageGroup: AgeGroup.listener,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 2),
  );

  ProviderContainer makeContainer(
    FakeStoryRepository stories,
    FakeStoryGenerator generator,
  ) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedInUserId: 'parent-1'),
        ),
        storyRepositoryProvider.overrideWithValue(stories),
        storyGenerationServiceProvider.overrideWithValue(generator),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ── Happy path ──
  test('saves a DRAFT first, then GENERATING, then READY', () async {
    final stories = FakeStoryRepository();
    var draftSavedBeforeCall = false;
    final generator = FakeStoryGenerator(
      onCall: () => draftSavedBeforeCall = stories.stories.isNotEmpty,
    );
    final container = makeContainer(stories, generator);

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(
          text: 'Zayan will not share his toys',
          value: 'Sharing',
          child: zayan,
        );

    final state = container.read(storyCreationControllerProvider);
    expect(draftSavedBeforeCall, isTrue);
    expect(stories.statusHistory, [StoryStatus.generating, StoryStatus.ready]);
    expect(state.value?.title, 'Mango Shares the Ball');
    expect(state.value?.status, StoryStatus.ready);
  });

  // ── Real name never reaches the story model (FR-STORY-08) ──
  test('the prompt uses the buddy name, not the child name', () async {
    final generator = FakeStoryGenerator();
    final container = makeContainer(FakeStoryRepository(), generator);

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: 'Zayan will not share his toys', value: '', child: zayan);

    expect(generator.prompts.single.behaviour, 'Mango will not share his toys');
    expect(generator.prompts.single.buddyAnimal, 'fox');
  });

  // ── Failure and retry ──
  test('a failure marks FAILED and keeps a plain message', () async {
    final stories = FakeStoryRepository();
    final generator = FakeStoryGenerator(failuresBeforeSuccess: 1);
    final container = makeContainer(stories, generator);

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Kindness', child: zayan);

    final state = container.read(storyCreationControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error.toString(), contains('Please try again'));
    expect(stories.stories.values.single.status, StoryStatus.failed);
  });

  test('retry uses the same story and the same prompt', () async {
    final stories = FakeStoryRepository();
    final generator = FakeStoryGenerator(failuresBeforeSuccess: 1);
    final container = makeContainer(stories, generator);
    final controller = container.read(storyCreationControllerProvider.notifier);

    await controller.create(text: '', value: 'Kindness', child: zayan);
    await controller.retry();

    expect(stories.stories.length, 1);
    expect(stories.statusHistory, [
      StoryStatus.generating,
      StoryStatus.failed,
      StoryStatus.generating,
      StoryStatus.ready,
    ]);
    expect(generator.prompts[0].value, generator.prompts[1].value);
    expect(container.read(storyCreationControllerProvider).hasValue, isTrue);
  });
}
