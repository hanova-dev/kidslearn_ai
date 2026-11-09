import 'dart:math';

/// Levenshtein edit distance: the fewest single-letter changes from one text to another (SRS 8.1.3).
class Levenshtein {
  /// How many inserts, deletes or changes turn [a] into [b].
  static int distance(String a, String b) {
    final rows = a.length;
    final columns = b.length;

    // ── Table: table[i][j] = distance between the first i letters of a and the first j of b ──
    final table = <List<int>>[];
    for (var i = 0; i <= rows; i++) {
      table.add(List<int>.filled(columns + 1, 0));
    }
    for (var i = 0; i <= rows; i++) {
      table[i][0] = i;
    }
    for (var j = 0; j <= columns; j++) {
      table[0][j] = j;
    }

    // ── Fill the table: delete, insert or change, take the cheapest ──
    for (var i = 1; i <= rows; i++) {
      for (var j = 1; j <= columns; j++) {
        var cost = 1;
        if (a[i - 1] == b[j - 1]) {
          cost = 0;
        }
        final delete = table[i - 1][j] + 1;
        final insert = table[i][j - 1] + 1;
        final change = table[i - 1][j - 1] + cost;
        table[i][j] = min(delete, min(insert, change));
      }
    }
    return table[rows][columns];
  }
}
