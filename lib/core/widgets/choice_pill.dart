import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_sizes.dart';

/// A round, tappable choice like "Sharing" or "English" (designs p4, p7).
///
/// A null [onTap] shows the pill greyed out and not tappable.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.fontFamily = AppFonts.nunito,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isUrdu = fontFamily == AppFonts.notoNastaliqUrdu;

    // ── Colours for selected, normal and disabled ──
    var textColor = colors.ink;
    if (isSelected) {
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (onTap == null) {
      textColor = colors.inkMuted;
    }

    // ── Pill ──
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      child: Material(
        color: isSelected ? colors.primary : colors.surface,
        shape: StadiumBorder(
          side: BorderSide(color: isSelected ? colors.primary : colors.border),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.parentTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w700,
                    height: isUrdu ? 1.0 : null,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
