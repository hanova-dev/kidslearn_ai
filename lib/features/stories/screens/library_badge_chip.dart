import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../controllers/library_item.dart';

/// The small status label on a library card: colour + icon + word (SRS 10, decision 023).
class LibraryBadgeChip extends StatelessWidget {
  const LibraryBadgeChip({super.key, required this.badge});

  final LibraryBadge badge;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // ── Colour, icon and word for each badge ──
    Color color;
    IconData icon;
    String label;
    switch (badge) {
      case LibraryBadge.writing:
        color = colors.sky;
        icon = Icons.edit_note;
        label = 'Writing…';
      case LibraryBadge.drawing:
        color = colors.amber;
        icon = Icons.brush;
        label = 'Drawing…';
      case LibraryBadge.needsCheck:
        color = colors.sunshine;
        icon = Icons.visibility_outlined;
        label = 'Needs check';
      case LibraryBadge.approved:
        color = colors.leaf;
        icon = Icons.check_circle;
        label = 'Approved';
      case LibraryBadge.stopped:
        color = colors.coralSoft;
        icon = Icons.pause_circle_outline;
        label = 'Stopped';
    }

    // ── Chip ──
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
