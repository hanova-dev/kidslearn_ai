import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../policy/age_experience_policy.dart';
import 'active_child.dart';

/// The policy of the active child; Listener when no child is picked yet (SRS 10.6, FR-HCI-01).
final activePolicyProvider = Provider<AgeExperiencePolicy>((ref) {
  final child = ref.watch(activeChildProvider);
  if (child == null) {
    return const ListenerPolicy();
  }
  return AgeExperiencePolicy.of(child.ageGroup);
});
