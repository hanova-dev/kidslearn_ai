import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

import '../core/errors/speech_failure.dart';
import '../data/models/transcript_result.dart';
import 'speech_to_text_service.dart';

/// [SpeechToTextService] that uses the phone's own recogniser; the fallback when Whisper is down (FR-STT-07).
class DeviceSpeechRecognizer implements SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  String _words = '';
  Completer<String>? _finalWords;

  /// The recogniser locale for our language code, e.g. 'en' → 'en_US'.
  static String localeFor(String languageCode) {
    if (languageCode == 'ur') {
      return 'ur_PK';
    }
    return 'en_US';
  }

  // ── Start: get the recogniser ready, then listen ──
  @override
  Future<void> startListening(String languageCode) async {
    final ready = await _speech.initialize();
    if (!ready) {
      throw const SpeechFailure(
        'This phone cannot listen right now. '
        'A grown-up can check the microphone in Settings.',
      );
    }
    _words = '';
    final finalWords = Completer<String>();
    _finalWords = finalWords;
    await _speech.listen(
      onResult: (result) {
        _words = result.recognizedWords;
        if (result.finalResult && !finalWords.isCompleted) {
          finalWords.complete(_words);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: localeFor(languageCode),
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  // ── Stop: wait a moment for the last words ──
  @override
  Future<TranscriptResult> stopListening() async {
    await _speech.stop();
    var text = _words;
    final finalWords = _finalWords;
    if (finalWords != null) {
      text = await finalWords.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => _words,
      );
    }
    if (text.trim().isEmpty) {
      throw const SpeechFailure(
        "We didn't hear anything. Tap the microphone and read again.",
      );
    }
    return TranscriptResult(text: text.trim(), source: 'DEVICE');
  }

  @override
  Future<void> cancel() {
    return _speech.cancel();
  }
}
