import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/providers.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_creation_controller.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_preview_controller.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
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
    createdAt: DateTime(2026, 11, 3),
  );

  late FakeStoryRepository stories;
  late FakeImageFileStore files;
  late FakeIllustrator flux;
  late String id;

  // ── Make one READY story; FLUX fails for the prompts in [fluxFails] ──
  Future<ProviderContainer> makeReadyStory(Set<String> fluxFails) async {
    stories = FakeStoryRepository();
    files = FakeImageFileStore();
    flux = FakeIllustrator(failPrompts: fluxFails);
    final children = FakeChildRepository();
    children.saved.add(zayan);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedInUserId: 'parent-1'),
        ),
        childRepositoryProvider.overrideWithValue(children),
        storyRepositoryProvider.overrideWithValue(stories),
        storyGenerationServiceProvider.overrideWithValue(FakeStoryGenerator()),
        illustrationServiceProvider.overrideWithValue(flux),
        fallbackIllustrationServiceProvider.overrideWithValue(
          FakeIllustrator(source: 'PLACEHOLDER'),
        ),
        imageFileStoreProvider.overrideWithValue(files),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(storyCreationControllerProvider.notifier)
        .create(text: '', value: 'Sharing', child: zayan);
    id = stories.stories.keys.single;
    return container;
  }

  // ── Load ──
  test('loads the story, its scenes and its child', () async {
    final container = await makeReadyStory({});

    final preview = await container.read(
      storyPreviewControllerProvider(id).future,
    );

    expect(preview.story.title, 'Mango Shares the Ball');
    expect(preview.scenes, hasLength(3));
    expect(preview.child.name, 'Zayan');
    expect(preview.placeholderCount, 0);
  });

  // ── Approve and delete (FR-STORY-07) ──
  test('approve marks the story approved', () async {
    final container = await makeReadyStory({});
    final provider = storyPreviewControllerProvider(id);
    final keepAlive = container.listen(provider, (previous, next) {});
    addTearDown(keepAlive.close);
    await container.read(provider.future);

    await container.read(provider.notifier).approve();

    expect(stories.stories[id]!.approved, isTrue);
    expect(container.read(provider).value!.story.approved, isTrue);
  });

  test('delete removes the story and its picture files', () async {
    final container = await makeReadyStory({});
    final provider = storyPreviewControllerProvider(id);
    final keepAlive = container.listen(provider, (previous, next) {});
    addTearDown(keepAlive.close);
    await container.read(provider.future);

    await container.read(provider.notifier).delete();

    expect(stories.stories, isEmpty);
    expect(files.deletedPaths, files.savedPaths);
  });

  // ── Draw simple pictures again (FR-ILLUS-06) ──
  test('redraw gives placeholder scenes a FLUX picture', () async {
    final container = await makeReadyStory({'giving'});
    final provider = storyPreviewControllerProvider(id);
    final keepAlive = container.listen(provider, (previous, next) {});
    addTearDown(keepAlive.close);
    expect((await container.read(provider.future)).placeholderCount, 1);
    flux.failPrompts.clear();

    final stillSimple = await container
        .read(provider.notifier)
        .redrawPictures();

    expect(stillSimple, 0);
    expect(stories.scenes[id]![1].imageSource, 'FLUX');
    expect(files.deletedPaths, ['/fake/story_images/$id-scene-2.png']);
  });

  test('redraw while FLUX still fails keeps the simple picture', () async {
    final container = await makeReadyStory({'giving'});
    final provider = storyPreviewControllerProvider(id);
    final keepAlive = container.listen(provider, (previous, next) {});
    addTearDown(keepAlive.close);
    await container.read(provider.future);

    final stillSimple = await container
        .read(provider.notifier)
        .redrawPictures();

    expect(stillSimple, 1);
    expect(container.read(provider).value!.isRedrawing, isFalse);
  });
}
