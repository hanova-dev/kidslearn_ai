import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/score_result.dart';
import 'package:kidslearn_ai/algorithms/verdict.dart';
import 'package:kidslearn_ai/features/reading/controllers/sentence_check.dart';

ScoreResult word(String text, Verdict verdict) {
  return ScoreResult(word: text, similarity: 0.5, verdict: verdict);
}

/// [good] CORRECT words followed by [missed] TRY_AGAIN words.
SentenceCheck pageWith(int good, int missed) {
  return SentenceCheck([
    for (var i = 0; i < good; i++) word('good$i', Verdict.correct),
    for (var i = 0; i < missed; i++) word('missed$i', Verdict.tryAgain),
  ]);
}

void main() {
  // ── Stars by share of words (decision 032) ──
  test('every word CORRECT gives 3 stars and "Great reading!"', () {
    final check = pageWith(4, 0);

    expect(check.stars, 3);
    expect(check.overall, Verdict.correct);
    expect(check.wordToPractise, isNull);
    expect(check.feedback, 'Great reading!');
  });

  test('90% read well is still 3 stars; 89% is 2', () {
    expect(pageWith(9, 1).stars, 3);
    expect(pageWith(8, 1).stars, 2);
  });

  test('60% read well gives 2 stars; less gives 1, never 0', () {
    expect(pageWith(6, 4).stars, 2);
    expect(pageWith(5, 5).stars, 1);
    expect(pageWith(0, 3).stars, 1);
  });

  // ── The word to practise and what the phone says ──
  test('a TRY_AGAIN word is practised before a NEAR_MISS word', () {
    final check = SentenceCheck([
      word('little', Verdict.nearMiss),
      word('rabbit', Verdict.tryAgain),
      word('shared', Verdict.tryAgain),
    ]);

    expect(check.stars, 1);
    expect(check.overall, Verdict.tryAgain);
    expect(check.wordToPractise?.word, 'rabbit');
    expect(check.feedback, "Let's try that one together: rabbit");
  });

  test('a NEAR_MISS word still gives 3 stars and "So close!"', () {
    final check = SentenceCheck([
      word('The', Verdict.correct),
      word('shared', Verdict.nearMiss),
    ]);

    expect(check.stars, 3);
    expect(check.wordToPractise?.word, 'shared');
    expect(check.feedback, 'So close! Listen: shared');
  });
}
