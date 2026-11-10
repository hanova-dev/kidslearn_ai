import '../data/models/transcript_result.dart';

/// Listens to one sentence and gives back the text; screens only know this interface (SRS 4.3, decision 028).
abstract class SpeechToTextService {
  /// Starts listening in [languageCode] ('en' or 'ur'); throws a SpeechFailure if the microphone cannot be used.
  Future<void> startListening(String languageCode);

  /// Stops listening and returns the transcript, or throws a SpeechFailure (FR-STT-02).
  Future<TranscriptResult> stopListening();

  /// Stops listening and throws away anything heard.
  Future<void> cancel();
}
