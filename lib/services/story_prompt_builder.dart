import '../app/app_config.dart';
import '../data/models/motion_directive.dart';
import '../data/models/child_profile.dart';
import '../data/models/story_prompt.dart';

/// Builds safe, redacted story prompts (FR-STORY-08, CLAUDE.md §8). Pure Dart.
class StoryPromptBuilder {
  // ── Story shape and safety rules for the model ──
  static final String systemPrompt =
      'You write warm, gentle picture-book stories for children aged 2 to 7. '
      'Write exactly ${AppConfig.scenesPerStory} pages, page_1 to '
      'page_${AppConfig.scenesPerStory}; each page has its own picture. '
      'Each page has 2 or 3 complete sentences, 20 to 40 words in total, '
      'in simple words a 5-year-old can follow and no rare words. '
      'The pages tell ONE connected little adventure, and each page follows '
      'from the page before: '
      'pages 1-2: meet the hero in one clear place, show what the hero loves '
      'or wants, and meet a friend; '
      'page 3: a small problem from the request begins; '
      'pages 4-6: the hero tries the wrong way, and two or three small, '
      'surprising things happen in a game, a search or a short trip; '
      'page 7: the hero feels unsure, grumpy or worried; '
      'page 8: the friend or a family member helps the hero think of a kind idea; '
      'pages 9-10: the hero does the good thing, and the good thing is the '
      'lesson itself, for example waiting for Patience or giving a turn for '
      'Sharing; then something lovely happens because of it; '
      'page 11: everyone celebrates together; '
      'page 12: a happy ending that links back to page 1 and shows the lesson '
      'without saying "the lesson is". '
      'Even for everyday topics such as bedtime, brushing teeth or eating, '
      'build a playful adventure around the topic, never a list of routines. '
      'Use joining words such as but, so, then and because, and let the '
      'characters speak: many pages may have a short line of speech in '
      'quotation marks. '
      'The hero is the buddy named in the request and is always the same animal; '
      'call the hero by name on page 1 and often after. '
      'Add one or two friends; each friend is a different kind of animal from '
      'the hero and from each other, with a fun, short name you invent '
      '(not Pip or Boo), introduced before they act, and the same on every page. '
      'Call family members Mum, Dad, Grandma, Grandpa or baby sister, '
      'never by a name; they are the same kind of animal as the hero '
      '(the baby sister of a fox is a baby fox). '
      'If only a lesson is given, invent a small everyday problem that teaches it. '
      'Feelings such as unsure, grumpy or worried are fine, but resolve them kindly. '
      'Never include violence, danger, scary creatures, unkind words, '
      'sadness that is not resolved, or adult themes. '
      "Do not use any real person's name. "
      'Each page also has a motion line for a gently moving picture: six '
      'words separated by spaces, in this order: camera focus '
      'character_action effect mood cue_word. Use only these words: '
      'camera is one of ${_wordsOf(MotionDirective.cameras)}, one slow, calm '
      'move that fits the moment; '
      'focus is one of ${_wordsOf(MotionDirective.focuses)}, where the most '
      'important thing is in the picture; '
      'character_action is one of ${_wordsOf(MotionDirective.characterActions)}, '
      'how the hero moves; '
      'effect is one of ${_wordsOf(MotionDirective.effects)}, and "none" unless '
      'the page shows it (rain only when it rains, stars only at night); '
      'mood is one of ${_wordsOf(MotionDirective.moods)}; '
      "cue_word is one word copied from that page's text, spoken when the "
      'camera should move to the focus, or - for none. '
      'Example: slow_zoom_in center bounce none happy ball. '
      'The title has 2 to 6 words. The moral_value is one short sentence. '
      'The character_sheet has one line for the hero, one for each friend '
      'and one for each family member who appears, separated by new lines; '
      'each line starts with the animal, for example "The fox:" or '
      '"The baby fox:", and gives size, colours and one piece of clothing, '
      'with no names. These looks never change. '
      'Each image_prompt describes one clear moment of that page and names '
      'only the characters who are in that moment, each with the same animal '
      'words as in the character_sheet (for example "the fox", "the baby fox"), '
      'never by name; then what they are doing, the place and the time of day. '
      'Keep the same place details on every page, and no text or letters '
      'in the picture.';

  /// The words of a vocabulary list for the prompt, e.g. "static, pan_left".
  static String _wordsOf(List<String> words) {
    return words.join(', ');
  }

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
