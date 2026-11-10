import '../../../algorithms/score_result.dart';
import '../../../algorithms/verdict.dart';

/// What one reading of a sentence gave: a verdict per word, stars and what to say (decisions 004, 008, 009).
class SentenceCheck {
  const SentenceCheck(this.results);

  /// One result per word of the sentence, in order (from PhoneticScorer.scoreSentence).
  final List<ScoreResult> results;

  // ── The weakest word decides the feedback ──
  /// TRY_AGAIN if any word is TRY_AGAIN, else NEAR_MISS if any is, else CORRECT.
  Verdict get weakest {
    var weakest = Verdict.correct;
    for (final result in results) {
      if (result.verdict == Verdict.tryAgain) {
        return Verdict.tryAgain;
      }
      if (result.verdict == Verdict.nearMiss) {
        weakest = Verdict.nearMiss;
      }
    }
    return weakest;
  }

  /// The first word with the weakest verdict, for the model pronunciation; null when all are CORRECT.
  String? get wordToPractise {
    final verdict = weakest;
    if (verdict == Verdict.correct) {
      return null;
    }
    for (final result in results) {
      if (result.verdict == verdict) {
        return result.word;
      }
    }
    return null;
  }

  // ── Stars for this sentence (decision 009) ──
  /// 3 if every word is CORRECT, 2 if every word is CORRECT or NEAR_MISS, otherwise 1.
  int get stars {
    final verdict = weakest;
    if (verdict == Verdict.correct) {
      return 3;
    }
    if (verdict == Verdict.nearMiss) {
      return 2;
    }
    return 1;
  }

  // ── What the banner shows and the phone says (SRS 10.8) ──
  /// e.g. "Great reading!", "So close! Listen: shared" or "Let's try that one together: rabbit".
  String get feedback {
    final word = wordToPractise;
    if (word == null) {
      return 'Great reading!';
    }
    if (weakest == Verdict.nearMiss) {
      return 'So close! Listen: $word';
    }
    return "Let's try that one together: $word";
  }
}
