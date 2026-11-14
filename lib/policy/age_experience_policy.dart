import '../core/constants/app_sizes.dart';
import '../data/models/age_group.dart';
import 'motion_profile.dart';

/// What changes between the two age groups; screens ask the policy instead of checking the age (SRS 10.6, FR-HCI-01).
abstract class AgeExperiencePolicy {
  const AgeExperiencePolicy();

  /// The policy for one age group: Listener for 2–4, Reader for 5–7 (FR-MODE-01).
  static AgeExperiencePolicy of(AgeGroup ageGroup) {
    if (ageGroup == AgeGroup.reader) {
      return const ReaderPolicy();
    }
    return const ListenerPolicy();
  }

  /// Saved in reading_sessions.mode: 'LISTENER' or 'READER'.
  String get sessionMode;

  /// True when the child reads each sentence aloud into the microphone.
  bool get readsAloud;

  /// The smallest button size on child screens (SRS 10.7).
  double get touchTarget;

  /// The size of the page text (SRS 10.7; smaller for 2–3 sentences, decision 032).
  double get storyTextSize;

  /// How much the picture may move (M11, FR-MOTION-04).
  MotionProfile get motion;
}

/// Ages 2–4: the story viewer with read aloud, no microphone and no scoring.
class ListenerPolicy extends AgeExperiencePolicy {
  const ListenerPolicy();

  @override
  String get sessionMode => 'LISTENER';

  @override
  bool get readsAloud => false;

  @override
  double get touchTarget => AppSizes.listenerTouchTarget;

  @override
  double get storyTextSize => 24;

  @override
  MotionProfile get motion => MotionProfile.listener;
}

/// Ages 5–7: Reader Mode, the child reads each sentence aloud and sees coloured words.
class ReaderPolicy extends AgeExperiencePolicy {
  const ReaderPolicy();

  @override
  String get sessionMode => 'READER';

  @override
  bool get readsAloud => true;

  @override
  double get touchTarget => AppSizes.readerTouchTarget;

  @override
  double get storyTextSize => 22;

  @override
  MotionProfile get motion => MotionProfile.reader;
}
