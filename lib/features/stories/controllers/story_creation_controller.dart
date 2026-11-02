import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/errors/story_generation_failure.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/models/scene.dart';
import '../../../data/models/scene_image.dart';
import '../../../data/models/story.dart';
import '../../../data/models/story_prompt.dart';
import '../../../data/models/story_status.dart';
import '../../../services/story_prompt_builder.dart';
import 'story_creation.dart';

/// Creates one story: DRAFT → GENERATING (write, then draw) → READY or FAILED.
///
/// FR-STORY-03, FR-STORY-04, FR-ILLUS-01..04, FR-ILLUS-06.
class StoryCreationController extends Notifier<StoryCreation> {
  StoryPrompt? _prompt;

  @override
  StoryCreation build() {
    return const StoryCreation(step: CreationStep.idle);
  }

  /// Saves a draft for [child], writes the story, then draws every scene.
  Future<void> create({
    required String text,
    required String value,
    required ChildProfile child,
  }) async {
    state = const StoryCreation(step: CreationStep.writing);

    // ── Save draft story to SQLite (before the network call) ──
    final parentId = ref.read(authRepositoryProvider).currentUserId ?? '';
    final now = DateTime.now();
    final draft = Story(
      id: 'story-${now.microsecondsSinceEpoch}',
      parentId: parentId,
      childId: child.id,
      promptText: text.trim(),
      promptValue: value,
      title: '',
      moralValue: '',
      language: child.language,
      characterSheet: '',
      seed: now.millisecondsSinceEpoch % 1000000,
      status: StoryStatus.draft,
      approved: false,
      createdAt: now,
    );
    try {
      await ref.read(storyRepositoryProvider).saveDraft(draft);
    } catch (error) {
      _fail('Could not save the story. Please try again.');
      return;
    }

    // ── Build the redacted prompt (no real name) ──
    final buddy = Buddies.byId(child.buddyId);
    _prompt = StoryPromptBuilder.build(
      parentText: text,
      value: value,
      child: child,
      buddyName: buddy.name,
      buddyAnimal: buddy.animal,
    );
    state = StoryCreation(step: CreationStep.writing, story: draft);
    await _writeAndDraw(draft.id);
  }

  /// Tries the last failed story again with the same prompt (FR-STORY-04).
  Future<void> retry() async {
    final story = state.story;
    if (story == null || _prompt == null) {
      return;
    }
    state = StoryCreation(step: CreationStep.writing, story: story);
    await _writeAndDraw(story.id);
  }

  // ── Write the story, draw the scenes, mark READY ──
  Future<void> _writeAndDraw(String storyId) async {
    final repository = ref.read(storyRepositoryProvider);
    try {
      await repository.updateStatus(storyId, StoryStatus.generating);
      final narrative = await ref
          .read(storyGenerationServiceProvider)
          .generateNarrative(_prompt!);
      await repository.saveNarrative(storyId, narrative);
      await _showProgress(storyId, CreationStep.drawing);

      final scenes = await repository.getScenes(storyId);
      for (final scene in scenes) {
        await _drawScene(scene, narrative.characterSheet);
        await _showProgress(storyId, CreationStep.drawing);
      }

      await repository.updateStatus(storyId, StoryStatus.ready);
      await _showProgress(storyId, CreationStep.ready);
    } catch (error) {
      await _markFailed(storyId);
      _fail(_friendly(error));
    }
  }

  // ── Draw one scene: FLUX first, placeholder if FLUX fails (FR-ILLUS-06) ──
  Future<void> _drawScene(Scene scene, String characterSheet) async {
    final seed = state.story?.seed ?? 0;
    SceneImage image;
    try {
      image = await ref
          .read(illustrationServiceProvider)
          .renderScene(scene.imagePrompt, characterSheet, seed);
    } catch (error) {
      image = await ref
          .read(fallbackIllustrationServiceProvider)
          .renderScene(scene.imagePrompt, characterSheet, seed);
    }

    // ── Save image file, path in SQLite (FR-ILLUS-02) ──
    final path = await ref.read(imageFileStoreProvider).save(scene.id, image);
    await ref
        .read(storyRepositoryProvider)
        .saveSceneImage(scene.id, path, image.source);
  }

  // ── Reload story and scenes so the screen shows the latest ──
  Future<void> _showProgress(String storyId, CreationStep step) async {
    final repository = ref.read(storyRepositoryProvider);
    state = StoryCreation(
      step: step,
      story: await repository.getStory(storyId),
      scenes: await repository.getScenes(storyId),
    );
  }

  // ── Mark FAILED so the story can be retried later ──
  Future<void> _markFailed(String storyId) async {
    try {
      await ref
          .read(storyRepositoryProvider)
          .updateStatus(storyId, StoryStatus.failed);
    } catch (error) {
      return;
    }
  }

  void _fail(String message) {
    state = StoryCreation(
      step: CreationStep.failed,
      story: state.story,
      message: message,
    );
  }

  String _friendly(Object error) {
    if (error is StoryGenerationFailure) {
      return error.message;
    }
    return 'Something went wrong while making the story. Please try again.';
  }
}

/// Gives the Create story and Story generating screens the [StoryCreationController].
final storyCreationControllerProvider =
    NotifierProvider<StoryCreationController, StoryCreation>(
      StoryCreationController.new,
    );
