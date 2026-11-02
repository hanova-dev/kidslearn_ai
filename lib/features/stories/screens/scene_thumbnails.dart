import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../data/models/scene.dart';

/// A row of small scene pictures that fills in as scenes are drawn (design p8, FR-ILLUS-03).
class SceneThumbnails extends StatelessWidget {
  const SceneThumbnails({super.key, required this.scenes});

  final List<Scene> scenes;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final path = scenes[index].imagePath;

          // ── Empty box until the scene is drawn ──
          Widget picture = Container(color: colors.surface);
          if (path != null) {
            picture = Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: colors.surface),
            );
          }

          // ── Rounded frame ──
          return Container(
            width: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: picture,
          );
        },
      ),
    );
  }
}
