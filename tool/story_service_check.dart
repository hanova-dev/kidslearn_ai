import 'package:kidslearn_ai/app/app_config.dart';
import 'package:kidslearn_ai/core/errors/story_generation_failure.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/services/groq_story_generator.dart';
import 'package:kidslearn_ai/services/story_prompt_builder.dart';

import 'dev_env.dart';

/// Real check: one Groq call through the app's own M2 classes.
Future<void> main() async {
  // ── A pretend child and the parent's words (real name inside) ──
  final child = ChildProfile(
    id: 'check-child',
    parentId: 'check-parent',
    name: 'Zayan',
    buddyId: 'mango',
    ageGroup: AgeGroup.listener,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime.now(),
  );
  const parentText =
      "Zayan doesn't want to share his toys with his baby sister";

  // ── Redact and show what will be sent ──
  final prompt = StoryPromptBuilder.build(
    parentText: parentText,
    value: 'Sharing',
    child: child,
    buddyName: 'Mango',
    buddyAnimal: 'fox',
  );
  print('Parent typed:  $parentText');
  print('Sent to Groq:\n${StoryPromptBuilder.userMessage(prompt)}');
  print('');

  // ── Call Groq through GroqStoryGenerator ──
  final generator = GroqStoryGenerator(
    apiKey: readDevKey('GROQ_API_KEY'),
    modelId: AppConfig.storyModelId,
  );
  final stopwatch = Stopwatch()..start();
  try {
    final story = await generator.generateNarrative(prompt);
    print('Done in ${stopwatch.elapsedMilliseconds} ms');
    print('Title: ${story.title}');
    print('Character: ${story.characterSheet}');
    for (var i = 0; i < story.scenes.length; i++) {
      print('Scene ${i + 1}: ${story.scenes[i].text}');
    }
  } on StoryGenerationFailure catch (failure) {
    print('Failed: ${failure.message}');
  }
}
