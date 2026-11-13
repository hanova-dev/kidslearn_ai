import 'package:kidslearn_ai/app/app_config.dart';
import 'package:kidslearn_ai/core/errors/story_generation_failure.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/services/groq_story_generator.dart';
import 'package:kidslearn_ai/services/story_prompt_builder.dart';

import 'dev_env.dart';

/// Real check: four stories through the app's own prompt, to judge story quality by eye.
Future<void> main() async {
  // ── A pretend child (the real name is replaced before sending) ──
  final child = ChildProfile(
    id: 'check-child',
    parentId: 'check-parent',
    name: 'Ali',
    buddyId: 'mango',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime.now(),
  );

  // ── The same kinds of input parents typed on the emulator ──
  const inputs = [
    ['Ali does not want to try new food at dinner', ''],
    ['', 'Patience'],
    ["Ali doesn't want to share his toys with his baby sister", 'Sharing'],
    ['Ali is scared of the dark at bedtime', ''],
  ];

  final generator = GroqStoryGenerator(
    apiKey: readDevKey('GROQ_API_KEY'),
    modelId: AppConfig.storyModelId,
  );
  for (final input in inputs) {
    final prompt = StoryPromptBuilder.build(
      parentText: input[0],
      value: input[1],
      child: child,
      buddyName: 'Mango',
      buddyAnimal: 'fox',
    );
    print('=== Input: "${input[0]}"  value: "${input[1]}"');

    // ── Call Groq and print every sentence with its word count ──
    final stopwatch = Stopwatch()..start();
    try {
      final story = await generator.generateNarrative(prompt);
      print('Title: ${story.title}  (${stopwatch.elapsedMilliseconds} ms)');
      print('Characters: ${story.characterSheet}');
      for (var i = 0; i < story.scenes.length; i++) {
        final text = story.scenes[i].text;
        final words = text.split(' ').where((w) => w.isNotEmpty).length;
        print('  ${i + 1}. $text  ($words words)');
        print('     picture: ${story.scenes[i].imagePrompt}');
      }
    } on StoryGenerationFailure catch (failure) {
      print('Failed: ${failure.message}');
    }
    print('');

    // ── Pause, so each story has its own minute of the free token limit ──
    await Future.delayed(const Duration(seconds: 60));
  }
}
