import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/features/reading/controllers/narration_tracker.dart';

import '../../fakes/fake_text_to_speech.dart';

void main() {
  late FakeTextToSpeech voice;
  late List<bool> mouth;
  late int cues;
  late NarrationTracker tracker;

  setUp(() {
    voice = FakeTextToSpeech();
    mouth = [];
    cues = 0;
    tracker = NarrationTracker(
      voice: voice,
      onMouth: mouth.add,
      onCue: () => cues++,
    );
  });

  // ── Words from the phone's voice (FR-MOTION-08) ──
  testWidgets('each word from the voice opens the mouth, then it closes', (
    tester,
  ) async {
    await tracker.narrate('Sky hops home.', 'en', '');
    voice.lastOnWord!('Sky');
    expect(mouth, [true]);

    await tester.pump(const Duration(milliseconds: 250));
    expect(mouth, [true, false]);
    await tracker.stop();
  });

  testWidgets('the mouth opens at most once in 340 ms', (tester) async {
    await tracker.narrate('a b c', 'en', '');
    voice.lastOnWord!('a');
    await tester.pump(const Duration(milliseconds: 100));
    voice.lastOnWord!('b');
    await tester.pump(const Duration(milliseconds: 300));
    voice.lastOnWord!('c');

    expect(mouth, [true, false, true]);
    await tracker.stop();
  });

  // ── The cue word (FR-MOTION-07) ──
  testWidgets('the cue word is found once, ignoring case and punctuation', (
    tester,
  ) async {
    await tracker.narrate('The ball! A ball.', 'en', 'ball');
    voice.lastOnWord!('The');
    expect(cues, 0);
    voice.lastOnWord!('Ball!');
    expect(cues, 1);
    await tester.pump(const Duration(milliseconds: 400));
    voice.lastOnWord!('ball.');
    expect(cues, 1);
    await tracker.stop();
  });

  // ── No words from the voice: the guess runs (decision 035) ──
  testWidgets('without word reports the guessed times move the mouth', (
    tester,
  ) async {
    await tracker.narrate('Sky finds the ball', 'en', 'ball');
    await tester.pump(Duration.zero);
    expect(mouth.first, isTrue);

    await tester.pump(const Duration(seconds: 2));
    expect(cues, 1);
    expect(mouth.last, isFalse);
  });

  testWidgets('a word from the voice stops the guessing', (tester) async {
    await tracker.narrate('Sky finds the ball', 'en', 'ball');
    voice.lastOnWord!('Sky');

    await tester.pump(const Duration(seconds: 2));
    expect(cues, 0);
    expect(mouth, [true, false]);
  });

  testWidgets('stop cancels the guesses and closes the mouth', (tester) async {
    await tracker.narrate('Sky finds the ball', 'en', 'ball');
    await tester.pump(Duration.zero);
    await tracker.stop();

    await tester.pump(const Duration(seconds: 2));
    expect(cues, 0);
    expect(mouth, [true, false]);
    expect(voice.stopCount, 1);
  });

  testWidgets('no voice for the language: nothing happens', (tester) async {
    final silent = NarrationTracker(
      voice: FakeTextToSpeech(hasVoice: false),
      onMouth: mouth.add,
      onCue: () => cues++,
    );

    expect(await silent.narrate('Sky', 'ur', ''), isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(mouth, isEmpty);
  });
}
