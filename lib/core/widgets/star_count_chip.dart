import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

/// The child's star count in a sunshine pill, e.g. "★ 12" (designs p15, p18).
class StarCountChip extends StatelessWidget {
  const StarCountChip({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Color.lerp(colors.surface, colors.sunshine, 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}
