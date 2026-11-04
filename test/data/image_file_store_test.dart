import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/local/image_file_store.dart';
import 'package:kidslearn_ai/data/models/scene_image.dart';

void main() {
  late Directory folder;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('kidslearn_images_');
  });
  tearDown(() => folder.delete(recursive: true));

  // ── Picture saved as a file (FR-ILLUS-02) ──
  test('saves the bytes as <sceneId>.<ext> in story_images', () async {
    final store = ImageFileStore(folder: folder);
    final image = SceneImage(
      bytes: Uint8List.fromList([7, 8, 9]),
      source: 'FLUX',
      fileExtension: 'jpg',
    );

    final path = await store.save('s1-scene-1', image);

    expect(path, endsWith('story_images/s1-scene-1.jpg'));
    expect(await File(path).readAsBytes(), [7, 8, 9]);
  });

  // ── Old pictures removed ──
  test('delete removes the file, and a missing file is fine', () async {
    final store = ImageFileStore(folder: folder);
    final image = SceneImage(
      bytes: Uint8List.fromList([1]),
      source: 'PLACEHOLDER',
      fileExtension: 'png',
    );
    final path = await store.save('s1-scene-1', image);

    await store.delete(path);
    await store.delete(path);

    expect(await File(path).exists(), isFalse);
  });
}
