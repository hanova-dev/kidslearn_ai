import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/models/story_status.dart';
import '../controllers/story_creation_controller.dart';
import '../controllers/story_preview.dart';
import '../controllers/story_preview_controller.dart';

/// Approve, Make a new version and Delete, at the bottom of the preview (FR-STORY-06, FR-STORY-07).
class PreviewActions extends ConsumerWidget {
  const PreviewActions({super.key, required this.preview});

  final StoryPreview preview;

  // ── Approve ──
  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(storyPreviewControllerProvider(preview.story.id).notifier)
          .approve();
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Approved. ${preview.child.name} can read it.')),
    );
    if (context.mounted) {
      context.go(AppRoutes.storyLibrary);
    }
  }

  // ── Make a new version from the same prompt (FR-STORY-06) ──
  Future<void> _makeNewVersion(BuildContext context, WidgetRef ref) async {
    final yes = await showConfirmDialog(
      context,
      title: 'Make a new version?',
      message:
          'The text and pictures will be replaced. '
          'Your story idea stays the same.',
      yesLabel: 'Make new version',
    );
    if (!yes || !context.mounted) {
      return;
    }
    unawaited(
      ref
          .read(storyCreationControllerProvider.notifier)
          .regenerate(preview.story, preview.child),
    );
    context.go(AppRoutes.storyGenerating);
  }

  // ── Delete ──
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final yes = await showConfirmDialog(
      context,
      title: 'Delete this story?',
      message: 'The story and its pictures will be removed from this phone.',
      yesLabel: 'Delete',
    );
    if (!yes || !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(storyPreviewControllerProvider(preview.story.id).notifier)
          .delete();
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete the story. Please try again.'),
        ),
      );
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Story deleted.')));
    if (context.mounted) {
      context.go(AppRoutes.storyLibrary);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final busy = preview.isRedrawing;
    final canApprove =
        preview.story.status == StoryStatus.ready && !preview.story.approved;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canApprove) ...[
            FilledButton.icon(
              onPressed: busy ? null : () => _approve(context, ref),
              icon: const Icon(Icons.check),
              label: Text('Approve for ${preview.child.name}'),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: busy ? null : () => _makeNewVersion(context, ref),
            icon: const Icon(Icons.refresh),
            label: const Text('Make a new version'),
          ),
          TextButton(
            onPressed: busy ? null : () => _delete(context, ref),
            child: const Text('Delete story'),
          ),
        ],
      ),
    );
  }
}
