import '../core/errors/speech_failure.dart';
import '../data/models/transcript_result.dart';
import 'speech_to_text_service.dart';

/// Uses [primary] (Whisper) until it is down, then [fallback] (the phone) for the rest of the app run (FR-STT-07, decision 028).
class SpeechToTextWithFallback implements SpeechToTextService {
  SpeechToTextWithFallback({required this.primary, required this.fallback});

  final SpeechToTextService primary;
  final SpeechToTextService fallback;

  /// True after Whisper failed once; the phone recogniser is then used.
  bool usingFallback = false;

  SpeechToTextService get _active {
    if (usingFallback) {
      return fallback;
    }
    return primary;
  }

  @override
  Future<void> startListening(String languageCode) {
    return _active.startListening(languageCode);
  }

  // ── Stop: switch to the phone if Whisper is down ──
  @override
  Future<TranscriptResult> stopListening() async {
    try {
      return await _active.stopListening();
    } on SpeechFailure catch (failure) {
      if (failure.serviceDown && !usingFallback) {
        usingFallback = true;
        throw const SpeechFailure("Let's read that sentence once more.");
      }
      rethrow;
    }
  }

  @override
  Future<void> cancel() {
    return _active.cancel();
  }
}
