import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../../../data/models/story.dart';
import '../controllers/story_creation_controller.dart';
import 'progress_step.dart';

/// Shows the story being written, then ready or failed (design p8, FR-STORY-04).
class StoryGeneratingScreen extends ConsumerWidget {
  const StoryGeneratingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final creation = ref.watch(storyCreationControllerProvider);

    // ── Pick title, subtitle and step look for the current status ──
    var title = 'Lumi is writing your story…';
    var subtitle = 'Usually under a minute. You can leave this screen.';
    var writingStep = StepLook.active;
    var isFailed = false;
    Story? readyStory;
    if (creation.isLoading) {
      writingStep = StepLook.active;
    } else if (creation.hasError) {
      isFailed = true;
      title = 'Lumi got stuck';
      subtitle = creation.error.toString();
      writingStep = StepLook.failed;
    } else if (creation.value != null) {
      readyStory = creation.value;
      title = 'Your story is ready!';
      subtitle = 'You can preview and approve it soon.';
      writingStep = StepLook.done;
    } else {
      title = 'No story is being written';
      subtitle = 'Start a new story from the home screen.';
      writingStep = StepLook.waiting;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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

              // ── Progress steps ──
              _StepsCard(writingStep: writingStep),
              if (readyStory != null) ...[
                const SizedBox(height: 16),
                _ReadyStoryCard(story: readyStory),
              ],
              const Spacer(),

              // ── Actions ──
              if (isFailed)
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
  const _StepsCard({required this.writingStep});

  final StepLook writingStep;

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
          ProgressStep(label: 'Writing the story', look: writingStep),
          const ProgressStep(
            label: 'Drawing the pictures',
            look: StepLook.waiting,
          ),
        ],
      ),
    );
  }
}

class _ReadyStoryCard extends StatelessWidget {
  const _ReadyStoryCard({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
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
        ],
      ),
    );
  }
}
