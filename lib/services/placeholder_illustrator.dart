import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/errors/illustration_failure.dart';
import '../core/widgets/scenery_background.dart';
import '../data/models/scene_image.dart';
import 'illustration_service.dart';

/// [IllustrationService] that draws a simple sky-and-hills picture, no network (FR-ILLUS-06).
class PlaceholderIllustrator implements IllustrationService {
  /// Width and height of the placeholder picture in pixels.
  static const int size = 512;

  @override
  Future<SceneImage> renderScene(
    String scenePrompt,
    String characterSheet,
    int seed,
  ) async {
    // ── Paint the scenery on a canvas ──
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final area = Size(size.toDouble(), size.toDouble());
    SceneryPainter(isNight: false).paint(canvas, area);
    final picture = recorder.endRecording();

    // ── Turn the canvas into PNG bytes ──
    final image = await picture.toImage(size, size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    if (data == null) {
      throw const IllustrationFailure('The placeholder could not be drawn.');
    }
    return SceneImage(
      bytes: data.buffer.asUint8List(),
      source: 'PLACEHOLDER',
      fileExtension: 'png',
    );
  }
}
