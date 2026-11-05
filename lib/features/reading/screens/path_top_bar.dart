import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Top of the path map: Back on the left, the child's stars in the middle (design p15).
class PathTopBar extends StatelessWidget {
  const PathTopBar({super.key, required this.stars, required this.onBack});

  final int stars;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // ── Back button ──
          SizedBox(
            width: AppSizes.listenerTouchTarget,
            height: AppSizes.listenerTouchTarget,
            child: IconButton(
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: colors.ink,
                side: BorderSide(color: colors.border, width: 2),
              ),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 26),
            ),
          ),
          const Spacer(),

          // ── Star count ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Color.lerp(colors.surface, colors.sunshine, 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: colors.sunshine, size: 30),
                const SizedBox(width: 6),
                Text(
                  '$stars',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: colors.ink),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(width: AppSizes.listenerTouchTarget),
        ],
      ),
    );
  }
}
