import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/story_status.dart';
import '../controllers/story_preview.dart';
import '../controllers/story_preview_controller.dart';
import 'preview_actions.dart';
import 'preview_scene_card.dart';

/// Lets the parent read a new story before the child sees it (FR-STORY-07).
class StoryPreviewScreen extends ConsumerWidget {
  const StoryPreviewScreen({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(storyPreviewControllerProvider(storyId));
    return Scaffold(
      body: SafeArea(
        child: preview.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const _StoryMissing(),
          data: (data) => Column(
            children: [
              Expanded(child: _SceneList(preview: data)),
              PreviewActions(preview: data),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneList extends StatelessWidget {
  const _SceneList({required this.preview});

  final StoryPreview preview;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final story = preview.story;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Back button and title ──
        Row(
          children: [
            IconButton.outlined(
              tooltip: 'Back',
              onPressed: () => context.go(AppRoutes.storyLibrary),
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                story.title.isEmpty ? 'New story' : story.title,
                style: textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          story.moralValue.isEmpty
              ? 'For ${preview.child.name}'
              : 'For ${preview.child.name} · Lesson: ${story.moralValue}',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
        ),
        if (story.status == StoryStatus.failed) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.pause_circle_outline, color: colors.coralSoft),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This story stopped before it was finished. '
                  'Tap "Make a new version" to try again.',
                ),
              ),
            ],
          ),
        ],
        if (story.approved) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: colors.leaf),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Approved: ${preview.child.name} can read it.'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // ── Scenes ──
        for (final scene in preview.scenes) ...[
          PreviewSceneCard(scene: scene),
          const SizedBox(height: 16),
        ],

        // ── Draw simple pictures again (FR-ILLUS-06) ──
        if (preview.placeholderCount > 0) _RedrawBox(preview: preview),
      ],
    );
  }
}

class _RedrawBox extends ConsumerWidget {
  const _RedrawBox({required this.preview});

  final StoryPreview preview;

  // ── Redraw and tell the parent how it went ──
  Future<void> _redraw(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(
      storyPreviewControllerProvider(preview.story.id).notifier,
    );
    String message;
    try {
      final stillSimple = await controller.redrawPictures();
      message = stillSimple == 0
          ? 'All pictures are drawn now.'
          : 'Still simple: $stillSimple of ${preview.scenes.length}. '
                'Please try again later.';
    } catch (error) {
      message = 'Could not draw the pictures. Please try again later.';
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Simple pictures: ${preview.placeholderCount} of '
            '${preview.scenes.length}. FLUX can try to draw them again.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: preview.isRedrawing ? null : () => _redraw(context, ref),
            icon: const Icon(Icons.brush_outlined),
            label: Text(
              preview.isRedrawing
                  ? 'Drawing pictures again…'
                  : 'Draw pictures again',
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryMissing extends StatelessWidget {
  const _StoryMissing();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'This story could not be opened. It may have been deleted.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.storyLibrary),
            child: const Text('Back to library'),
          ),
        ],
      ),
    );
  }
}
