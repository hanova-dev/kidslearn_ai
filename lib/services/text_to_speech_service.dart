/// Reads story text aloud; screens only know this interface (SRS 4.3, FR-TTS-01).
abstract class TextToSpeechService {
  /// Reads [text] aloud in [languageCode] ('en' or 'ur'); returns false if the phone has no voice for it (FR-TTS-02).
  ///
  /// [onWord] is called with each word as the voice starts it, if the phone's voice reports words (FR-MOTION-07).
  Future<bool> speak(
    String text,
    String languageCode, {
    void Function(String word)? onWord,
  });

  /// Stops reading at once.
  Future<void> stop();
}
