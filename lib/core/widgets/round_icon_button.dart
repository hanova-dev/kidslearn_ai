import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../constants/app_sizes.dart';

/// A round 64 dp icon button for child screens, e.g. Back or Read aloud (SRS 10.7).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: AppSizes.listenerTouchTarget,
      height: AppSizes.listenerTouchTarget,
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.border, width: 2),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
      ),
    );
  }
}
