import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/word_timing.dart';

void main() {
  // ── One guess per word, in order ──
  test('every word gets a time and the first word starts at 0', () {
    final words = WordTiming.estimate('Sky hops home.');

    expect(words.map((w) => w.word), ['Sky', 'hops', 'home.']);
    expect(words.first.atMs, 0);
  });

  test('a longer word takes longer', () {
    final words = WordTiming.estimate('a toothbrush is here');

    final shortWord = words[1].atMs - words[0].atMs;
    final longWord = words[2].atMs - words[1].atMs;
    expect(longWord, greaterThan(shortWord));
    expect(longWord, 20 + 80 * 10);
  });

  test('a comma and a full stop add a pause', () {
    final plain = WordTiming.estimate('Inside Sky');
    final comma = WordTiming.estimate('Inside, Sky');
    final stop = WordTiming.estimate('Inside. Sky');

    expect(comma[1].atMs - plain[1].atMs, WordTiming.commaPauseMs);
    expect(stop[1].atMs - plain[1].atMs, WordTiming.sentencePauseMs);
  });

  test('punctuation is not counted as letters', () {
    expect(WordTiming.lettersIn('rabbit.'), 6);
    expect(WordTiming.lettersIn('"Hello!"'), 5);
  });

  test('extra spaces and an empty text give no empty words', () {
    expect(WordTiming.estimate('  Sky   hops  ').length, 2);
    expect(WordTiming.estimate(''), isEmpty);
  });

  test('the guess is close to the measured emulator voice', () {
    final words = WordTiming.estimate('Sky hops home as the sun says goodbye');

    expect(words.last.atMs, inInclusiveRange(1500, 2300));
  });
}
