import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_illustrator.dart';
import '../../fakes/fake_story_generator.dart';
import '../../fakes/fake_story_repository.dart';
import '../../helpers/test_app.dart';

void main() {
  late FakeStoryRepository stories;
  late FakeStoryGenerator generator;
  late FakeIllustrator flux;

  // ── Make a Kindness story for Zayan, then open its preview ──
  Future<void> openPreview(
    WidgetTester tester, {
    Set<String>? fluxFails,
  }) async {
    stories = FakeStoryRepository();
    generator = FakeStoryGenerator();
    flux = FakeIllustrator(failPrompts: fluxFails ?? {});
    final children = FakeChildRepository();
    children.saved.add(
      ChildProfile(
        id: 'child-1',
        parentId: 'parent-1',
        name: 'Zayan',
        buddyId: 'mango',
        ageGroup: AgeGroup.listener,
        language: 'en',
        starBalance: 0,
        readingLevel: 1,
        createdAt: DateTime(2026, 11, 3),
      ),
    );
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
        stories: stories,
        storyGenerator: generator,
        illustrator: flux,
        parentUnlocked: true,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kindness'));
    await tester.tap(find.text('Create story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview story'));
    await tester.pumpAndSettle();
  }

  // ── Approve (FR-STORY-07) ──
  testWidgets('shows the story and Approve lets the child see it', (
    tester,
  ) async {
    await openPreview(tester);

    expect(find.text('Mango Shares the Ball'), findsOneWidget);
    expect(find.text('Mango has a red ball.'), findsOneWidget);

    await tester.tap(find.text('Approve for Zayan'));
    await tester.pumpAndSettle();

    expect(stories.stories.values.single.approved, isTrue);
    expect(find.text('Approved. Zayan can read it.'), findsOneWidget);
    expect(find.text('Story library'), findsOneWidget);
  });

  // ── Delete after a confirm dialog (FR-STORY-07) ──
  testWidgets('Delete asks first, then removes the story', (tester) async {
    await openPreview(tester);

    await tester.tap(find.text('Delete story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stories.stories, hasLength(1));

    await tester.tap(find.text('Delete story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(stories.stories, isEmpty);
    expect(find.text('Story deleted.'), findsOneWidget);
  });

  // ── New version from the same prompt (FR-STORY-06) ──
  testWidgets('Make a new version writes the story again', (tester) async {
    await openPreview(tester);

    await tester.tap(find.text('Make a new version'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make new version'));
    await tester.pumpAndSettle();

    expect(generator.prompts, hasLength(2));
    expect(generator.prompts[1].value, 'Kindness');
    expect(find.text('Your story is ready!'), findsOneWidget);
    expect(stories.stories, hasLength(1));
  });

  // ── Draw simple pictures again (FR-ILLUS-06) ──
  testWidgets('Draw pictures again replaces the simple picture', (
    tester,
  ) async {
    await openPreview(tester, fluxFails: {'giving'});
    final redraw = find.text('Draw pictures again');
    await tester.scrollUntilVisible(
      redraw,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(redraw);
    await tester.pumpAndSettle();
    expect(
      find.text('Simple pictures: 1 of 3. FLUX can try to draw them again.'),
      findsOneWidget,
    );

    flux.failPrompts.clear();
    await tester.tap(redraw);
    await tester.pumpAndSettle();

    expect(find.text('All pictures are drawn now.'), findsOneWidget);
    expect(redraw, findsNothing);
  });
}
