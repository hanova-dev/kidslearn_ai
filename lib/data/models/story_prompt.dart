/// What the story model receives. It is already redacted: no real names (FR-STORY-08).
class StoryPrompt {
  const StoryPrompt({
    required this.behaviour,
    required this.value,
    required this.language,
    required this.buddyName,
    required this.buddyAnimal,
  });

  /// The parent's description with the child's name replaced by the buddy name.
  final String behaviour;

  /// The chosen value, e.g. 'Sharing'; empty when none was picked.
  final String value;

  /// 'en' this semester (decision 005).
  final String language;

  final String buddyName;
  final String buddyAnimal;
}
