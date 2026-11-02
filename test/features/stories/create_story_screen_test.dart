import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_story_generator.dart';
import '../../fakes/fake_story_repository.dart';
import '../../helpers/test_app.dart';

void main() {
  // ── Open Create story: Who's reading → parent home → Create a story ──
  Future<void> openCreateStory(
    WidgetTester tester, {
    required FakeStoryRepository stories,
    required FakeStoryGenerator generator,
  }) async {
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
        createdAt: DateTime(2026, 11, 2),
      ),
    );
    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
        stories: stories,
        storyGenerator: generator,
        parentUnlocked: true,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Grown-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a story'));
    await tester.pumpAndSettle();
  }

  // ── Too-short prompt is stopped before any call (FR-STORY-05) ──
  testWidgets('a short prompt shows guidance and calls nothing', (
    tester,
  ) async {
    final generator = FakeStoryGenerator();
    final stories = FakeStoryRepository();
    await openCreateStory(tester, stories: stories, generator: generator);
    await tester.enterText(find.byType(TextField), 'Ali hits');

    await tester.tap(find.text('Create story'));
    await tester.pump();

    expect(find.textContaining('Please write a little more'), findsOneWidget);
    expect(generator.prompts, isEmpty);
    expect(stories.stories, isEmpty);
  });

  // ── Writing, then ready ──
  testWidgets('shows writing, then the ready story title', (tester) async {
    final generator = FakeStoryGenerator();
    generator.gate = Completer<void>();
    final stories = FakeStoryRepository();
    await openCreateStory(tester, stories: stories, generator: generator);
    expect(find.text('Zayan · 2–4'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      "Zayan doesn't want to share his toys",
    );
    await tester.tap(find.text('Sharing'));

    await tester.tap(find.text('Create story'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Lumi is writing your story…'), findsOneWidget);
    expect(stories.stories.values.single.status, StoryStatus.generating);

    generator.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Your story is ready!'), findsOneWidget);
    expect(find.text('Mango Shares the Ball'), findsOneWidget);
    expect(generator.prompts.single.behaviour, contains('Mango'));
  });

  // ── Failure with retry (FR-STORY-04, NFR-USE-03) ──
  testWidgets('a failure shows a plain message and Try again works', (
    tester,
  ) async {
    final generator = FakeStoryGenerator(failuresBeforeSuccess: 1);
    await openCreateStory(
      tester,
      stories: FakeStoryRepository(),
      generator: generator,
    );
    await tester.tap(find.text('Kindness'));

    await tester.tap(find.text('Create story'));
    await tester.pumpAndSettle();

    expect(find.text('Lumi got stuck'), findsOneWidget);
    expect(find.textContaining('busy right now'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Your story is ready!'), findsOneWidget);
  });
}
