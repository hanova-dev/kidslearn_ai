import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/reading_session.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_reading_session_repository.dart';
import '../../fakes/fake_story_repository.dart';
import '../../helpers/test_app.dart';

ChildProfile makeChild() {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Fatima',
    buddyId: 'mango',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 7,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 1),
  );
}

Story makeStory(String id, String title, int day, {bool approved = true}) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: '',
    promptValue: 'Sharing',
    title: title,
    moralValue: 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: StoryStatus.ready,
    approved: approved,
    createdAt: DateTime(2026, 11, day),
  );
}

void main() {
  // ── Open the app, pick Fatima, land on her path ──
  Future<void> openPath(
    WidgetTester tester, {
    List<Story> storyList = const [],
    List<String> finishedIds = const [],
  }) async {
    final stories = FakeStoryRepository();
    for (final story in storyList) {
      stories.stories[story.id] = story;
      stories.scenes[story.id] = [
        Scene(
          id: '${story.id}-scene-1',
          storyId: story.id,
          sequenceNumber: 1,
          text: 'Mango wakes up.',
          imagePrompt: '',
          imagePath: null,
          imageSource: null,
        ),
      ];
    }
    final sessions = FakeReadingSessionRepository();
    for (final storyId in finishedIds) {
      sessions.saved.add(
        ReadingSession(
          id: 'session-$storyId',
          childId: 'child-1',
          storyId: storyId,
          mode: 'READER',
          wordsRead: 18,
          starsEarned: 3,
          lastModified: DateTime(2026, 11, 4),
        ),
      );
    }

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: FakeChildRepository()..saved.add(makeChild()),
        stories: stories,
        sessions: sessions,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Fatima'));
    await tester.pumpAndSettle();
  }

  // ── Finished, current and locked circles (SRS 10.10, D1) ──
  testWidgets('approved stories become circles: finished, current, locked', (
    tester,
  ) async {
    await openPath(
      tester,
      storyList: [
        makeStory('s1', 'Mango Shares', 1),
        makeStory('s2', 'Honest Hana', 2),
        makeStory('s3', 'Patient Panda', 3),
        makeStory('hidden', 'Not Approved', 4, approved: false),
      ],
      finishedIds: ['s1'],
    );

    expect(find.bySemanticsLabel('Story 1, finished'), findsOneWidget);
    expect(find.bySemanticsLabel('Story 2, tap to play'), findsOneWidget);
    expect(find.bySemanticsLabel('Story 3, locked'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Story 4')), findsNothing);
    expect(find.text('Tap to play!'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets(
    'a locked circle says to finish the glowing story; the current one opens',
    (tester) async {
      await openPath(
        tester,
        storyList: [
          makeStory('s1', 'Mango Shares', 1),
          makeStory('s2', 'Honest Hana', 2),
        ],
      );

      await tester.tap(find.bySemanticsLabel('Story 2, locked'));
      await tester.pump();
      expect(find.text('Finish the glowing story first!'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Story 1, tap to play'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Read aloud'), findsOneWidget);
    },
  );

  // ── No approved stories yet ──
  testWidgets('with no stories the buddy asks for a grown-up; Back returns', (
    tester,
  ) async {
    await openPath(tester);

    expect(find.text('No stories yet.'), findsOneWidget);
    expect(find.text('Ask a grown-up to make one!'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text("Who's reading today?"), findsOneWidget);
  });
}
