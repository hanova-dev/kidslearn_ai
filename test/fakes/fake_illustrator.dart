import 'dart:typed_data';

import 'package:kidslearn_ai/core/errors/illustration_failure.dart';
import 'package:kidslearn_ai/data/models/scene_image.dart';
import 'package:kidslearn_ai/services/illustration_service.dart';

/// [IllustrationService] for tests: no network, can fail chosen scene prompts.
class FakeIllustrator implements IllustrationService {
  FakeIllustrator({this.source = 'FLUX', this.failPrompts = const {}});

  final String source;

  /// Scene prompts that throw, to test the placeholder fallback.
  final Set<String> failPrompts;

  final List<String> drawnPrompts = [];
  final List<String> drawnSheets = [];

  @override
  Future<SceneImage> renderScene(
    String scenePrompt,
    String characterSheet,
    int seed,
  ) async {
    if (failPrompts.contains(scenePrompt)) {
      throw const IllustrationFailure('The picture helper is busy.');
    }
    drawnPrompts.add(scenePrompt);
    drawnSheets.add(characterSheet);
    return SceneImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      source: source,
      fileExtension: source == 'FLUX' ? 'jpg' : 'png',
    );
  }
}
