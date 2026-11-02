import '../data/models/scene_image.dart';

/// Draws one scene picture; screens and controllers only know this interface (SRS 4.3).
abstract class IllustrationService {
  /// Returns the picture, or throws an IllustrationFailure (FR-ILLUS-01).
  Future<SceneImage> renderScene(
    String scenePrompt,
    String characterSheet,
    int seed,
  );
}
