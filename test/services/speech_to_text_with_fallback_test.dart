import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/services/speech_to_text_with_fallback.dart';

import '../fakes/fake_speech_to_text.dart';

void main() {
  late FakeSpeechToText whisper;
  late FakeSpeechToText device;
  late SpeechToTextWithFallback speech;

  setUp(() {
    whisper = FakeSpeechToText(source: 'WHISPER');
    device = FakeSpeechToText(source: 'DEVICE');
    speech = SpeechToTextWithFallback(primary: whisper, fallback: device);
  });

  // ── Whisper first ──
  test('Whisper is used while it works', () async {
    await speech.startListening('en');
    final result = await speech.stopListening();

    expect(result.source, 'WHISPER');
    expect(whisper.startedLanguages, ['en']);
    expect(device.startedLanguages, isEmpty);
    expect(speech.usingFallback, isFalse);
  });

  // ── Switch when Whisper is down (FR-STT-07, decision 028) ──
  test(
    'when Whisper is down, the child reads once more with the phone',
    () async {
      whisper.nextFailure = const SpeechFailure(
        'No internet for listening.',
        serviceDown: true,
      );

      await speech.startListening('en');
      SpeechFailure? failure;
      try {
        await speech.stopListening();
      } on SpeechFailure catch (error) {
        failure = error;
      }

      expect(failure?.message, "Let's read that sentence once more.");
      expect(failure?.serviceDown, isFalse);
      expect(speech.usingFallback, isTrue);

      await speech.startListening('en');
      final result = await speech.stopListening();

      expect(result.source, 'DEVICE');
      expect(device.startedLanguages, ['en']);
      expect(whisper.startedLanguages, ['en']);
    },
  );

  test('"we didn\'t hear you" does not switch', () async {
    whisper.nextFailure = const SpeechFailure("We didn't hear anything.");

    await speech.startListening('en');
    await expectLater(
      speech.stopListening(),
      throwsA(
        isA<SpeechFailure>().having(
          (error) => error.message,
          'message',
          "We didn't hear anything.",
        ),
      ),
    );

    expect(speech.usingFallback, isFalse);
  });

  test('a problem with the phone recogniser is passed on', () async {
    whisper.nextFailure = const SpeechFailure('Busy.', serviceDown: true);
    await speech.startListening('en');
    await expectLater(speech.stopListening(), throwsA(isA<SpeechFailure>()));
    device.nextFailure = const SpeechFailure("We didn't hear anything.");

    await speech.startListening('en');

    await expectLater(
      speech.stopListening(),
      throwsA(
        isA<SpeechFailure>().having(
          (error) => error.message,
          'message',
          "We didn't hear anything.",
        ),
      ),
    );
    expect(speech.usingFallback, isTrue);
  });

  // ── Cancel ──
  test('cancel stops the service that is listening', () async {
    await speech.startListening('en');
    await speech.cancel();

    expect(whisper.cancelCount, 1);
    expect(device.cancelCount, 0);
  });
}
