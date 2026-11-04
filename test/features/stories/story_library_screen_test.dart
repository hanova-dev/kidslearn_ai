import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_story_repository.dart';
import '../../helpers/test_app.dart';

ChildProfile makeChild(String id, String name) {
  return ChildProfile(
    id: id,
    parentId: 'parent-1',
    name: name,
    buddyId: 'mango',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 1),
  );
}

Story makeStory(
  String id,
  String childId,
  String title,
  StoryStatus status,
  int day, {
  bool approved = false,
}) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: childId,
    promptText: '',
    promptValue: 'Sharing',
    title: title,
    moralValue: title.isEmpty ? '' : 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: status,
    approved: approved,
    createdAt: DateTime(2026, 11, day),
  );
}

void main() {
  late FakeStoryRepository stories;

  // ── Three stories (stopped, needs check, approved), then open the library ──
  Future<void> openLibrary(WidgetTester tester, {bool empty = false}) async {
    stories = FakeStoryRepository();
    if (!empty) {
      for (final story in [
        makeStory('s1', 'child-2', '', StoryStatus.failed, 4),
        makeStory('s2', 'child-2', 'Sky Shares', StoryStatus.ready, 3),
        makeStory(
          's3',
          'child-1',
          'Mango Waits',
          StoryStatus.ready,
          2,
          approved: true,
        ),
      ]) {
        stories.stories[story.id] = story;
      }
    }
    final children = FakeChildRepository();
    children.saved.add(makeChild('child-1', 'Ali'));
    children.saved.add(makeChild('child-2', 'Sara'));
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
        stories: stories,
        parentUnlocked: true,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
  }

  // ── Cards, badges and the child filter ──
  testWidgets('shows every story with its badge and filters by child', (
    tester,
  ) async {
    await openLibrary(tester);

    expect(find.text('Story library'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);
    expect(find.text('Needs check'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();
    expect(find.text('Mango Waits'), findsOneWidget);
    expect(find.text('Sky Shares'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Sky Shares'), findsOneWidget);
  });

  // ── Open a ready story and approve it (FR-STORY-07) ──
  testWidgets(
    'a story that needs a check opens the preview and can be approved',
    (tester) async {
      await openLibrary(tester);

      await tester.tap(find.text('Sky Shares'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve for Sara'));
      await tester.pumpAndSettle();

      expect(stories.stories['s2']!.approved, isTrue);
      expect(find.text('Story library'), findsOneWidget);
      expect(find.text('Needs check'), findsNothing);
      expect(find.text('Approved'), findsNWidgets(2));
    },
  );

  // ── A stopped story can be made again, not approved (decision 023) ──
  testWidgets('a stopped story opens with a note and no Approve button', (
    tester,
  ) async {
    await openLibrary(tester);

    await tester.tap(find.text('New story'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This story stopped before it was finished. '
        'Tap "Make a new version" to try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Approve for Sara'), findsNothing);
    expect(find.text('Make a new version'), findsOneWidget);
  });

  // ── Empty library and the Home tab ──
  testWidgets('an empty library shows a hint, and Home goes back', (
    tester,
  ) async {
    await openLibrary(tester, empty: true);

    expect(
      find.text('No stories yet. Go to Home and tap "Create a story".'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });
}
