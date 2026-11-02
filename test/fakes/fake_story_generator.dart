import 'dart:async';

import 'package:kidslearn_ai/core/errors/story_generation_failure.dart';
import 'package:kidslearn_ai/data/models/narrative_result.dart';
import 'package:kidslearn_ai/data/models/narrative_scene.dart';
import 'package:kidslearn_ai/data/models/story_prompt.dart';
import 'package:kidslearn_ai/services/story_generation_service.dart';

/// [StoryGenerationService] for tests: no network, remembers what it was asked.
class FakeStoryGenerator implements StoryGenerationService {
  FakeStoryGenerator({this.failuresBeforeSuccess = 0, this.onCall});

  /// How many calls fail before one succeeds.
  int failuresBeforeSuccess;

  /// Runs at the start of each call, e.g. to check what is already saved.
  final void Function()? onCall;

  /// When set, each call waits until this is completed (to see the loading screen).
  Completer<void>? gate;

  final List<StoryPrompt> prompts = [];

  @override
  Future<NarrativeResult> generateNarrative(StoryPrompt prompt) async {
    prompts.add(prompt);
    onCall?.call();
    if (gate != null) {
      await gate!.future;
    }
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const StoryGenerationFailure(
        'Story writing is busy right now. Please try again in a minute.',
      );
    }
    return NarrativeResult(
      title: '${prompt.buddyName} Shares the Ball',
      moralValue: 'Sharing',
      characterSheet: 'A small orange fox with a blue scarf.',
      scenes: const [
        NarrativeScene(text: 'Mango has a red ball.', imagePrompt: 'a ball'),
        NarrativeScene(text: 'Mango gives the ball.', imagePrompt: 'giving'),
        NarrativeScene(text: 'They play together.', imagePrompt: 'playing'),
      ],
    );
  }
}
