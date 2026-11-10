import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/score_result.dart';
import 'package:kidslearn_ai/algorithms/verdict.dart';
import 'package:kidslearn_ai/features/reading/controllers/sentence_check.dart';

ScoreResult word(String text, Verdict verdict) {
  return ScoreResult(word: text, similarity: 0.5, verdict: verdict);
}

void main() {
  // ── Stars per sentence (decision 009) ──
  test('every word CORRECT gives 3 stars and "Great reading!"', () {
    final check = SentenceCheck([
      word('The', Verdict.correct),
      word('rabbit', Verdict.correct),
    ]);

    expect(check.weakest, Verdict.correct);
    expect(check.stars, 3);
    expect(check.wordToPractise, isNull);
    expect(check.feedback, 'Great reading!');
  });

  test('a NEAR_MISS gives 2 stars and the word to listen to', () {
    final check = SentenceCheck([
      word('The', Verdict.correct),
      word('rabbit', Verdict.correct),
      word('shared', Verdict.nearMiss),
    ]);

    expect(check.weakest, Verdict.nearMiss);
    expect(check.stars, 2);
    expect(check.feedback, 'So close! Listen: shared');
  });

  test('a TRY_AGAIN gives 1 star and wins over a NEAR_MISS', () {
    final check = SentenceCheck([
      word('little', Verdict.nearMiss),
      word('rabbit', Verdict.tryAgain),
      word('shared', Verdict.tryAgain),
    ]);

    expect(check.weakest, Verdict.tryAgain);
    expect(check.stars, 1);
    expect(check.wordToPractise, 'rabbit');
    expect(check.feedback, "Let's try that one together: rabbit");
  });
}
