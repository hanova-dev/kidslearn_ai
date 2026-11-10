import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

/// A rounded line under the sentence: icon, message and the stars earned, e.g. "So close! Listen: shared +2".
class ReaderBanner extends StatelessWidget {
  const ReaderBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
    this.stars = 0,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String text;

  /// Shown as "+3" with a star; 0 hides it.
  final int stars;

  /// Says the message again with the phone's voice.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: colors.ink);
    return Material(
      color: Color.lerp(colors.surface, color, 0.25),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: textStyle)),

                // ── Stars for this sentence ──
                if (stars > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.star_rounded, color: colors.sunshine, size: 28),
                  Text('+$stars', style: textStyle),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
