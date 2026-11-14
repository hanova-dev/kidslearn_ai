import 'dart:async';

import '../../../algorithms/word_aligner.dart';
import '../../../algorithms/word_timing.dart';
import '../../../services/text_to_speech_service.dart';

/// Follows the voice word by word: moves the mascot's mouth and spots the page's cue word (FR-MOTION-07, FR-MOTION-08).
class NarrationTracker {
  NarrationTracker({
    required this.voice,
    required this.onMouth,
    required this.onCue,
  });

  /// How long the mouth stays open for one word.
  static const Duration mouthOpenTime = Duration(milliseconds: 200);

  /// The mouth opens at most once in this time, so it never flaps faster than 3 times a second (NFR-USE-06).
  static const Duration mouthCycle = Duration(milliseconds: 340);

  final TextToSpeechService voice;
  final void Function(bool open) onMouth;
  final void Function() onCue;

  final List<Timer> _guesses = [];
  Timer? _closeMouth;
  Timer? _mouthRest;
  bool _voiceReportsWords = false;
  String _cueWord = '';
  bool _cueFound = false;

  // ── Read a page aloud ──
  /// Returns false when the phone has no voice for [language] (FR-TTS-02).
  Future<bool> narrate(String text, String language, String cueWord) async {
    _stopTimers();
    _voiceReportsWords = false;
    _cueWord = cueWord;
    _cueFound = false;
    final spoken = await voice.speak(text, language, onWord: _voiceWord);
    if (spoken && !_voiceReportsWords) {
      _startGuessing(text);
    }
    return spoken;
  }

  // ── Words from the phone's voice: stop guessing ──
  void _voiceWord(String word) {
    _voiceReportsWords = true;
    _cancelGuesses();
    _wordStarted(word);
  }

  // ── No words from the voice: guess from word length (decision 035) ──
  void _startGuessing(String text) {
    for (final timed in WordTiming.estimate(text)) {
      final timer = Timer(Duration(milliseconds: timed.atMs), () {
        if (!_voiceReportsWords) {
          _wordStarted(timed.word);
        }
      });
      _guesses.add(timer);
    }
  }

  // ── One word starts: open the mouth, check the cue word ──
  void _wordStarted(String word) {
    if (!(_mouthRest?.isActive ?? false)) {
      onMouth(true);
      _closeMouth = Timer(mouthOpenTime, () => onMouth(false));
      _mouthRest = Timer(mouthCycle, () {});
    }
    final words = WordAligner.tokenize(word.toLowerCase());
    if (!_cueFound && _cueWord.isNotEmpty && words.contains(_cueWord)) {
      _cueFound = true;
      onCue();
    }
  }

  // ── Stop the voice and every timer ──
  Future<void> stop() async {
    _stopTimers();
    await voice.stop();
  }

  void _stopTimers() {
    _cancelGuesses();
    if (_closeMouth?.isActive ?? false) {
      onMouth(false);
    }
    _closeMouth?.cancel();
    _mouthRest?.cancel();
  }

  void _cancelGuesses() {
    for (final timer in _guesses) {
      timer.cancel();
    }
    _guesses.clear();
  }
}
