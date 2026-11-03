import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/providers.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_creation.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_creation_controller.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_illustrator.dart';
import '../../fakes/fake_image_file_store.dart';
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

  late FakeStoryRepository stories;
  late FakeImageFileStore files;
  late FakeIllustrator placeholder;

  ProviderContainer makeContainer(
    FakeStoryGenerator generator, {
    FakeIllustrator? flux,
  }) {
    stories = FakeStoryRepository();
    files = FakeImageFileStore();
    placeholder = FakeIllustrator(source: 'PLACEHOLDER');
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedInUserId: 'parent-1'),
        ),
        storyRepositoryProvider.overrideWithValue(stories),
        storyGenerationServiceProvider.overrideWithValue(generator),
        illustrationServiceProvider.overrideWithValue(
          flux ?? FakeIllustrator(),
        ),
        fallbackIllustrationServiceProvider.overrideWithValue(placeholder),
        imageFileStoreProvider.overrideWithValue(files),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ── Happy path ──
  test('saves a DRAFT first, then GENERATING, then READY', () async {
    var draftSavedBeforeCall = false;
    final generator = FakeStoryGenerator(
      onCall: () => draftSavedBeforeCall = stories.stories.isNotEmpty,
    );
    final container = makeContainer(generator);

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
    expect(state.step, CreationStep.ready);
    expect(state.story?.title, 'Mango Shares the Ball');
    expect(state.story?.status, StoryStatus.ready);
  });

  // ── Every scene drawn and saved (FR-ILLUS-01, FR-ILLUS-02) ──
  test('every scene gets a FLUX picture file before READY', () async {
    final container = makeContainer(FakeStoryGenerator());

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Sharing', child: zayan);

    final state = container.read(storyCreationControllerProvider);
    expect(state.drawnCount, 3);
    expect(state.placeholderCount, 0);
    expect(files.savedPaths, hasLength(3));
    expect(state.scenes.first.imagePath, files.savedPaths.first);
    expect(state.scenes.first.imageSource, 'FLUX');
  });

  // ── One failed scene uses the placeholder (FR-ILLUS-06, NFR-REL-04) ──
  test('a failed FLUX scene gets the placeholder, story still READY', () async {
    final container = makeContainer(
      FakeStoryGenerator(),
      flux: FakeIllustrator(failPrompts: {'giving'}),
    );

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Sharing', child: zayan);

    final state = container.read(storyCreationControllerProvider);
    expect(state.step, CreationStep.ready);
    expect(state.drawnCount, 3);
    expect(state.placeholderCount, 1);
    expect(state.scenes[1].imageSource, 'PLACEHOLDER');
    expect(placeholder.drawnPrompts, ['giving']);
  });

  // ── Real name never reaches the story model (FR-STORY-08) ──
  test('the prompt uses the buddy name, not the child name', () async {
    final generator = FakeStoryGenerator();
    final container = makeContainer(generator);

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: 'Zayan will not share his toys', value: '', child: zayan);

    expect(generator.prompts.single.behaviour, 'Mango will not share his toys');
    expect(generator.prompts.single.buddyAnimal, 'fox');
  });

  // ── Buddy name is kept out of picture prompts (FLUX writes names) ──
  test('the picture prompt says "the fox", not the buddy name', () async {
    final flux = FakeIllustrator();
    final container = makeContainer(FakeStoryGenerator(), flux: flux);

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Sharing', child: zayan);

    expect(
      flux.drawnSheets.first,
      'the fox is a small orange fox with a blue scarf.',
    );
  });

  // ── Failure and retry ──
  test('a failure marks FAILED and keeps a plain message', () async {
    final container = makeContainer(
      FakeStoryGenerator(failuresBeforeSuccess: 1),
    );

    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Kindness', child: zayan);

    final state = container.read(storyCreationControllerProvider);
    expect(state.step, CreationStep.failed);
    expect(state.message, contains('Please try again'));
    expect(stories.stories.values.single.status, StoryStatus.failed);
  });

  test('retry uses the same story and the same prompt', () async {
    final generator = FakeStoryGenerator(failuresBeforeSuccess: 1);
    final container = makeContainer(generator);
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
    expect(
      container.read(storyCreationControllerProvider).step,
      CreationStep.ready,
    );
  });
}
