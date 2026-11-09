import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/word_aligner.dart';
import 'package:kidslearn_ai/algorithms/word_pair.dart';

/// Two words match when they are the same, ignoring case (enough to test the alignment).
bool sameLetters(String target, String spoken) {
  return target.toLowerCase() == spoken.toLowerCase();
}

/// Writes the pairs as text, e.g. "the=the red=_ ball=ball", so tests are easy to read.
String show(List<WordPair> pairs) {
  final parts = <String>[];
  for (final pair in pairs) {
    parts.add('${pair.target ?? '_'}=${pair.spoken ?? '_'}');
  }
  return parts.join(' ');
}

List<WordPair> align(String target, String spoken) {
  return WordAligner.align(
    WordAligner.tokenize(target),
    WordAligner.tokenize(spoken),
    sameLetters,
  );
}

void main() {
  // ── Splitting a sentence into words ──
  test('tokenize removes punctuation and extra spaces', () {
    expect(WordAligner.tokenize('Mango shares,  his ball!'), [
      'Mango',
      'shares',
      'his',
      'ball',
    ]);
    expect(WordAligner.tokenize("'Hello,' said Sky."), [
      'Hello',
      'said',
      'Sky',
    ]);
    expect(WordAligner.tokenize("Don't stop"), ["Don't", 'stop']);
    expect(WordAligner.tokenize('  '), isEmpty);
  });

  // ── Alignment (SRS 8.1.6, FR-SCORE-08) ──
  test('the same words line up one to one', () {
    expect(
      show(align('The red ball', 'the red ball')),
      'The=the red=red ball=ball',
    );
  });

  test('a skipped word is paired with nothing', () {
    expect(show(align('the red ball', 'the ball')), 'the=the red=_ ball=ball');
  });

  test('an extra spoken word does not shift the others', () {
    expect(
      show(align('the red ball', 'the big red ball')),
      'the=the _=big red=red ball=ball',
    );
  });

  test('a repeated word is treated as an extra word', () {
    expect(show(align('the cat', 'the the cat')), '_=the the=the cat=cat');
  });

  test('a different word in the same place is paired, not skipped', () {
    expect(
      show(align('the cat sat', 'the dog sat')),
      'the=the cat=dog sat=sat',
    );
  });

  test('nothing spoken leaves every target word alone', () {
    expect(show(align('the cat', '')), 'the=_ cat=_');
  });
}
