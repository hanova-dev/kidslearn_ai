import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/services/device_speech_recognizer.dart';

void main() {
  // ── Our language code → the phone's recogniser locale (FR-STT-03) ──
  test('English uses en_US and Urdu uses ur_PK', () {
    expect(DeviceSpeechRecognizer.localeFor('en'), 'en_US');
    expect(DeviceSpeechRecognizer.localeFor('ur'), 'ur_PK');
  });

  test('an unknown language falls back to English', () {
    expect(DeviceSpeechRecognizer.localeFor('fr'), 'en_US');
  });
}
