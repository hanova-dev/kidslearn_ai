import 'dart:typed_data';

/// One drawn picture for a scene, before it is saved as a file (FR-ILLUS-02).
class SceneImage {
  const SceneImage({
    required this.bytes,
    required this.source,
    required this.fileExtension,
  });

  final Uint8List bytes;

  /// 'FLUX' or 'PLACEHOLDER', saved in scenes.image_source (FR-ILLUS-06).
  final String source;

  /// 'jpg' for FLUX, 'png' for the placeholder.
  final String fileExtension;
}
