/// A documented subset of Double Metaphone (Philips 2000): a word becomes a sound code (decision 027).
///
/// Only the primary code is made. Sound-alike spellings get the same code, e.g. "elefant" and "elephant" → ALFNT.
class DoubleMetaphone {
  static const String vowels = 'AEIOU';

  /// The sound code of [word], e.g. "phone" → FN; empty when the word has no letters A–Z.
  static String encode(String word) {
    final letters = word.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    if (letters.isEmpty) {
      return '';
    }
    final code = StringBuffer();

    // ── Start of the word: silent first letters, WH and X ──
    var start = 0;
    final firstTwo = letters.length >= 2 ? letters.substring(0, 2) : letters;
    if (firstTwo == 'KN' ||
        firstTwo == 'GN' ||
        firstTwo == 'PN' ||
        firstTwo == 'WR') {
      start = 1;
    } else if (firstTwo == 'WH') {
      code.write('W');
      start = 2;
    } else if (letters[0] == 'X') {
      code.write('S');
      start = 1;
    }

    // ── Letter by letter ──
    var i = start;
    while (i < letters.length) {
      final letter = letters[i];
      final next = _at(letters, i + 1);
      final afterNext = _at(letters, i + 2);

      // ── Double letters count once ──
      if (i > start && letter == letters[i - 1]) {
        i++;
        continue;
      }

      // ── Vowels: only a first vowel is kept, as A ──
      if (vowels.contains(letter)) {
        if (i == 0) {
          code.write('A');
        }
        i++;
        continue;
      }

      // ── Consonant rules ──
      switch (letter) {
        case 'B':
          final silentAfterM =
              i == letters.length - 1 && _at(letters, i - 1) == 'M';
          if (!silentAfterM) {
            code.write('P');
          }
        case 'C':
          if (next == 'H') {
            code.write('X');
            i++;
          } else if (next == 'K') {
            code.write('K');
            i++;
          } else if (_isSoftVowel(next)) {
            code.write('S');
          } else {
            code.write('K');
          }
        case 'D':
          if (next == 'G' && _isSoftVowel(afterNext)) {
            code.write('J');
            i++;
          } else {
            code.write('T');
          }
        case 'G':
          if (next == 'H') {
            if (i == start) {
              code.write('K');
            }
            i++;
          } else if (_isSoftVowel(next)) {
            code.write('J');
          } else {
            code.write('K');
          }
        case 'H':
          if (_isVowel(next)) {
            code.write('H');
          }
        case 'P':
          if (next == 'H') {
            code.write('F');
            i++;
          } else {
            code.write('P');
          }
        case 'Q':
          code.write('K');
        case 'S':
          if (next == 'H') {
            code.write('X');
            i++;
          } else if (next == 'I' && (afterNext == 'O' || afterNext == 'A')) {
            code.write('X');
          } else {
            code.write('S');
          }
        case 'T':
          if (next == 'H') {
            code.write('0');
            i++;
          } else if (next == 'I' && (afterNext == 'O' || afterNext == 'A')) {
            code.write('X');
          } else if (next != 'C' || afterNext != 'H') {
            code.write('T');
          }
        case 'V':
          code.write('F');
        case 'W':
        case 'Y':
          if (_isVowel(next)) {
            code.write(letter);
          }
        case 'X':
          code.write('KS');
        case 'Z':
          code.write('S');
        default:
          code.write(letter);
      }
      i++;
    }
    return code.toString();
  }

  // ── Small helpers ──
  static String _at(String letters, int index) {
    if (index < 0 || index >= letters.length) {
      return '';
    }
    return letters[index];
  }

  static bool _isVowel(String letter) {
    return letter.isNotEmpty && vowels.contains(letter);
  }

  static bool _isSoftVowel(String letter) {
    return letter == 'E' || letter == 'I' || letter == 'Y';
  }
}
