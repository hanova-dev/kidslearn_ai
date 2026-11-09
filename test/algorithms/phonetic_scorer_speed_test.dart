import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/phonetic_scorer.dart';

void main() {
  // ── Speed (NFR-PERF-01, FR-SCORE-07: verdict within 300 ms) ──
  test('a long sentence is scored well under 300 ms', () {
    const scorer = PhoneticScorer();
    const target =
        'Mango the little fox shares his shiny red ball with his baby sister.';
    const spoken =
        'mango the the little fox um shares his shiny wed ball with his baby sister today';

    scorer.scoreSentence(target, spoken, 'en');
    final stopwatch = Stopwatch()..start();
    final results = scorer.scoreSentence(target, spoken, 'en');
    stopwatch.stop();

    expect(results.length, 13);
    expect(stopwatch.elapsedMilliseconds, lessThan(300));
  });
}
