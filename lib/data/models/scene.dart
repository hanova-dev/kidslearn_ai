import 'dart:convert';

import '../../algorithms/motion_directive_parser.dart';
import 'motion_directive.dart';

/// One illustrated panel of a story (SRS 6.2 scenes).
class Scene {
  const Scene({
    required this.id,
    required this.storyId,
    required this.sequenceNumber,
    required this.text,
    required this.imagePrompt,
    required this.imagePath,
    required this.imageSource,
    this.motion = MotionDirective.calm,
  });

  final String id;
  final String storyId;

  /// 1 for the first scene, 2 for the second, ...
  final int sequenceNumber;
  final String text;
  final String imagePrompt;

  /// File path of the picture on the phone; null until it is drawn (M3).
  final String? imagePath;

  /// 'FLUX' or 'PLACEHOLDER'; null until it is drawn (FR-ILLUS-06).
  final String? imageSource;

  /// How the page moves; calm for old stories (M11, decision 033).
  final MotionDirective motion;

  // ── To SQLite row ──
  /// Converts this scene to a map whose keys are the SQLite column names.
  Map<String, Object?> toMap() {
    return {
      'scene_id': id,
      'story_id': storyId,
      'sequence_number': sequenceNumber,
      'text': text,
      'image_prompt': imagePrompt,
      'image_path': imagePath,
      'image_source': imageSource,
      'motion_json': jsonEncode(motion.toMap()),
    };
  }

  // ── From SQLite row ──
  /// Builds a scene from one SQLite row.
  factory Scene.fromMap(Map<String, Object?> map) {
    final text = map['text'] as String;
    return Scene(
      id: map['scene_id'] as String,
      storyId: map['story_id'] as String,
      sequenceNumber: map['sequence_number'] as int,
      text: text,
      imagePrompt: map['image_prompt'] as String,
      imagePath: map['image_path'] as String?,
      imageSource: map['image_source'] as String?,
      motion: MotionDirectiveParser.parseJson(
        map['motion_json'] as String?,
        text,
      ),
    );
  }
}
