import '../../../app/app_config.dart';

/// Checks the Create story input before any network call (FR-STORY-05, decision 019).
class StoryInputCheck {
  /// Returns a friendly message, or null when [text] and [value] are good enough.
  static String? check(String text, String value) {
    final trimmed = text.trim();

    // ── Nothing given ──
    if (trimmed.isEmpty && value.isEmpty) {
      return 'Tell us what the story should teach, or pick a value.';
    }

    // ── Text given but too short or too long ──
    if (trimmed.isNotEmpty && trimmed.length < AppConfig.minPromptLength) {
      return 'Please write a little more (at least '
          '${AppConfig.minPromptLength} letters).';
    }
    if (trimmed.length > AppConfig.maxPromptLength) {
      return 'Please keep it shorter (at most '
          '${AppConfig.maxPromptLength} letters).';
    }
    return null;
  }
}
