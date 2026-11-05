import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/scene.dart';
import '../../../data/models/story.dart';
import '../../../data/models/story_status.dart';

/// What the story viewer shows: one approved story and its scenes in order.
class StoryViewerData {
  const StoryViewerData({required this.story, required this.scenes});

  final Story story;
  final List<Scene> scenes;
}

/// Loads one story for the child; null if it is missing, not READY or not approved (FR-STORY-07).
final storyViewerProvider = FutureProvider.autoDispose
    .family<StoryViewerData?, String>((ref, storyId) async {
      final repository = ref.watch(storyRepositoryProvider);

      // ── Only approved, finished stories reach the child ──
      final story = await repository.getStory(storyId);
      if (story == null ||
          !story.approved ||
          story.status != StoryStatus.ready) {
        return null;
      }

      // ── Scenes in reading order ──
      final scenes = await repository.getScenes(storyId);
      if (scenes.isEmpty) {
        return null;
      }
      return StoryViewerData(story: story, scenes: scenes);
    });
