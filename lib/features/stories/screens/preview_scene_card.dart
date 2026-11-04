import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/scene.dart';

/// One scene on the Story preview screen: its picture and its sentence.
class PreviewSceneCard extends StatelessWidget {
  const PreviewSceneCard({super.key, required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final path = scene.imagePath;
    final emptyPicture = Container(
      color: colors.border,
      child: Icon(Icons.image_outlined, color: colors.inkMuted, size: 48),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Picture ──
          AspectRatio(
            aspectRatio: 1,
            child: path == null
                ? emptyPicture
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => emptyPicture,
                  ),
          ),

          // ── Scene number, sentence and picture source ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scene ${scene.sequenceNumber}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(scene.text, style: textTheme.titleMedium),
                if (scene.imageSource == 'PLACEHOLDER') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Simple picture for now',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
