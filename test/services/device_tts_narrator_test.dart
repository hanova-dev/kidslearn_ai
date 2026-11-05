import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/services/device_tts_narrator.dart';

void main() {
  // ── Voice for the child's language (FR-TTS-02) ──
  test('English uses en-US and Urdu uses ur-PK', () {
    expect(DeviceTtsNarrator.voiceTagFor('en'), 'en-US');
    expect(DeviceTtsNarrator.voiceTagFor('ur'), 'ur-PK');
  });

  test('an unknown language falls back to English', () {
    expect(DeviceTtsNarrator.voiceTagFor('fr'), 'en-US');
  });
}
