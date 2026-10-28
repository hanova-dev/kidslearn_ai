import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/age_group.dart';

/// One tappable age-group card, e.g. "2–4 Little Listener" (design p4).
class AgeGroupCard extends StatelessWidget {
  const AgeGroupCard({
    super.key,
    required this.ageGroup,
    required this.isSelected,
    required this.onTap,
  });

  final AgeGroup ageGroup;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final icon = ageGroup == AgeGroup.listener
        ? Icons.volume_up_outlined
        : Icons.menu_book_outlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.10)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 8),
            Text(ageGroup.ageRange, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(ageGroup.title, style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              ageGroup.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
