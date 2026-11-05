/// Reads story text aloud; screens only know this interface (SRS 4.3, FR-TTS-01).
abstract class TextToSpeechService {
  /// Reads [text] aloud in [languageCode] ('en' or 'ur'); returns false if the phone has no voice for it (FR-TTS-02).
  Future<bool> speak(String text, String languageCode);

  /// Stops reading at once.
  Future<void> stop();
}
