import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/scene_image.dart';

/// Saves scene pictures as files in the app's private folder (FR-ILLUS-02).
class ImageFileStore {
  /// [folder] is for tests; on the phone the app documents folder is used.
  ImageFileStore({this.folder});

  final Directory? folder;

  /// Writes [image] as `<sceneId>.<ext>` in `story_images/` and returns the file path.
  Future<String> save(String sceneId, SceneImage image) async {
    // ── Find the images folder ──
    var base = folder;
    base ??= await getApplicationDocumentsDirectory();
    final imagesFolder = Directory('${base.path}/story_images');
    await imagesFolder.create(recursive: true);

    // ── Write the file ──
    final file = File('${imagesFolder.path}/$sceneId.${image.fileExtension}');
    await file.writeAsBytes(image.bytes, flush: true);
    return file.path;
  }
}
