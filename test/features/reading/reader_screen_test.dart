import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_reading_session_repository.dart';
import '../../fakes/fake_speech_to_text.dart';
import '../../fakes/fake_story_repository.dart';
import '../../fakes/fake_text_to_speech.dart';
import '../../helpers/test_app.dart';

ChildProfile makeChild() {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Sara',
    buddyId: 'sky',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 5,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 1),
  );
}

Story makeStory() {
  return Story(
    id: 's1',
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: '',
    promptValue: 'Sharing',
    title: 'Sky Shares',
    moralValue: 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: StoryStatus.ready,
    approved: true,
    createdAt: DateTime(2026, 11, 1),
  );
}

Scene makeScene(int number, String text) {
  return Scene(
    id: 's1-scene-$number',
    storyId: 's1',
    sequenceNumber: number,
    text: text,
    imagePrompt: '',
    imagePath: null,
    imageSource: null,
  );
}

void main() {
  late FakeSpeechToText speech;
  late FakeTextToSpeech voice;
  late FakeReadingSessionRepository sessions;

  // ── Pick Sara (5–7), tap story 1, land in Reader Mode ──
  Future<void> openReader(WidgetTester tester) async {
    final stories = FakeStoryRepository();
    stories.stories['s1'] = makeStory();
    stories.scenes['s1'] = [
      makeScene(1, 'The rabbit hops.'),
      makeScene(2, 'Sky hops home.'),
    ];
    speech = FakeSpeechToText(source: 'WHISPER');
    voice = FakeTextToSpeech();
    sessions = FakeReadingSessionRepository();

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: FakeChildRepository()..saved.add(makeChild()),
        stories: stories,
        sessions: sessions,
        voice: voice,
        speech: speech,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Sara'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Story 1, tap to play'));
    await tester.pumpAndSettle();
  }

  Future<void> readSentence(WidgetTester tester, String spoken) async {
    speech.nextText = spoken;
    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();
  }

  // ── Mic, listening, coloured words (designs p18–p20, FR-MODE-05) ──
  testWidgets('a 5-7 child reads aloud and every word turns green', (
    tester,
  ) async {
    await openReader(tester);

    expect(find.text('Tap and read'), findsOneWidget);
    expect(find.text('Next page'), findsNothing);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pumpAndSettle();
    expect(find.text("I'm listening…"), findsOneWidget);
    expect(speech.startedLanguages, ['en']);

    speech.nextText = 'The rabbit hops';
    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('rabbit, correct'), findsOneWidget);
    expect(find.bySemanticsLabel('hops., correct'), findsOneWidget);
    expect(find.text('Great reading!'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(voice.spoken, contains('Great reading!'));
    expect(find.text('Next page'), findsOneWidget);
  });

  testWidgets('a skipped word is soft coral and the phone says it', (
    tester,
  ) async {
    await openReader(tester);

    await readSentence(tester, 'The hops');

    expect(find.bySemanticsLabel('rabbit, try again'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(voice.spoken, contains("Let's try that one together: rabbit"));
  });

  // ── Nothing heard: a friendly message and the mic again (FR-STT-05) ──
  testWidgets('when nothing is heard the child can simply try again', (
    tester,
  ) async {
    await openReader(tester);
    speech.nextFailure = const SpeechFailure(
      "We didn't hear anything. Tap the microphone and read again.",
    );

    await readSentence(tester, '');

    expect(
      find.text("We didn't hear anything. Tap the microphone and read again."),
      findsOneWidget,
    );
    expect(find.byTooltip('Read aloud'), findsOneWidget);
    expect(find.text('Next page'), findsNothing);
  });

  // ── Best stars per page, then save the reading (decisions 009, 026) ──
  testWidgets('Read again keeps the best stars; The end saves them', (
    tester,
  ) async {
    await openReader(tester);

    await readSentence(tester, 'The rabbit hops');
    await tester.tap(find.text('Read again'));
    await tester.pumpAndSettle();
    await readSentence(tester, 'The hops');
    expect(find.text('8'), findsOneWidget);

    await tester.tap(find.text('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Sky'), findsOneWidget);

    await readSentence(tester, 'Sky hops home');
    await tester.tap(find.text('The end'));
    await tester.pumpAndSettle();

    expect(find.text('You did it, Sara!'), findsOneWidget);
    expect(find.text('+6'), findsOneWidget);
    expect(sessions.saved.single.mode, 'READER');
    expect(sessions.saved.single.starsEarned, 6);
  });

  // ── The microphone is never left on (FR-STT-01) ──
  testWidgets('leaving while listening turns the microphone off', (
    tester,
  ) async {
    await openReader(tester);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(speech.cancelCount, 1);
    expect(find.bySemanticsLabel('Story 1, tap to play'), findsOneWidget);
  });
}
