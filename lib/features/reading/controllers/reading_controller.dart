import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../algorithms/phonetic_scorer.dart';
import '../../../app/providers.dart';
import '../../../services/speech_to_text_service.dart';
import 'sentence_check.dart';

/// Listens to the child reading one sentence and scores every word (FR-STT-01, FR-MODE-04, FR-MODE-05).
class ReadingController {
  ReadingController(this._speech, this._scorer);

  final SpeechToTextService _speech;
  final PhoneticScorer _scorer;

  /// Turns the microphone on; throws a SpeechFailure if it cannot be used.
  Future<void> startReading(String languageCode) {
    return _speech.startListening(languageCode);
  }

  // ── Transcript, then scoring (decision 004: the whole sentence at once) ──
  /// Turns the microphone off and scores what the child said against [sentence].
  Future<SentenceCheck> finishReading(
    String sentence,
    String languageCode,
  ) async {
    final transcript = await _speech.stopListening();
    final results = _scorer.scoreSentence(
      sentence,
      transcript.text,
      languageCode,
    );
    return SentenceCheck(results);
  }

  /// Turns the microphone off and forgets what was heard, e.g. when the child leaves the screen.
  Future<void> cancel() {
    return _speech.cancel();
  }
}

/// The one [ReadingController], built from the speech service in providers.dart.
final readingControllerProvider = Provider<ReadingController>((ref) {
  return ReadingController(
    ref.watch(speechToTextServiceProvider),
    const PhoneticScorer(),
  );
});
