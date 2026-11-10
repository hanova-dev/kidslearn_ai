import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/policy/age_experience_policy.dart';

void main() {
  // ── One policy per age group (SRS 10.6, FR-MODE-01) ──
  test('2-4 gets the Listener policy: no microphone', () {
    final policy = AgeExperiencePolicy.of(AgeGroup.listener);

    expect(policy, isA<ListenerPolicy>());
    expect(policy.readsAloud, isFalse);
    expect(policy.sessionMode, 'LISTENER');
    expect(policy.touchTarget, 64);
    expect(policy.storyTextSize, 30);
  });

  test('5-7 gets the Reader policy: reads aloud', () {
    final policy = AgeExperiencePolicy.of(AgeGroup.reader);

    expect(policy, isA<ReaderPolicy>());
    expect(policy.readsAloud, isTrue);
    expect(policy.sessionMode, 'READER');
    expect(policy.touchTarget, 56);
    expect(policy.storyTextSize, inInclusiveRange(22, 26));
  });
}
