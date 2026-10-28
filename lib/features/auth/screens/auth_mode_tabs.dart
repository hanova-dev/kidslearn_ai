import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// The "Log in | Sign up" switch at the top of the login form (design p3).
class AuthModeTabs extends StatelessWidget {
  const AuthModeTabs({
    super.key,
    required this.isSignUp,
    required this.onChanged,
  });

  final bool isSignUp;

  /// Called with true for "Sign up" and false for "Log in".
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(context, 'Log in', !isSignUp, () => onChanged(false)),
          _buildTab(context, 'Sign up', isSignUp, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final colors = AppColors.of(context);
    final isNight = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isNight ? colors.background : colors.surface;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppSizes.parentTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: selected ? colors.ink : colors.inkMuted),
          ),
        ),
      ),
    );
  }
}
