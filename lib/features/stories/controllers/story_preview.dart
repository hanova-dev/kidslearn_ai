import '../../../data/models/child_profile.dart';
import '../../../data/models/scene.dart';
import '../../../data/models/story.dart';

/// What the Story preview screen shows: one story, its scenes and its child.
class StoryPreview {
  const StoryPreview({
    required this.story,
    required this.scenes,
    required this.child,
    this.isRedrawing = false,
  });

  final Story story;
  final List<Scene> scenes;
  final ChildProfile child;

  /// True while "Draw pictures again" is running.
  final bool isRedrawing;

  /// How many scenes still use the simple placeholder picture.
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
