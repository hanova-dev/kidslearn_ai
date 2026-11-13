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

  /// Fixed looks of the hero and the friends, put before every image prompt (FR-ILLUS-01).
  final String characterSheet;
  final List<NarrativeScene> scenes;

  /// Builds the result from the model's JSON answer; pages come as page_1, page_2, … (decision 032).
  factory NarrativeResult.fromMap(Map<String, dynamic> map) {
    final pages = map['pages'] as Map<String, dynamic>;
    final scenes = <NarrativeScene>[];
    for (var number = 1; number <= pages.length; number++) {
      final page = pages['page_$number'] as Map<String, dynamic>;
      scenes.add(NarrativeScene.fromMap(page));
    }
    return NarrativeResult(
      title: map['title'] as String,
      moralValue: map['moral_value'] as String,
      characterSheet: map['character_sheet'] as String,
      scenes: scenes,
    );
  }
}
