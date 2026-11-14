import 'package:kidslearn_ai/services/text_to_speech_service.dart';

/// [TextToSpeechService] that only records what it was asked to say.
class FakeTextToSpeech implements TextToSpeechService {
  FakeTextToSpeech({this.hasVoice = true});

  /// When false, [speak] answers like a phone without a voice for the language.
  final bool hasVoice;
  final List<String> spoken = [];
  final List<String> languages = [];
  int stopCount = 0;

  /// The word listener of the last [speak]; a test calls it to act like the phone's voice.
  void Function(String word)? lastOnWord;

  @override
  Future<bool> speak(
    String text,
    String languageCode, {
    void Function(String word)? onWord,
  }) async {
    if (!hasVoice) {
      return false;
    }
    spoken.add(text);
    languages.add(languageCode);
    lastOnWord = onWord;
    return true;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}
