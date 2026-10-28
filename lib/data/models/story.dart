import 'story_status.dart';

/// One story for one child (SRS 6.2 stories, decisions 002 and 018).
class Story {
  const Story({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.promptText,
    required this.promptValue,
    required this.title,
    required this.moralValue,
    required this.language,
    required this.characterSheet,
    required this.seed,
    required this.status,
    required this.approved,
    required this.createdAt,
  });

  final String id;
  final String parentId;
  final String childId;

  /// The parent's own words, kept so the story can be regenerated (FR-STORY-06).
  final String promptText;

  /// The value chip the parent picked, e.g. 'Sharing'; may be empty.
  final String promptValue;

  /// Empty until the story model answers.
  final String title;
  final String moralValue;
  final String language;
  final String characterSheet;

  /// Kept for future image models; FLUX on Workers AI ignores it (decision 012).
  final int seed;
  final StoryStatus status;

  /// Only approved stories reach the child (FR-STORY-07).
  final bool approved;
  final DateTime createdAt;

  // ── To SQLite row ──
  /// Converts this story to a map whose keys are the SQLite column names.
  Map<String, Object> toMap() {
    return {
      'story_id': id,
      'parent_id': parentId,
      'child_id': childId,
      'prompt_text': promptText,
      'prompt_value': promptValue,
      'title': title,
      'moral_value': moralValue,
      'language': language,
      'character_sheet': characterSheet,
      'seed': seed,
      'status': status.dbValue,
      'approved': approved ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // ── From SQLite row ──
  /// Builds a story from one SQLite row.
  factory Story.fromMap(Map<String, Object?> map) {
    return Story(
      id: map['story_id'] as String,
      parentId: map['parent_id'] as String,
      childId: map['child_id'] as String,
      promptText: map['prompt_text'] as String,
      promptValue: map['prompt_value'] as String,
      title: map['title'] as String,
      moralValue: map['moral_value'] as String,
      language: map['language'] as String,
      characterSheet: map['character_sheet'] as String,
      seed: map['seed'] as int,
      status: StoryStatus.fromDbValue(map['status'] as String),
      approved: map['approved'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
