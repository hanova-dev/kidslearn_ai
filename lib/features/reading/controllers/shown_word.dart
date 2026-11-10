import '../../../algorithms/score_result.dart';
import '../../../algorithms/verdict.dart';
import '../../../algorithms/word_aligner.dart';

/// One word of the sentence as the child sees it ("carrots." keeps its full stop), with its verdict once scored.
class ShownWord {
  const ShownWord(this.text, this.verdict);

  final String text;

  /// Null before the sentence is scored, or for a piece with no letters such as "—".
  final Verdict? verdict;

  /// Splits [sentence] at spaces and gives each piece the verdict of its scored word.
  ///
  /// [results] come from PhoneticScorer.scoreSentence: one per piece that WordAligner.tokenize keeps.
  static List<ShownWord> listOf(String sentence, List<ScoreResult> results) {
    final shown = <ShownWord>[];
    var next = 0;
    for (final piece in sentence.split(' ')) {
      if (piece.trim().isEmpty) {
        continue;
      }

      // ── "—" has no letters, so the scorer skipped it ──
      Verdict? verdict;
      final isScored = WordAligner.tokenize(piece).isNotEmpty;
      if (isScored && next < results.length) {
        verdict = results[next].verdict;
        next++;
      }
      shown.add(ShownWord(piece, verdict));
    }
    return shown;
  }
}
