import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_reading_session_repository.dart';
import '../../fakes/fake_story_repository.dart';
import '../../fakes/fake_text_to_speech.dart';
import '../../helpers/test_app.dart';

ChildProfile makeChild() {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Ali',
    buddyId: 'mango',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 5,
    readingLevel: 1,
    createdAt: DateTime(2026, 11, 1),
  );
}

Story makeStory(String id, int day) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: '',
    promptValue: 'Sharing',
    title: 'Story $id',
    moralValue: 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: StoryStatus.ready,
    approved: true,
    createdAt: DateTime(2026, 11, day),
  );
}

Scene makeScene(String storyId, int number) {
  return Scene(
    id: '$storyId-scene-$number',
    storyId: storyId,
    sequenceNumber: number,
    text: 'Mango reads page $number.',
    imagePrompt: '',
    imagePath: null,
    imageSource: null,
  );
}

void main() {
  late FakeReadingSessionRepository sessions;
  late FakeChildRepository children;
  late FakeTextToSpeech voice;

  // ── Pick Ali, read story 1 (2 pages) to the end ──
  Future<void> finishStoryOne(WidgetTester tester) async {
    final stories = FakeStoryRepository();
    for (final story in [makeStory('s1', 1), makeStory('s2', 2)]) {
      stories.stories[story.id] = story;
      stories.scenes[story.id] = [
        makeScene(story.id, 1),
        makeScene(story.id, 2),
      ];
    }
    sessions = FakeReadingSessionRepository();
    children = FakeChildRepository()..saved.add(makeChild());
    voice = FakeTextToSpeech();

    usePhoneScreen(tester);
    await tester.pumpWidget(
      buildTestApp(
        auth: FakeAuthRepository(signedInUserId: 'parent-1'),
        children: children,
        stories: stories,
        sessions: sessions,
        voice: voice,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Story 1, tap to play'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('The end'));
    await tester.pumpAndSettle();
  }

  // ── Celebration with words and stars (design p22, FR-MODE-06) ──
  testWidgets('shows words read, stars earned and says the cheer', (
    tester,
  ) async {
    await finishStoryOne(tester);

    expect(find.text('You did it, Ali!'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    expect(voice.spoken, contains('You did it, Ali!'));
    expect(sessions.saved.length, 1);
    expect(sessions.saved.first.storyId, 's1');
    expect(children.saved.first.starBalance, 7);
  });

  // ── Next adventure: story 2 is unlocked, stars are shown (SRS 10.10) ──
  testWidgets('Next adventure shows the path with story 2 unlocked', (
    tester,
  ) async {
    await finishStoryOne(tester);

    await tester.tap(find.text('Next adventure'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Story 1, finished'), findsOneWidget);
    expect(find.bySemanticsLabel('Story 2, tap to play'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('Read it again opens page 1 of the same story', (tester) async {
    await finishStoryOne(tester);

    await tester.tap(find.text('Read it again'));
    await tester.pumpAndSettle();

    expect(find.text('Mango reads page 1.'), findsOneWidget);
    expect(find.bySemanticsLabel('Page 1 of 2'), findsOneWidget);
  });
}
