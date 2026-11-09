import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/levenshtein.dart';

void main() {
  // ── Edit distance (SRS 8.1.3, FR-SCORE-02) ──
  test('equal texts have distance 0', () {
    expect(Levenshtein.distance('', ''), 0);
    expect(Levenshtein.distance('ALFNT', 'ALFNT'), 0);
  });

  test('an empty text needs one insert per letter', () {
    expect(Levenshtein.distance('', 'ABC'), 3);
    expect(Levenshtein.distance('ABC', ''), 3);
  });

  test('one change, insert or delete costs 1', () {
    expect(Levenshtein.distance('RPT', 'WPT'), 1);
    expect(Levenshtein.distance('KT', 'KTS'), 1);
    expect(Levenshtein.distance('KTS', 'KT'), 1);
  });

  test('the classic examples', () {
    expect(Levenshtein.distance('kitten', 'sitting'), 3);
    expect(Levenshtein.distance('flaw', 'lawn'), 2);
  });

  test('the order of the two texts does not matter', () {
    expect(
      Levenshtein.distance('sunday', 'saturday'),
      Levenshtein.distance('saturday', 'sunday'),
    );
  });
}
