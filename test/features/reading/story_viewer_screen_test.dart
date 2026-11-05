import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_story_repository.dart';
import '../../fakes/fake_text_to_speech.dart';
import '../../helpers/test_app.dart';

ChildProfile makeChild() {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Zayan',
    buddyId: 'sky',
    ageGroup: AgeGroup.listener,
    language: 'en',
    starBalance: 0,
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

Scene makeScene(int number) {
  return Scene(
    id: 's1-scene-$number',
    storyId: 's1',
    sequenceNumber: number,
    text: 'Sentence $number.',
    imagePrompt: '',
    imagePath: null,
    imageSource: null,
  );
}

void main() {
  late FakeTextToSpeech voice;

  // ── Pick Zayan, tap story 1 on his path, land in the viewer ──
  Future<void> openViewer(WidgetTester tester, {bool hasVoice = true}) async {
    final stories = FakeStoryRepository();
    stories.stories['s1'] = makeStory();
    stories.scenes['s1'] = [makeScene(1), makeScene(2), makeScene(3)];
    voice = FakeTextToSpeech(hasVoice: hasVoice);

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: FakeChildRepository()..saved.add(makeChild()),
        stories: stories,
        voice: voice,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Zayan'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Story 1, tap to play'));
    await tester.pumpAndSettle();
  }

  // ── Turning pages (design p13, decision 006) ──
  testWidgets('Next and Previous turn the pages; no Previous on page 1', (
    tester,
  ) async {
    await openViewer(tester);

    expect(find.text('Sentence 1.'), findsOneWidget);
    expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);
    expect(find.byTooltip('Previous page').hitTestable(), findsNothing);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 2.'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous page'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 1.'), findsOneWidget);
  });

  testWidgets('"The end" on the last page goes back to the path', (
    tester,
  ) async {
    await openViewer(tester);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 3.'), findsOneWidget);

    await tester.tap(find.byTooltip('The end'));
    await tester.pumpAndSettle();
    expect(find.text('Tap to play!'), findsOneWidget);
  });

  // ── Read aloud (FR-TTS-01, FR-TTS-02) ──
  testWidgets('Read aloud says this page; turning the page stops the voice', (
    tester,
  ) async {
    await openViewer(tester);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pump();
    expect(voice.spoken, ['Sentence 1.']);
    expect(voice.languages, ['en']);

    final stopsBefore = voice.stopCount;
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(voice.stopCount, greaterThan(stopsBefore));
  });

  testWidgets('with no voice on the phone a grown-up is told what to do', (
    tester,
  ) async {
    await openViewer(tester, hasVoice: false);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pump();

    expect(
      find.textContaining('A grown-up can add one in Settings'),
      findsOneWidget,
    );
  });
}
