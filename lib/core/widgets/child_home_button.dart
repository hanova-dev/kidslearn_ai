import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_colors.dart';
import '../../app/router.dart';
import '../constants/app_sizes.dart';

/// The round yellow Home button at the bottom centre of child screens (SRS 10.9).
class ChildHomeButton extends StatelessWidget {
  const ChildHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: AppSizes.listenerTouchTarget,
      height: AppSizes.listenerTouchTarget,
      child: FloatingActionButton(
        heroTag: 'home',
        backgroundColor: colors.sunshine,
        foregroundColor: AppColors.day.ink,
        tooltip: 'Home',
        shape: const CircleBorder(),
        onPressed: () => context.go(AppRoutes.whoIsReading),
        child: const Icon(Icons.home_outlined, size: 30),
      ),
    );
  }
}
