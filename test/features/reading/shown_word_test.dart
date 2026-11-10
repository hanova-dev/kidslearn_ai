import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/score_result.dart';
import 'package:kidslearn_ai/algorithms/verdict.dart';
import 'package:kidslearn_ai/features/reading/controllers/shown_word.dart';

ScoreResult word(String text, Verdict verdict) {
  return ScoreResult(word: text, similarity: 0.5, verdict: verdict);
}

void main() {
  // ── Before scoring ──
  test('without results every word is plain and keeps its punctuation', () {
    final shown = ShownWord.listOf('Sky hops  home.', []);

    expect(shown.length, 3);
    expect(shown[2].text, 'home.');
    for (final item in shown) {
      expect(item.verdict, isNull);
    }
  });

  // ── After scoring ──
  test('each word gets the verdict of its scored word, in order', () {
    final shown = ShownWord.listOf('The rabbit ate carrots.', [
      word('The', Verdict.correct),
      word('rabbit', Verdict.tryAgain),
      word('ate', Verdict.correct),
      word('carrots', Verdict.nearMiss),
    ]);

    expect(shown[1].text, 'rabbit');
    expect(shown[1].verdict, Verdict.tryAgain);
    expect(shown[3].text, 'carrots.');
    expect(shown[3].verdict, Verdict.nearMiss);
  });

  test('"well-known" is one word; "—" stays plain and is skipped', () {
    final shown = ShownWord.listOf('A well-known — song', [
      word('A', Verdict.correct),
      word('wellknown', Verdict.nearMiss),
      word('song', Verdict.correct),
    ]);

    expect(shown.length, 4);
    expect(shown[1].verdict, Verdict.nearMiss);
    expect(shown[2].text, '—');
    expect(shown[2].verdict, isNull);
    expect(shown[3].verdict, Verdict.correct);
  });
}
