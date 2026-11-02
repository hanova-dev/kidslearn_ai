import '../../../data/models/scene.dart';
import '../../../data/models/story.dart';

/// Where the story creation is now (shown on the Story generating screen).
enum CreationStep { idle, writing, drawing, ready, failed }

/// What the Story generating screen needs to know at one moment.
class StoryCreation {
  const StoryCreation({
    required this.step,
    this.story,
    this.scenes = const [],
    this.message = '',
  });

  final CreationStep step;

  /// Null until the draft is saved.
  final Story? story;

  /// The story's scenes; drawn ones have an image path (FR-ILLUS-03).
  final List<Scene> scenes;

  /// Plain-language problem text when [step] is failed (NFR-USE-03).
  final String message;

  /// How many scenes already have a picture.
  int get drawnCount {
    var count = 0;
    for (final scene in scenes) {
      if (scene.imagePath != null) {
        count++;
      }
    }
    return count;
  }

  /// How many pictures are the placeholder instead of FLUX (FR-ILLUS-06).
  int get placeholderCount {
    var count = 0;
    for (final scene in scenes) {
      if (scene.imageSource == 'PLACEHOLDER') {
        count++;
      }
    }
    return count;
  }
}
