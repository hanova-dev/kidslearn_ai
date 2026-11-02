import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/features/stories/controllers/story_input_check.dart';

void main() {
  // ── Rejected input (FR-STORY-05) ──
  test('empty text and no value is rejected', () {
    expect(StoryInputCheck.check('   ', ''), isNotNull);
  });

  test('short text is rejected even when a value is picked', () {
    expect(StoryInputCheck.check('Ali hits', 'Kindness'), isNotNull);
  });

  test('text over the maximum is rejected', () {
    expect(StoryInputCheck.check('a' * 301, ''), isNotNull);
  });

  test('spaces around the text do not count', () {
    expect(StoryInputCheck.check('   Ali hits   ', ''), isNotNull);
  });

  // ── Accepted input (decision 019: text or a value) ──
  test('only a value is accepted', () {
    expect(StoryInputCheck.check('', 'Sharing'), isNull);
  });

  test('15 letters of text with no value is accepted', () {
    expect(StoryInputCheck.check('Ali will not sh', ''), isNull);
  });
}
