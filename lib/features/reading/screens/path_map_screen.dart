import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';
import '../../../core/widgets/scenery_background.dart';
import '../../children/controllers/active_child.dart';

/// Placeholder for the child's story path (design p15); stories come in Week 3.
class PathMapScreen extends ConsumerWidget {
  const PathMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final child = ref.watch(activeChildProvider);

    return Scaffold(
      body: SceneryBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // ── Greeting ──
              if (child != null) ...[
                BuddyFace(buddy: Buddies.byId(child.buddyId), size: 96),
                const SizedBox(height: 16),
                Text('Hi, ${child.name}!', style: textTheme.displaySmall),
              ],
              const SizedBox(height: 8),
              Text(
                'Your stories will appear here soon.',
                style: textTheme.bodyLarge,
              ),
              const Spacer(),

              // ── Home button (fixed bottom-centre, SRS 10.9) ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: AppSizes.listenerTouchTarget,
                  height: AppSizes.listenerTouchTarget,
                  child: FloatingActionButton(
                    heroTag: 'home',
                    backgroundColor: colors.sunshine,
                    foregroundColor: AppColors.day.ink,
                    tooltip: 'Home',
                    onPressed: () => context.go(AppRoutes.whoIsReading),
                    child: const Icon(Icons.home_outlined, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
