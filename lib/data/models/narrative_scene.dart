import '../../algorithms/motion_directive_parser.dart';
import 'motion_directive.dart';

/// One scene from the story model: the page text, what to draw and how it moves.
class NarrativeScene {
  const NarrativeScene({
    required this.text,
    required this.imagePrompt,
    this.motion = MotionDirective.calm,
  });

  final String text;
  final String imagePrompt;

  /// Camera, focus, action, effect, mood and cue word (M11, decision 033).
  final MotionDirective motion;

  /// Builds a scene from the model's JSON (keys 'text', 'image_prompt' and 'motion').
  factory NarrativeScene.fromMap(Map<String, dynamic> map) {
    final text = map['text'] as String;
    return NarrativeScene(
      text: text,
      imagePrompt: map['image_prompt'] as String,
      motion: MotionDirectiveParser.parse(map['motion'], text),
    );
  }
}
