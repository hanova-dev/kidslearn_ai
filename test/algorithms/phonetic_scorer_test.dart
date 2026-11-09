import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/phonetic_scorer.dart';
import 'package:kidslearn_ai/algorithms/score_result.dart';
import 'package:kidslearn_ai/algorithms/verdict.dart';

/// Writes results as text, e.g. "the:CORRECT red:TRY_AGAIN", so tests are easy to read.
String show(List<ScoreResult> results) {
  final parts = <String>[];
  for (final result in results) {
    parts.add('${result.word}:${result.verdict.dbValue}');
  }
  return parts.join(' ');
}

void main() {
  const scorer = PhoneticScorer();

  // ── Similarity (FR-SCORE-01, 02, 03) ──
  test('the same sound gives similarity 1.0', () {
    expect(scorer.similarityOf('ball', 'ball'), 1.0);
    expect(scorer.similarityOf('sun', 'son'), 1.0);
    expect(scorer.similarityOf('elephant', 'elefant'), 1.0);
  });

  test('similarity is 1 - distance / longer code length', () {
    expect(scorer.similarityOf('rabbit', 'wabbit'), closeTo(2 / 3, 0.001));
    expect(scorer.similarityOf('plant', 'slant'), closeTo(0.75, 0.001));
    expect(scorer.similarityOf('cat', 'zoo'), 0.0);
  });

  test('words with no letter code are compared as text', () {
    expect(scorer.similarityOf('7', '7'), 1.0);
    expect(scorer.similarityOf('7', '8'), 0.0);
  });

  // ── Verdict for one word (FR-SCORE-04) ──
  test('one word gets CORRECT, NEAR_MISS or TRY_AGAIN', () {
    expect(scorer.score('elephant', 'elefant', 'en').verdict, Verdict.correct);
    expect(scorer.score('rabbit', 'wabbit', 'en').verdict, Verdict.nearMiss);
    expect(scorer.score('giraffe', 'monkey', 'en').verdict, Verdict.tryAgain);
  });

  test('the result keeps the target word and the similarity', () {
    final result = scorer.score('rabbit', 'wabbit', 'en');

    expect(result.word, 'rabbit');
    expect(result.similarity, closeTo(2 / 3, 0.001));
  });

  // ── Thresholds per language (FR-SCORE-05) ──
  test('English and Urdu have their own thresholds', () {
    expect(scorer.score('plant', 'slant', 'en').verdict, Verdict.nearMiss);
    expect(scorer.score('plant', 'slant', 'ur').verdict, Verdict.correct);
  });

  test('an unknown language uses the English thresholds', () {
    expect(scorer.score('plant', 'slant', 'fr').verdict, Verdict.nearMiss);
  });

  test('thresholds can be tuned without changing the code', () {
    const easy = PhoneticScorer(thresholds: {'en': 0.6});

    expect(easy.score('rabbit', 'wabbit', 'en').verdict, Verdict.correct);
  });

  // ── Whole sentence (SRS 8.1.6, FR-SCORE-08) ──
  test('a sentence read well is all CORRECT', () {
    final results = scorer.scoreSentence(
      'The rabbit hops home.',
      'the rabbit hops home',
      'en',
    );

    expect(
      show(results),
      'The:CORRECT rabbit:CORRECT hops:CORRECT home:CORRECT',
    );
  });

  test('a skipped word is TRY_AGAIN with similarity 0', () {
    final results = scorer.scoreSentence('The red ball.', 'the ball', 'en');

    expect(show(results), 'The:CORRECT red:TRY_AGAIN ball:CORRECT');
    expect(results[1].similarity, 0.0);
  });

  test('extra and repeated words do not change the other verdicts', () {
    final results = scorer.scoreSentence(
      'The red ball.',
      'the the big red ball',
      'en',
    );

    expect(show(results), 'The:CORRECT red:CORRECT ball:CORRECT');
  });

  test('a near word in a sentence is NEAR_MISS', () {
    final results = scorer.scoreSentence(
      'The rabbit runs.',
      'the wabbit runs',
      'en',
    );

    expect(show(results), 'The:CORRECT rabbit:NEAR_MISS runs:CORRECT');
  });

  test('nothing heard makes every word TRY_AGAIN', () {
    final results = scorer.scoreSentence('Sky hops.', '', 'en');

    expect(show(results), 'Sky:TRY_AGAIN hops:TRY_AGAIN');
  });

  // ── Saved verdict text (SRS 6.2 score_results.verdict) ──
  test('verdicts are saved as CORRECT, NEAR_MISS and TRY_AGAIN', () {
    expect(Verdict.correct.dbValue, 'CORRECT');
    expect(Verdict.nearMiss.dbValue, 'NEAR_MISS');
    expect(Verdict.tryAgain.dbValue, 'TRY_AGAIN');
  });
}
