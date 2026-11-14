/// One word of a page and when the voice is expected to start it.
class TimedWord {
  const TimedWord({required this.word, required this.atMs});

  final String word;

  /// Milliseconds after the voice starts.
  final int atMs;
}

/// Guesses when each word is spoken, from its length, for voices that do not report words (FR-MOTION-07, decision 035).
class WordTiming {
  // ── Measured on the emulator voice at speech rate 0.4 (14 Nov, 27 words) ──
  static const int msPerWord = 20;
  static const int msPerLetter = 80;
  static const int commaPauseMs = 400;

  /// Not measured yet: the old stories have one sentence per page.
  static const int sentencePauseMs = 600;

  // ── One guess per word, in order ──
  /// Splits [text] at spaces; a longer word takes longer, and punctuation adds a pause.
  static List<TimedWord> estimate(String text) {
    final words = <TimedWord>[];
    var atMs = 0;
    for (final piece in text.trim().split(RegExp(r'\s+'))) {
      if (piece.isEmpty) {
        continue;
      }
      words.add(TimedWord(word: piece, atMs: atMs));
      atMs += msPerWord + msPerLetter * lettersIn(piece);
      if (RegExp(r'[,،;:]$').hasMatch(piece)) {
        atMs += commaPauseMs;
      } else if (RegExp(r'[.!?۔]["”]?$').hasMatch(piece)) {
        atMs += sentencePauseMs;
      }
    }
    return words;
  }

  /// Letters and digits only: "rabbit." has 6.
  static int lettersIn(String piece) {
    return piece.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '').length;
  }
}
