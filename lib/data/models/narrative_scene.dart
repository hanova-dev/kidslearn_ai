/// One scene from the story model: the sentence and what to draw.
class NarrativeScene {
  const NarrativeScene({required this.text, required this.imagePrompt});

  final String text;
  final String imagePrompt;

  /// Builds a scene from the model's JSON (keys 'text' and 'image_prompt').
  factory NarrativeScene.fromMap(Map<String, dynamic> map) {
    return NarrativeScene(
      text: map['text'] as String,
      imagePrompt: map['image_prompt'] as String,
    );
  }
}
