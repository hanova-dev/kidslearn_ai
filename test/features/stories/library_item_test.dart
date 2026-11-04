import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/stories/controllers/library_item.dart';

LibraryItem makeItem(
  StoryStatus status, {
  bool approved = false,
  bool isWriting = false,
}) {
  return LibraryItem(
    story: Story(
      id: 'story-1',
      parentId: 'parent-1',
      childId: 'child-1',
      promptText: '',
      promptValue: 'Sharing',
      title: 'Mango Shares',
      moralValue: 'Sharing',
      language: 'en',
      characterSheet: '',
      seed: 1,
      status: status,
      approved: approved,
      createdAt: DateTime(2026, 11, 4),
    ),
    childName: 'Sara',
    coverPath: null,
    isWriting: isWriting,
  );
}

void main() {
  // ── Badge for every status (decision 023) ──
  test('a ready story needs a check until it is approved', () {
    expect(makeItem(StoryStatus.ready).badge, LibraryBadge.needsCheck);
    expect(
      makeItem(StoryStatus.ready, approved: true).badge,
      LibraryBadge.approved,
    );
  });

  test('a story being made shows writing, then drawing', () {
    expect(makeItem(StoryStatus.draft).badge, LibraryBadge.writing);
    expect(
      makeItem(StoryStatus.generating, isWriting: true).badge,
      LibraryBadge.writing,
    );
    expect(makeItem(StoryStatus.generating).badge, LibraryBadge.drawing);
  });

  test('a failed story shows stopped', () {
    expect(makeItem(StoryStatus.failed).badge, LibraryBadge.stopped);
  });

  // ── Which screen a card opens ──
  test('only DRAFT and GENERATING stories are in progress', () {
    expect(makeItem(StoryStatus.draft).isInProgress, isTrue);
    expect(makeItem(StoryStatus.generating).isInProgress, isTrue);
    expect(makeItem(StoryStatus.ready).isInProgress, isFalse);
    expect(makeItem(StoryStatus.failed).isInProgress, isFalse);
  });
}
