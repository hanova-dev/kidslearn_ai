import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

/// How one progress step looks on the Story generating screen.
enum StepLook { waiting, active, done, failed }

/// One row like "Writing the story" with a circle, spinner or tick (design p8).
class ProgressStep extends StatelessWidget {
  const ProgressStep({super.key, required this.label, required this.look});

  final String label;
  final StepLook look;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    // ── Icon for each look ──
    Widget icon;
    switch (look) {
      case StepLook.waiting:
        icon = Icon(Icons.circle_outlined, color: colors.border);
      case StepLook.active:
        icon = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colors.primary,
          ),
        );
      case StepLook.done:
        icon = Icon(Icons.check_circle, color: colors.leaf);
      case StepLook.failed:
        icon = Icon(Icons.error_outline, color: colors.coralSoft);
    }

    // ── Row ──
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 24, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: look == StepLook.waiting ? colors.inkMuted : colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
