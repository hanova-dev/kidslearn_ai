import 'dart:math';

import 'word_pair.dart';

/// Lines up the spoken words with the sentence's words, so a skipped or extra word does not shift the rest (SRS 8.1.6).
class WordAligner {
  /// Splits [text] into words, without punctuation; an apostrophe inside a word stays ("Don't").
  static List<String> tokenize(String text) {
    final words = <String>[];
    for (final piece in text.split(RegExp(r'\s+'))) {
      final word = piece
          .replaceAll(RegExp(r"[^\p{L}\p{N}']", unicode: true), '')
          .replaceAll(RegExp(r"^'+|'+$"), '');
      if (word.isNotEmpty) {
        words.add(word);
      }
    }
    return words;
  }

  /// Word-level edit distance, then a walk back through the table to get the pairs.
  ///
  /// [sameWord] says when a target word and a spoken word count as a match.
  static List<WordPair> align(
    List<String> target,
    List<String> spoken,
    bool Function(String target, String spoken) sameWord,
  ) {
    final rows = target.length;
    final columns = spoken.length;

    // ── Table: the same idea as Levenshtein, with words instead of letters ──
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
    for (var i = 1; i <= rows; i++) {
      for (var j = 1; j <= columns; j++) {
        final skipped = table[i - 1][j] + 1;
        final extra = table[i][j - 1] + 1;
        final paired =
            table[i - 1][j - 1] + _cost(target[i - 1], spoken[j - 1], sameWord);
        table[i][j] = min(skipped, min(extra, paired));
      }
    }

    // ── Walk back from the end: paired, else skipped, else extra ──
    final pairs = <WordPair>[];
    var i = rows;
    var j = columns;
    while (i > 0 || j > 0) {
      if (i > 0 &&
          j > 0 &&
          table[i][j] ==
              table[i - 1][j - 1] +
                  _cost(target[i - 1], spoken[j - 1], sameWord)) {
        pairs.add(WordPair(target: target[i - 1], spoken: spoken[j - 1]));
        i--;
        j--;
      } else if (i > 0 && table[i][j] == table[i - 1][j] + 1) {
        pairs.add(WordPair(target: target[i - 1], spoken: null));
        i--;
      } else {
        pairs.add(WordPair(target: null, spoken: spoken[j - 1]));
        j--;
      }
    }
    return pairs.reversed.toList();
  }

  /// 0 when the two words match, 1 when they do not.
  static int _cost(
    String target,
    String spoken,
    bool Function(String target, String spoken) sameWord,
  ) {
    if (sameWord(target, spoken)) {
      return 0;
    }
    return 1;
  }
}
