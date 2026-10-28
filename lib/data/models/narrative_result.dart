import 'narrative_scene.dart';

/// The whole story from the story model (FR-STORY-02).
class NarrativeResult {
  const NarrativeResult({
    required this.title,
    required this.moralValue,
    required this.characterSheet,
    required this.scenes,
  });

  final String title;
  final String moralValue;

  /// Fixed look of the hero, put before every image prompt (FR-ILLUS-01).
  final String characterSheet;
  final List<NarrativeScene> scenes;

  /// Builds the result from the model's JSON answer.
  factory NarrativeResult.fromMap(Map<String, dynamic> map) {
    final scenes = <NarrativeScene>[];
    for (final item in map['scenes'] as List<dynamic>) {
      scenes.add(NarrativeScene.fromMap(item as Map<String, dynamic>));
    }
    return NarrativeResult(
      title: map['title'] as String,
      moralValue: map['moral_value'] as String,
      characterSheet: map['character_sheet'] as String,
      scenes: scenes,
    );
  }
}
