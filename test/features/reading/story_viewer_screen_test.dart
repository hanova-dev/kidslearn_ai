import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/core/widgets/lumi_mascot.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/reading/screens/motion_scene_player.dart';

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
    motion: const MotionDirective(
      camera: 'static',
      focus: 'left',
      characterAction: 'idle_breathe',
      effect: 'none',
      mood: 'calm',
      cueWord: 'sentence',
    ),
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

  testWidgets('"The end" on the last page opens Story complete', (
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
    expect(find.text('You did it, Zayan!'), findsOneWidget);
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

  // ── Lumi's mouth and the cue word follow the voice (FR-MOTION-07, FR-MOTION-08) ──
  testWidgets(
    "each spoken word opens Lumi's mouth; the cue word moves the camera",
    (tester) async {
      await openViewer(tester);
      bool mouthOpen() =>
          tester.widget<LumiMascot>(find.byType(LumiMascot)).mouthOpen;
      MotionScenePlayer picture() =>
          tester.widget<MotionScenePlayer>(find.byType(MotionScenePlayer));

      await tester.tap(find.byTooltip('Read aloud'));
      await tester.pump();
      expect(mouthOpen(), isFalse);
      expect(picture().cueHeard, isFalse);

      voice.lastOnWord!('Sentence');
      await tester.pump();
      expect(mouthOpen(), isTrue);
      expect(picture().cueHeard, isTrue);

      await tester.pump(const Duration(milliseconds: 300));
      expect(mouthOpen(), isFalse);
      await tester.pumpAndSettle();
      final scale = tester
          .widget<Transform>(
            find.descendant(
              of: find.byType(MotionScenePlayer),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .getMaxScaleOnAxis();
      expect(scale, closeTo(1.12, 0.001));
    },
  );

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
