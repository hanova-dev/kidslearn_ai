import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/data/models/transcript_result.dart';
import 'package:kidslearn_ai/services/speech_to_text_service.dart';

/// [SpeechToTextService] for tests: returns [nextText], or throws [nextFailure] once.
class FakeSpeechToText implements SpeechToTextService {
  FakeSpeechToText({required this.source});

  /// 'WHISPER' or 'DEVICE', copied into every result.
  final String source;

  String nextText = 'the red ball';
  SpeechFailure? nextFailure;
  final List<String> startedLanguages = [];
  int stopCount = 0;
  int cancelCount = 0;

  @override
  Future<void> startListening(String languageCode) async {
    startedLanguages.add(languageCode);
  }

  @override
  Future<TranscriptResult> stopListening() async {
    stopCount++;
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
    return TranscriptResult(text: nextText, source: source);
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
  }
}
