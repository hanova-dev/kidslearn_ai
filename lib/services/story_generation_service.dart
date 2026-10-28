import '../data/models/narrative_result.dart';
import '../data/models/story_prompt.dart';

/// Writes a story from a redacted prompt; screens only know this interface (SRS 4.3).
abstract class StoryGenerationService {
  /// Returns the story, or throws a StoryGenerationFailure with a plain message.
  Future<NarrativeResult> generateNarrative(StoryPrompt prompt);
}
