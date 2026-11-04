import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../controllers/story_creation.dart';
import '../controllers/story_creation_controller.dart';
import 'progress_step.dart';
import 'scene_thumbnails.dart';

/// Shows the story being written and drawn, then ready or failed (design p8, FR-STORY-04).
class StoryGeneratingScreen extends ConsumerWidget {
  const StoryGeneratingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final creation = ref.watch(storyCreationControllerProvider);
    final total = creation.scenes.length;

    // ── Pick title, subtitle and step looks for the current step ──
    var title = 'Lumi is drawing your story…';
    var subtitle = 'Usually under a minute. You can leave this screen.';
    var writingLook = StepLook.done;
    var drawingLook = StepLook.waiting;
    var drawingLabel = 'Drawing the pictures';
    switch (creation.step) {
      case CreationStep.idle:
        title = 'No story is being made';
        subtitle = 'Start a new story from the home screen.';
        writingLook = StepLook.waiting;
      case CreationStep.writing:
        writingLook = StepLook.active;
      case CreationStep.drawing:
        drawingLook = StepLook.active;
        final next = creation.drawnCount < total
            ? creation.drawnCount + 1
            : total;
        drawingLabel = 'Drawing scene $next of $total';
      case CreationStep.ready:
        title = 'Your story is ready!';
        subtitle = 'Read it first, then approve it for your child.';
        drawingLook = StepLook.done;
        drawingLabel = 'All $total pictures drawn';
      case CreationStep.failed:
        title = 'Lumi got stuck';
        subtitle = creation.message;
        writingLook = StepLook.failed;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Lumi and title ──
                      const SizedBox(height: 24),
                      const Center(child: LumiMascot(size: 110)),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(subtitle, textAlign: TextAlign.center),
                      const SizedBox(height: 24),

                      // ── Progress steps and drawn scenes ──
                      _StepsCard(
                        writingLook: writingLook,
                        drawingLook: drawingLook,
                        drawingLabel: drawingLabel,
                      ),
                      const SizedBox(height: 16),
                      SceneThumbnails(scenes: creation.scenes),
                      if (creation.step == CreationStep.ready) ...[
                        const SizedBox(height: 16),
                        _ReadyStoryCard(creation: creation),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Actions ──
              if (creation.step == CreationStep.ready)
                FilledButton.icon(
                  onPressed: () =>
                      context.go(AppRoutes.storyPreviewOf(creation.story!.id)),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Preview story'),
                ),
              if (creation.step == CreationStep.failed)
                FilledButton.icon(
                  onPressed: () => ref
                      .read(storyCreationControllerProvider.notifier)
                      .retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              TextButton(
                onPressed: () => context.go(AppRoutes.parentHome),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({
    required this.writingLook,
    required this.drawingLook,
    required this.drawingLabel,
  });

  final StepLook writingLook;
  final StepLook drawingLook;
  final String drawingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ProgressStep(label: 'Writing the story', look: writingLook),
          ProgressStep(label: drawingLabel, look: drawingLook),
        ],
      ),
    );
  }
}

class _ReadyStoryCard extends StatelessWidget {
  const _ReadyStoryCard({required this.creation});

  final StoryCreation creation;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final story = creation.story!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.leaf),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(story.title, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Lesson: ${story.moralValue}', style: textTheme.bodyMedium),
          if (creation.placeholderCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Simple pictures: ${creation.placeholderCount} of '
              '${creation.scenes.length}. You can draw them again in the '
              'preview.',
              style: textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
