import 'package:kidslearn_ai/algorithms/phonetic_scorer.dart';

/// Measures how long PhoneticScorer takes for one long sentence (NFR-PERF-01: under 300 ms).
void main() {
  const scorer = PhoneticScorer();
  const target =
      'Mango the little fox shares his shiny red ball with his baby sister.';
  const spoken =
      'mango the the little fox um shares his shiny wed ball with his baby sister today';

  // ── Warm up, then time 1000 sentences ──
  scorer.scoreSentence(target, spoken, 'en');
  const runs = 1000;
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    scorer.scoreSentence(target, spoken, 'en');
  }
  stopwatch.stop();

  // ── Show the result ──
  final perSentence = stopwatch.elapsedMicroseconds / runs / 1000;
  print('$runs sentences in ${stopwatch.elapsedMilliseconds} ms');
  print('One sentence: ${perSentence.toStringAsFixed(3)} ms (limit 300 ms)');
  for (final result in scorer.scoreSentence(target, spoken, 'en')) {
    print(
      '${result.word}: ${result.verdict.dbValue} '
      '(${result.similarity.toStringAsFixed(2)})',
    );
  }
}
