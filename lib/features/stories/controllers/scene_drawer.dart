import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/local/image_file_store.dart';
import '../../../data/models/scene.dart';
import '../../../data/models/scene_image.dart';
import '../../../data/models/story_prompt.dart';
import '../../../data/story_repository.dart';
import '../../../services/illustration_service.dart';
import '../../../services/story_prompt_builder.dart';

/// Draws one scene, saves the picture file and records it in SQLite.
///
/// FR-ILLUS-01, FR-ILLUS-02, FR-ILLUS-06. Used for new stories, new versions and redraws.
class SceneDrawer {
  SceneDrawer({
    required this.illustrator,
    required this.fallback,
    required this.files,
    required this.stories,
  });

  final IllustrationService illustrator;
  final IllustrationService fallback;
  final ImageFileStore files;
  final StoryRepository stories;

  /// Draws [scene] with FLUX, or the simple picture if FLUX fails.
  Future<void> draw(
    Scene scene,
    String characterSheet,
    StoryPrompt prompt,
    int seed,
  ) async {
    // ── Keep the buddy name out of the picture prompt (decision 021) ──
    final scenePrompt = StoryPromptBuilder.imageText(scene.imagePrompt, prompt);
    final sheet = StoryPromptBuilder.imageText(characterSheet, prompt);

    // ── FLUX first, placeholder if FLUX fails (FR-ILLUS-06) ──
    SceneImage image;
    try {
      image = await illustrator.renderScene(scenePrompt, sheet, seed);
    } catch (error) {
      image = await fallback.renderScene(scenePrompt, sheet, seed);
    }

    // ── Save image file, path in SQLite (FR-ILLUS-02) ──
    final path = await files.save(scene.id, image);
    await stories.saveSceneImage(scene.id, path, image.source);

    // ── Remove the old picture if it had a different file name ──
    final oldPath = scene.imagePath;
    if (oldPath != null && oldPath != path) {
      await files.delete(oldPath);
    }
  }
}

/// Gives controllers a [SceneDrawer] wired to the adapters chosen in providers.dart.
final sceneDrawerProvider = Provider<SceneDrawer>((ref) {
  return SceneDrawer(
    illustrator: ref.watch(illustrationServiceProvider),
    fallback: ref.watch(fallbackIllustrationServiceProvider),
    files: ref.watch(imageFileStoreProvider),
    stories: ref.watch(storyRepositoryProvider),
  );
});
