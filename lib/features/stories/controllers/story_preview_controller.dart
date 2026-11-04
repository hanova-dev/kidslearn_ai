import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/buddies.dart';
import '../../../data/models/child_profile.dart';
import '../../../services/story_prompt_builder.dart';
import 'scene_drawer.dart';
import 'story_preview.dart';

/// Loads one story for the parent to check, then approves, deletes or redraws it.
///
/// FR-STORY-07, FR-ILLUS-06.
class StoryPreviewController extends AsyncNotifier<StoryPreview> {
  StoryPreviewController(this.storyId);

  final String storyId;

  @override
  Future<StoryPreview> build() {
    return _load();
  }

  /// Lets the child see this story (FR-STORY-07).
  Future<void> approve() async {
    await ref.read(storyRepositoryProvider).setApproved(storyId, true);
    state = AsyncData(await _load());
  }

  /// Removes the story, its scenes and its picture files (FR-STORY-07).
  Future<void> delete() async {
    final preview = state.value;
    if (preview == null) {
      return;
    }
    for (final scene in preview.scenes) {
      final path = scene.imagePath;
      if (path != null) {
        await ref.read(imageFileStoreProvider).delete(path);
      }
    }
    await ref.read(storyRepositoryProvider).deleteStory(storyId);
  }

  /// Tries FLUX again for every scene with the simple picture; returns how many are still simple.
  Future<int> redrawPictures() async {
    final preview = state.value;
    if (preview == null || preview.isRedrawing) {
      return 0;
    }
    state = AsyncData(
      StoryPreview(
        story: preview.story,
        scenes: preview.scenes,
        child: preview.child,
        isRedrawing: true,
      ),
    );

    // ── Draw each placeholder scene again (FR-ILLUS-06) ──
    final buddy = Buddies.byId(preview.child.buddyId);
    final prompt = StoryPromptBuilder.build(
      parentText: preview.story.promptText,
      value: preview.story.promptValue,
      child: preview.child,
      buddyName: buddy.name,
      buddyAnimal: buddy.animal,
    );
    try {
      for (final scene in preview.scenes) {
        if (scene.imageSource == 'PLACEHOLDER') {
          await ref
              .read(sceneDrawerProvider)
              .draw(
                scene,
                preview.story.characterSheet,
                prompt,
                preview.story.seed,
              );
        }
      }
    } finally {
      state = AsyncData(await _load());
    }
    return state.requireValue.placeholderCount;
  }

  // ── Load story, scenes and child from SQLite ──
  Future<StoryPreview> _load() async {
    final repository = ref.read(storyRepositoryProvider);
    final story = await repository.getStory(storyId);
    if (story == null) {
      throw StateError('Story $storyId not found.');
    }
    final children = await ref
        .read(childRepositoryProvider)
        .getChildren(story.parentId);
    ChildProfile? child;
    for (final candidate in children) {
      if (candidate.id == story.childId) {
        child = candidate;
      }
    }
    if (child == null) {
      throw StateError('Child ${story.childId} not found.');
    }
    return StoryPreview(
      story: story,
      scenes: await repository.getScenes(storyId),
      child: child,
    );
  }
}

/// One controller per story id; it is thrown away when the preview screen closes.
final storyPreviewControllerProvider = AsyncNotifierProvider.autoDispose
    .family<StoryPreviewController, StoryPreview, String>(
      StoryPreviewController.new,
    );
