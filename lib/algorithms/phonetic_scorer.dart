import 'dart:math';

import 'double_metaphone.dart';
import 'levenshtein.dart';
import 'score_result.dart';
import 'verdict.dart';
import 'word_aligner.dart';
import 'word_pair.dart';

/// Scores how close a child's spoken words are to the story sentence (SRS 8.1, FR-SCORE-01..05, 08).
class PhoneticScorer {
  const PhoneticScorer({this.thresholds = defaultThresholds});

  /// CORRECT from this similarity up, per language (SRS 8.1.3, FR-SCORE-05).
  static const Map<String, double> defaultThresholds = {'en': 0.80, 'ur': 0.72};

  /// NEAR_MISS starts this far below the CORRECT threshold (English: 0.80 - 0.25 = 0.55).
  static const double nearMissMargin = 0.25;

  final Map<String, double> thresholds;

  // ── Score a whole sentence (SRS 8.1.6) ──
  /// One result per word of [target], in order; extra spoken words are ignored.
  List<ScoreResult> scoreSentence(
    String target,
    String spoken,
    String language,
  ) {
    final nearMissCut = _thresholdFor(language) - nearMissMargin;
    final pairs = _alignWords(
      WordAligner.tokenize(target),
      WordAligner.tokenize(spoken),
      nearMissCut,
    );
    final results = <ScoreResult>[];
    for (final pair in pairs) {
      final targetWord = pair.target;
      final spokenWord = pair.spoken;
      if (targetWord == null) {
        continue;
      }
      if (spokenWord == null) {
        results.add(
          ScoreResult(
            word: targetWord,
            similarity: 0,
            verdict: Verdict.tryAgain,
          ),
        );
      } else {
        results.add(score(targetWord, spokenWord, language));
      }
    }
    return results;
  }

  // ── Score one word (SRS 8.1.3) ──
  /// CORRECT, NEAR_MISS or TRY_AGAIN for [spoken] compared with [target].
  ScoreResult score(String target, String spoken, String language) {
    final similarity = similarityOf(target, spoken);
    final threshold = _thresholdFor(language);
    var verdict = Verdict.tryAgain;
    if (similarity >= threshold) {
      verdict = Verdict.correct;
    } else if (similarity >= threshold - nearMissMargin) {
      verdict = Verdict.nearMiss;
    }
    return ScoreResult(word: target, similarity: similarity, verdict: verdict);
  }

  // ── Similarity of two words: 1 - distance / longer code (FR-SCORE-01, 02, 03) ──
  /// 1.0 when both words make the same sound code, 0.0 when nothing is alike.
  double similarityOf(String target, String spoken) {
    final targetCode = _toDoubleMetaphone(target);
    final spokenCode = _toDoubleMetaphone(spoken);
    if (targetCode.isEmpty && spokenCode.isEmpty) {
      if (target.toLowerCase() == spoken.toLowerCase()) {
        return 1.0;
      }
      return 0.0;
    }
    final distance = _levenshteinDistance(targetCode, spokenCode);
    final longer = max(targetCode.length, spokenCode.length);
    return 1.0 - distance / longer;
  }

  // ── Steps from the SRS class diagram (Figure 7.2) ──
  List<WordPair> _alignWords(
    List<String> target,
    List<String> spoken,
    double nearMissCut,
  ) {
    return WordAligner.align(target, spoken, (targetWord, spokenWord) {
      return similarityOf(targetWord, spokenWord) >= nearMissCut;
    });
  }

  String _toDoubleMetaphone(String word) {
    return DoubleMetaphone.encode(word);
  }

  int _levenshteinDistance(String a, String b) {
    return Levenshtein.distance(a, b);
  }

  double _thresholdFor(String language) {
    final threshold = thresholds[language];
    if (threshold != null) {
      return threshold;
    }
    return defaultThresholds['en']!;
  }
}
