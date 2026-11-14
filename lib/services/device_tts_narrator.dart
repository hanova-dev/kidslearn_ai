import 'package:flutter_tts/flutter_tts.dart';

import 'text_to_speech_service.dart';

/// [TextToSpeechService] that uses the phone's own voice; works offline (FR-TTS-03).
class DeviceTtsNarrator implements TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  /// Slower than normal (0.5 on Android) so young children can follow.
  static const double childSpeechRate = 0.4;

  /// The voice tag for our language code, e.g. 'en' → 'en-US'.
  static String voiceTagFor(String languageCode) {
    if (languageCode == 'ur') {
      return 'ur-PK';
    }
    return 'en-US';
  }

  // ── Speak ──
  @override
  Future<bool> speak(
    String text,
    String languageCode, {
    void Function(String word)? onWord,
  }) async {
    final tag = voiceTagFor(languageCode);
    final available = await _tts.isLanguageAvailable(tag);
    if (available != true) {
      return false;
    }
    await _tts.stop();

    // ── Word progress (Android onRangeStart, Android 8+) ──
    _tts.setProgressHandler((spokenText, start, end, word) {
      onWord?.call(word);
    });
    await _tts.setLanguage(tag);
    await _tts.setSpeechRate(childSpeechRate);
    await _tts.speak(text);
    return true;
  }

  // ── Stop ──
  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
