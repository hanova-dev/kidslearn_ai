import 'dart:io';

import 'package:kidslearn_ai/data/local/image_file_store.dart';
import 'package:kidslearn_ai/data/models/scene_image.dart';

/// [ImageFileStore] for tests: remembers paths but writes nothing to disk.
class FakeImageFileStore implements ImageFileStore {
  final List<String> savedPaths = [];
  final List<String> deletedPaths = [];

  @override
  Directory? get folder => null;

  @override
  Future<String> save(String sceneId, SceneImage image) async {
    final path = '/fake/story_images/$sceneId.${image.fileExtension}';
    savedPaths.add(path);
    return path;
  }

  @override
  Future<void> delete(String path) async {
    deletedPaths.add(path);
  }
}
