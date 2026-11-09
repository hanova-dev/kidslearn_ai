import 'verdict.dart';

/// One scored word of the sentence: the target word, how close it sounded, and the verdict (SRS 6.2 score_results).
class ScoreResult {
  const ScoreResult({
    required this.word,
    required this.similarity,
    required this.verdict,
  });

  /// The word from the story sentence, as it is written there.
  final String word;

  /// 0.0 (nothing alike) to 1.0 (the same sound).
  final double similarity;
  final Verdict verdict;
}
