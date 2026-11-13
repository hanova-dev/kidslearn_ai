import '../app/app_config.dart';
import '../data/models/child_profile.dart';
import '../data/models/story_prompt.dart';

/// Builds safe, redacted story prompts (FR-STORY-08, CLAUDE.md §8). Pure Dart.
class StoryPromptBuilder {
  // ── Story shape and safety rules for the model ──
  static const String systemPrompt =
      'You write warm, gentle picture-book stories for children aged 2 to 7. '
      'Write exactly ${AppConfig.scenesPerStory} scenes. '
      'Each scene is ONE complete sentence of 6 to 15 words that a '
      '5-year-old can read aloud: common words, no rare words, and no '
      'missing little words such as "the" or "a". '
      'The ${AppConfig.scenesPerStory} sentences tell one connected story, '
      'and each one follows from the one before: '
      '1) meet the hero and show what they are doing; '
      '2) a small everyday problem from the request begins; '
      '3) the hero shows how they feel, and a friend or family member notices; '
      '4) the hero gets a kind idea or some help and tries; '
      '5) the hero does the good thing, and something nice happens because of it; '
      'the good thing is the lesson itself, for example waiting for Patience '
      'or giving a turn for Sharing; '
      '6) a happy ending that shows the lesson without saying "the lesson is". '
      'Use joining words such as but, so, then and because. '
      'At most one scene may contain a short line of speech in quotation marks. '
      'A friend is an animal with a short, easy name you invent yourself; '
      'introduce the friend before they act and keep the name the same. '
      'Call family members Mum, Dad, Grandma, Grandpa or baby sister, '
      'never by a name. '
      'The hero is the buddy named in the request and is always the same animal. '
      'If only a lesson is given, invent a small everyday problem that teaches it. '
      'Feelings such as unsure, grumpy or worried are fine, but resolve them kindly. '
      'Never include violence, danger, scary creatures, unkind words, '
      'sadness that is not resolved, or adult themes. '
      "Do not use any real person's name. "
      'The title has 2 to 5 words. The moral_value is one short sentence. '
      'The character_sheet is one sentence describing how the hero looks '
      '(animal, colours, clothes); it stays the same in every scene. '
      'Each image_prompt describes only what is visible in that scene, '
      'with no text or letters in the picture.';

  // ── Name redaction ──
  /// Replaces every whole-word use of [childName] (and each part of it) with [buddyName].
  static String redactName(String text, String childName, String buddyName) {
    final fullName = childName.trim();
    if (fullName.isEmpty) {
      return text;
    }
    var result = _replaceWord(text, fullName, buddyName);
    for (final part in fullName.split(' ')) {
      if (part.length >= 2) {
        result = _replaceWord(result, part, buddyName);
      }
    }
    return result;
  }

  static String _replaceWord(String text, String word, String replacement) {
    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );
    return text.replaceAll(pattern, replacement);
  }

  // ── Build the prompt ──
  /// Turns the parent's input into a [StoryPrompt] with no real name in it.
  static StoryPrompt build({
    required String parentText,
    required String value,
    required ChildProfile child,
    required String buddyName,
    required String buddyAnimal,
  }) {
    return StoryPrompt(
      behaviour: redactName(parentText.trim(), child.name, buddyName),
      value: value,
      language: child.language,
      buddyName: buddyName,
      buddyAnimal: buddyAnimal,
    );
  }

  // ── Picture prompt text (no buddy name) ──
  /// Replaces the buddy name with `the <animal>`, so FLUX does not write the name in the picture.
  static String imageText(String text, StoryPrompt prompt) {
    return redactName(text, prompt.buddyName, 'the ${prompt.buddyAnimal}');
  }

  // ── Message text sent to the model ──
  /// The user message: hero, lesson and situation, one per line (empty parts are left out).
  static String userMessage(StoryPrompt prompt) {
    final lines = <String>[
      'Hero: ${prompt.buddyName} the ${prompt.buddyAnimal}.',
    ];
    if (prompt.value.isNotEmpty) {
      lines.add('Lesson: ${prompt.value}.');
    }
    if (prompt.behaviour.isNotEmpty) {
      lines.add('Situation: ${prompt.behaviour}');
    }
    lines.add('Language: English.');
    return lines.join('\n');
  }
}
