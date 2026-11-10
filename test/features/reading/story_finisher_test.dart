import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/features/reading/controllers/story_finisher.dart';

import '../../fakes/fake_child_repository.dart';
import '../../fakes/fake_reading_session_repository.dart';

ChildProfile makeChild(AgeGroup ageGroup) {
  return ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Ali',
    buddyId: 'mango',
    ageGroup: ageGroup,
    language: 'en',
    starBalance: 4,
    readingLevel: 1,
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
  final scenes = [
    makeScene(1, 'Sky hops home.'),
    makeScene(2, 'Sky  finds a   warm bed.'),
  ];

  // ── Counting words ──
  test('countWords counts words and ignores extra spaces', () {
    expect(StoryFinisher.countWords(scenes), 8);
    expect(StoryFinisher.countWords([]), 0);
  });

  // ── Saving a finished reading (FR-MODE-06, decision 026) ──
  test('finish saves one session and adds the stars it is given', () async {
    final sessions = FakeReadingSessionRepository();
    final children = FakeChildRepository()
      ..saved.add(makeChild(AgeGroup.reader));
    final finisher = StoryFinisher(sessions, children);

    final result = await finisher.finish(
      child: makeChild(AgeGroup.reader),
      storyId: 's1',
      scenes: scenes,
      stars: 2,
      now: DateTime(2026, 11, 6, 10),
    );

    expect(result.wordsRead, 8);
    expect(result.stars, 2);
    expect(sessions.saved.length, 1);
    expect(sessions.saved.first.storyId, 's1');
    expect(sessions.saved.first.mode, 'READER');
    expect(sessions.saved.first.starsEarned, 2);
    expect(children.saved.first.starBalance, 6);
  });

  test('a 2-4 child gets mode LISTENER; reading again saves again', () async {
    final sessions = FakeReadingSessionRepository();
    final children = FakeChildRepository()
      ..saved.add(makeChild(AgeGroup.listener));
    final finisher = StoryFinisher(sessions, children);

    for (var i = 0; i < 2; i++) {
      await finisher.finish(
        child: makeChild(AgeGroup.listener),
        storyId: 's1',
        scenes: scenes,
        stars: 2,
        now: DateTime(2026, 11, 6, 10, i),
      );
    }

    expect(sessions.saved.length, 2);
    expect(sessions.saved.first.mode, 'LISTENER');
    expect(sessions.saved[0].id == sessions.saved[1].id, isFalse);
    expect(children.saved.first.starBalance, 8);
  });
}
