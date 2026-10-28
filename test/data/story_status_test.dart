import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';

void main() {
  // ── Allowed moves (FR-STORY-04) ──
  test('the normal path and retries are allowed', () {
    expect(StoryStatus.draft.canMoveTo(StoryStatus.generating), isTrue);
    expect(StoryStatus.generating.canMoveTo(StoryStatus.ready), isTrue);
    expect(StoryStatus.generating.canMoveTo(StoryStatus.failed), isTrue);
    expect(StoryStatus.failed.canMoveTo(StoryStatus.generating), isTrue);
    expect(StoryStatus.ready.canMoveTo(StoryStatus.generating), isTrue);
  });

  // ── Forbidden moves ──
  test('skipping GENERATING or going back to DRAFT is not allowed', () {
    expect(StoryStatus.draft.canMoveTo(StoryStatus.ready), isFalse);
    expect(StoryStatus.ready.canMoveTo(StoryStatus.draft), isFalse);
    expect(StoryStatus.failed.canMoveTo(StoryStatus.ready), isFalse);
    expect(StoryStatus.generating.canMoveTo(StoryStatus.draft), isFalse);
  });

  // ── Saved text ──
  test('database text goes both ways', () {
    for (final status in StoryStatus.values) {
      expect(StoryStatus.fromDbValue(status.dbValue), status);
    }
    expect(StoryStatus.generating.dbValue, 'GENERATING');
  });
}
