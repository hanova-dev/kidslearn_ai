import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/star_count_chip.dart';

/// Top of the path map: Back on the left, the child's stars in the middle (design p15).
class PathTopBar extends StatelessWidget {
  const PathTopBar({super.key, required this.stars, required this.onBack});

  final int stars;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // ── Back button ──
          RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            tooltip: 'Back',
            onPressed: onBack,
          ),
          const Spacer(),

          // ── Star count ──
          StarCountChip(stars: stars),
          const Spacer(),
          const SizedBox(width: AppSizes.listenerTouchTarget),
        ],
      ),
    );
  }
}
