import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/phonetic_scorer.dart';
import 'package:kidslearn_ai/algorithms/verdict.dart';
import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/features/reading/controllers/reading_controller.dart';

import '../../fakes/fake_speech_to_text.dart';

void main() {
  late FakeSpeechToText speech;
  late ReadingController controller;

  setUp(() {
    speech = FakeSpeechToText(source: 'WHISPER');
    controller = ReadingController(speech, const PhoneticScorer());
  });

  // ── Transcript, then scoring (FR-MODE-05, decision 004) ──
  test('scores every word of the sentence against the transcript', () async {
    speech.nextText = 'The little rabbit shared her carrots';

    await controller.startReading('en');
    final check = await controller.finishReading(
      'The little rabbit shared her carrots.',
      'en',
    );

    expect(speech.startedLanguages, ['en']);
    expect(check.results.length, 6);
    expect(check.overall, Verdict.correct);
    expect(check.stars, 3);
  });

  test(
    'a skipped word is TRY_AGAIN and becomes the word to practise',
    () async {
      speech.nextText = 'The little shared her carrots';

      await controller.startReading('en');
      final check = await controller.finishReading(
        'The little rabbit shared her carrots.',
        'en',
      );

      expect(check.results[2].verdict, Verdict.tryAgain);
      expect(check.wordToPractise?.word, 'rabbit');
      expect(check.stars, 2);
    },
  );

  // ── Problems are passed on to the screen (FR-STT-05) ──
  test('a "did not hear you" failure reaches the screen', () async {
    speech.nextFailure = const SpeechFailure("We didn't hear anything.");

    await controller.startReading('en');

    await expectLater(
      controller.finishReading('Sky hops.', 'en'),
      throwsA(isA<SpeechFailure>()),
    );
  });

  test('cancel turns the microphone off', () async {
    await controller.startReading('en');
    await controller.cancel();

    expect(speech.cancelCount, 1);
  });
}
