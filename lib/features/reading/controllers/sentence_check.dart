import '../../../algorithms/score_result.dart';
import '../../../algorithms/verdict.dart';

/// What one reading of a page gave: a verdict per word, stars and what to say (decisions 004, 008, 032).
class SentenceCheck {
  const SentenceCheck(this.results);

  /// One result per word of the page, in order (from PhoneticScorer.scoreSentence).
  final List<ScoreResult> results;

  // ── Stars for this page (decision 032) ──
  /// Share of words read well (green or amber): 90% or more = 3, 60% or more = 2, otherwise 1.
  int get stars {
    if (results.isEmpty) {
      return 3;
    }
    var readWell = 0;
    for (final result in results) {
      if (result.verdict != Verdict.tryAgain) {
        readWell++;
      }
    }
    final share = readWell / results.length;
    if (share >= 0.9) {
      return 3;
    }
    if (share >= 0.6) {
      return 2;
    }
    return 1;
  }

  /// The banner's colour and icon: CORRECT for 3 stars, NEAR_MISS for 2, TRY_AGAIN for 1.
  Verdict get overall {
    final count = stars;
    if (count == 3) {
      return Verdict.correct;
    }
    if (count == 2) {
      return Verdict.nearMiss;
    }
    return Verdict.tryAgain;
  }

  // ── The word for the model pronunciation ──
  /// The first TRY_AGAIN word, else the first NEAR_MISS word, else null.
  ScoreResult? get wordToPractise {
    for (final result in results) {
      if (result.verdict == Verdict.tryAgain) {
        return result;
      }
    }
    for (final result in results) {
      if (result.verdict == Verdict.nearMiss) {
        return result;
      }
    }
    return null;
  }

  // ── What the banner shows and the phone says (SRS 10.8) ──
  /// e.g. "Great reading!", "So close! Listen: shared" or "Let's try that one together: rabbit".
  String get feedback {
    final practise = wordToPractise;
    if (practise == null) {
      return 'Great reading!';
    }
    if (practise.verdict == Verdict.nearMiss) {
      return 'So close! Listen: ${practise.word}';
    }
    return "Let's try that one together: ${practise.word}";
  }
}
