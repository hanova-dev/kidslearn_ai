import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_config.dart';

/// The light box "We'll write 6 short scenes…" above Create story (design p7).
class StoryInfoBox extends StatelessWidget {
  const StoryInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "We'll write ${AppConfig.scenesPerStory} short "
              'scenes and draw each one with the same characters.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
