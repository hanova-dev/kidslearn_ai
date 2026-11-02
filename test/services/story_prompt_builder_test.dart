import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/services/story_prompt_builder.dart';

ChildProfile makeChild(String name) {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: name,
    buddyId: 'mango',
    ageGroup: AgeGroup.listener,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 2),
  );
}

void main() {
  // ── Name redaction (FR-STORY-08) ──
  group('redactName', () {
    test('replaces the child name with the buddy name', () {
      expect(
        StoryPromptBuilder.redactName(
          'Zayan does not want to share his toys',
          'Zayan',
          'Mango',
        ),
        'Mango does not want to share his toys',
      );
    });

    test('ignores upper and lower case', () {
      expect(
        StoryPromptBuilder.redactName('zayan and ZAYAN', 'Zayan', 'Mango'),
        'Mango and Mango',
      );
    });

    test('keeps possessives like Zayan\'s', () {
      expect(
        StoryPromptBuilder.redactName("Zayan's sister", 'Zayan', 'Mango'),
        "Mango's sister",
      );
    });

    test('does not touch other words that only contain the name', () {
      expect(
        StoryPromptBuilder.redactName('Zayana and Zayan', 'Zayan', 'Mango'),
        'Zayana and Mango',
      );
    });

    test('replaces the full name and each part of it', () {
      expect(
        StoryPromptBuilder.redactName(
          'Fatima Khan lies. Fatima says sorry. Khan family.',
          'Fatima Khan',
          'Sky',
        ),
        'Sky lies. Sky says sorry. Sky family.',
      );
    });

    test('an empty child name changes nothing', () {
      expect(
        StoryPromptBuilder.redactName('Share your toys', '  ', 'Mango'),
        'Share your toys',
      );
    });
  });

  // ── Building the prompt ──
  group('build and userMessage', () {
    test('the message has the buddy and animal but never the real name', () {
      final prompt = StoryPromptBuilder.build(
        parentText: '  Zayan does not want to share with his baby sister ',
        value: 'Sharing',
        child: makeChild('Zayan'),
        buddyName: 'Mango',
        buddyAnimal: 'fox',
      );
      final message = StoryPromptBuilder.userMessage(prompt);

      expect(
        prompt.behaviour,
        'Mango does not want to share with his baby sister',
      );
      expect(message, contains('Mango the fox'));
      expect(message, contains('Sharing'));
      expect(message.toLowerCase(), isNot(contains('zayan')));
    });

    test('a value with no text leaves out the Situation line', () {
      final prompt = StoryPromptBuilder.build(
        parentText: '',
        value: 'Kindness',
        child: makeChild('Zayan'),
        buddyName: 'Mango',
        buddyAnimal: 'fox',
      );
      final message = StoryPromptBuilder.userMessage(prompt);

      expect(message, contains('Lesson: Kindness.'));
      expect(message, isNot(contains('Situation')));
    });

    test('the system prompt keeps stories gentle and age-appropriate', () {
      final rules = StoryPromptBuilder.systemPrompt.toLowerCase();

      expect(rules, contains('aged 2 to 7'));
      expect(rules, contains('violence'));
      expect(rules, contains('exactly 6 scenes'));
    });
  });
}
