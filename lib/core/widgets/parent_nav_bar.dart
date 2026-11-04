import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_colors.dart';
import '../../app/router.dart';

/// Bottom bar of the parent area with Home and Library (designs p6, p9; decision 023).
class ParentNavBar extends StatelessWidget {
  const ParentNavBar({super.key, required this.currentIndex});

  /// 0 = Home, 1 = Library.
  final int currentIndex;

  // ── Go to the tapped tab ──
  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }
    if (index == 0) {
      context.go(AppRoutes.parentHome);
    } else {
      context.go(AppRoutes.storyLibrary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      backgroundColor: colors.surface,
      indicatorColor: colors.primary.withValues(alpha: 0.18),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: colors.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book, color: colors.primary),
          label: 'Library',
        ),
      ],
    );
  }
}
