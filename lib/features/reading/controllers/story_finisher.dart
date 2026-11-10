import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/child_repository.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/models/reading_session.dart';
import '../../../data/models/scene.dart';
import '../../../data/reading_session_repository.dart';
import '../../../policy/age_experience_policy.dart';

/// What one finished reading earned; shown on the Story complete screen.
class StoryResult {
  const StoryResult({required this.wordsRead, required this.stars});

  final int wordsRead;
  final int stars;
}

/// Saves a finished reading: one reading_sessions row and the stars (FR-MODE-06, decision 026).
class StoryFinisher {
  StoryFinisher(this._sessions, this._children);

  final ReadingSessionRepository _sessions;
  final ChildRepository _children;

  /// One star for every page read in the story viewer (SRS 10.10).
  static const int starsPerPage = 1;

  /// Counts the words in every scene, e.g. "Sky hops home." is 3 words.
  static int countWords(List<Scene> scenes) {
    var count = 0;
    for (final scene in scenes) {
      for (final word in scene.text.split(' ')) {
        if (word.trim().isNotEmpty) {
          count++;
        }
      }
    }
    return count;
  }

  /// Saves the session with the [stars] the child earned, adds them to the child and returns what was earned.
  Future<StoryResult> finish({
    required ChildProfile child,
    required String storyId,
    required List<Scene> scenes,
    required int stars,
    required DateTime now,
  }) async {
    final result = StoryResult(wordsRead: countWords(scenes), stars: stars);

    // ── One session row per finished reading ──
    final mode = AgeExperiencePolicy.of(child.ageGroup).sessionMode;
    await _sessions.saveSession(
      ReadingSession(
        id: 'session-${now.microsecondsSinceEpoch}',
        childId: child.id,
        storyId: storyId,
        mode: mode,
        wordsRead: result.wordsRead,
        starsEarned: result.stars,
        lastModified: now,
      ),
    );

    // ── Stars go on the child's balance ──
    await _children.addStars(child.id, result.stars);
    return result;
  }
}

/// The one [StoryFinisher], built from the repositories in providers.dart.
final storyFinisherProvider = Provider<StoryFinisher>((ref) {
  return StoryFinisher(
    ref.watch(readingSessionRepositoryProvider),
    ref.watch(childRepositoryProvider),
  );
});
