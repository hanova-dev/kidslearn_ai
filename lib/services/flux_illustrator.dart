import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app/app_config.dart';
import '../core/errors/illustration_failure.dart';
import '../data/models/scene_image.dart';
import 'illustration_service.dart';

/// [IllustrationService] that calls FLUX.1 schnell on Cloudflare Workers AI (decision 012).
class FluxIllustrator implements IllustrationService {
  FluxIllustrator({
    required this.accountId,
    required this.apiToken,
    http.Client? client,
    this.retryDelay = const Duration(seconds: 1),
  }) : _client = client ?? http.Client();

  final String accountId;
  final String apiToken;
  final http.Client _client;

  /// Wait before retry 1; retry 2 waits twice as long (FR-ILLUS-04).
  final Duration retryDelay;

  // ── Same style text for every scene (FR-ILLUS-01) ──
  static const String styleText =
      "Children's picture-book illustration, soft warm colours, "
      'simple rounded shapes, gentle and friendly. '
      'A wordless picture: no writing, letters, titles, labels or signatures.';

  /// The API accepts at most this many prompt characters.
  static const int maxPromptLength = 2048;

  // ── Build the full prompt ──
  /// Style text, then the character sheet, then the scene, cut to [maxPromptLength].
  static String buildPrompt(String scenePrompt, String characterSheet) {
    final prompt = '$styleText Character: $characterSheet Scene: $scenePrompt';
    if (prompt.length <= maxPromptLength) {
      return prompt;
    }
    return prompt.substring(0, maxPromptLength);
  }

  @override
  Future<SceneImage> renderScene(
    String scenePrompt,
    String characterSheet,
    int seed,
  ) async {
    if (accountId.isEmpty || apiToken.isEmpty) {
      throw const IllustrationFailure('Pictures are not set up on this phone.');
    }
    final url =
        '${AppConfig.cloudflareAccountsUrl}/$accountId/ai/run/'
        '${AppConfig.imageModelId}';
    final body = jsonEncode({
      'prompt': buildPrompt(scenePrompt, characterSheet),
      'steps': AppConfig.imageSteps,
    });

    // ── Call Cloudflare API, retrying failed calls ──
    var problem = 'The picture could not be drawn.';
    for (var attempt = 0; attempt <= AppConfig.maxRetries; attempt++) {
      if (attempt > 0) {
        await Future.delayed(retryDelay * attempt);
      }
      try {
        final response = await _client
            .post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $apiToken',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(AppConfig.requestTimeout);
        if (response.statusCode == 200) {
          return _readImage(response.body);
        }
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const IllustrationFailure('The picture key is not working.');
        }
        problem = 'The picture helper is busy.';
      } on TimeoutException {
        problem = 'The picture helper took too long.';
      } on http.ClientException {
        problem = 'No internet for pictures.';
      }
    }
    throw IllustrationFailure(problem);
  }

  // ── Read base64 image ──
  SceneImage _readImage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final result = decoded['result'] as Map<String, dynamic>;
      return SceneImage(
        bytes: base64Decode(result['image'] as String),
        source: 'FLUX',
        fileExtension: 'jpg',
      );
    } on FormatException {
      throw const IllustrationFailure('The picture came back broken.');
    } on TypeError {
      throw const IllustrationFailure('The picture came back broken.');
    }
  }
}
