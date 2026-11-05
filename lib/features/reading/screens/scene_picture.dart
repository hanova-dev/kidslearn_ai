import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/widgets/scenery_background.dart';

/// The scene's picture file, or the scenery hills if there is none (FR-ILLUS-06).
class ScenePicture extends StatelessWidget {
  const ScenePicture({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    const scenery = SceneryBackground(child: SizedBox());
    final file = path;
    if (file == null) {
      return scenery;
    }
    return Image.file(
      File(file),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => scenery,
    );
  }
}
