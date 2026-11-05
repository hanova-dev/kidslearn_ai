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
import '../controllers/path_map_provider.dart';
import '../controllers/path_node.dart';
import 'path_map_view.dart';
import 'path_top_bar.dart';

/// The child's story path: approved stories as circles, one at a time (design p15, FR-MODE-01, D1, D6).
class PathMapScreen extends ConsumerWidget {
  const PathMapScreen({super.key});

  // ── Open a story (the story viewer comes in the next task) ──
  void _openStory(BuildContext context, PathNode node) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (!node.canOpen) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Finish the glowing story first!')),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('"${node.story.title}" opens soon.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final child = ref.watch(activeChildProvider);
    final path = ref.watch(pathMapProvider);
    var buddy = Buddies.mango;
    if (child != null) {
      buddy = Buddies.byId(child.buddyId);
    }

    return Scaffold(
      body: SceneryBackground(
        child: SafeArea(
          child: Column(
            children: [
              PathTopBar(
                stars: child?.starBalance ?? 0,
                onBack: () => context.go(AppRoutes.whoIsReading),
              ),

              // ── Path, or a message ──
              Expanded(
                child: path.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _PathMessage(
                    buddy: buddy,
                    title: 'Could not load your stories.',
                    onRetry: () => ref.invalidate(pathMapProvider),
                  ),
                  data: (nodes) {
                    if (nodes.isEmpty) {
                      return _PathMessage(
                        buddy: buddy,
                        title: 'No stories yet.',
                        subtitle: 'Ask a grown-up to make one!',
                      );
                    }
                    return PathMapView(
                      nodes: nodes,
                      buddy: buddy,
                      onTapNode: (node) => _openStory(context, node),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Home button (fixed bottom-centre, SRS 10.9) ──
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
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
      ),
    );
  }
}

/// Buddy with a short message, for an empty path or a loading error.
class _PathMessage extends StatelessWidget {
  const _PathMessage({
    required this.buddy,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  final Buddy buddy;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BuddyFace(buddy: buddy, size: 96),
            const SizedBox(height: 16),
            Text(title, style: textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: textTheme.bodyLarge),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
