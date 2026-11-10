import 'package:flutter/material.dart';

import '../../../algorithms/verdict.dart';
import '../../../app/app_colors.dart';

/// The colour, icon and spoken label of one verdict; never solid red (SRS 10.8, 10.9, FR-HCI-05).
class VerdictStyle {
  const VerdictStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;

  /// Read by TalkBack after the word, e.g. "rabbit, try again".
  final String label;

  /// Green for CORRECT, amber for NEAR_MISS, soft coral for TRY_AGAIN.
  static VerdictStyle of(Verdict verdict, AppColors colors) {
    if (verdict == Verdict.correct) {
      return VerdictStyle(
        color: colors.leaf,
        icon: Icons.star_rounded,
        label: 'correct',
      );
    }
    if (verdict == Verdict.nearMiss) {
      return VerdictStyle(
        color: colors.amber,
        icon: Icons.volume_up_rounded,
        label: 'so close',
      );
    }
    return VerdictStyle(
      color: colors.coralSoft,
      icon: Icons.replay_rounded,
      label: 'try again',
    );
  }
}
