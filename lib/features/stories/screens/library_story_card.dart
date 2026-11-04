import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/scenery_background.dart';
import '../controllers/library_item.dart';
import 'library_badge_chip.dart';

/// One story in the Story library grid: cover, title, child, language and badge (design p9).
class LibraryStoryCard extends StatelessWidget {
  const LibraryStoryCard({super.key, required this.item, required this.onTap});

  final LibraryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final story = item.story;
    final path = item.coverPath;
    const scenery = SceneryBackground(child: SizedBox());
    final title = story.title.isEmpty ? 'New story' : story.title;

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cover picture (first drawn scene, or scenery) ──
            SizedBox(
              height: 100,
              child: path == null
                  ? scenery
                  : Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => scenery,
                    ),
            ),

            // ── Title, child · language, badge ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${item.childName} · ${story.language.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LibraryBadgeChip(badge: item.badge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
