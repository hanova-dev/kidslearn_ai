import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app/app_config.dart';
import '../core/errors/story_generation_failure.dart';
import '../data/models/narrative_result.dart';
import '../data/models/story_prompt.dart';
import 'story_generation_service.dart';
import 'story_prompt_builder.dart';

/// [StoryGenerationService] that calls Groq's gpt-oss-120b with strict JSON (decision 013).
class GroqStoryGenerator implements StoryGenerationService {
  GroqStoryGenerator({
    required this.apiKey,
    required this.modelId,
    http.Client? client,
    this.retryDelay = const Duration(seconds: 1),
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String modelId;
  final http.Client _client;

  /// Wait before retry 1; retry 2 waits twice as long (NFR-REL-02).
  final Duration retryDelay;

  // ── JSON shape the model must return ──
  /// Strict mode fills every required field, so naming page_1 … page_12 forces exactly 12 pages (decision 032).
  static Map<String, dynamic> get storySchema {
    const pageSchema = {
      'type': 'object',
      'properties': {
        'text': {'type': 'string'},
        'image_prompt': {'type': 'string'},
      },
      'required': ['text', 'image_prompt'],
      'additionalProperties': false,
    };
    final pages = <String, dynamic>{};
    final pageNames = <String>[];
    for (var number = 1; number <= AppConfig.scenesPerStory; number++) {
      pages['page_$number'] = pageSchema;
      pageNames.add('page_$number');
    }
    return {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
        'moral_value': {'type': 'string'},
        'character_sheet': {'type': 'string'},
        'pages': {
          'type': 'object',
          'properties': pages,
          'required': pageNames,
          'additionalProperties': false,
        },
      },
      'required': ['title', 'moral_value', 'character_sheet', 'pages'],
      'additionalProperties': false,
    };
  }

  @override
  Future<NarrativeResult> generateNarrative(StoryPrompt prompt) async {
    if (apiKey.isEmpty) {
      throw const StoryGenerationFailure(
        'Story writing is not set up on this phone yet.',
      );
    }

    // ── Build request body ──
    final body = jsonEncode({
      'model': modelId,
      'reasoning_effort': 'medium',
      'max_completion_tokens': AppConfig.storyMaxTokens,
      'messages': [
        {'role': 'system', 'content': StoryPromptBuilder.systemPrompt},
        {'role': 'user', 'content': StoryPromptBuilder.userMessage(prompt)},
      ],
      'response_format': {
        'type': 'json_schema',
        'json_schema': {'name': 'story', 'strict': true, 'schema': storySchema},
      },
    });

    // ── Call Groq API, retrying busy or failed calls ──
    var problem =
        'Something went wrong while writing the story. Please try again.';
    for (var attempt = 0; attempt <= AppConfig.maxRetries; attempt++) {
      if (attempt > 0) {
        await Future.delayed(retryDelay * attempt);
      }
      try {
        final response = await _client
            .post(
              Uri.parse(AppConfig.groqChatUrl),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(AppConfig.requestTimeout);
        if (response.statusCode == 200) {
          return _readStory(response.body);
        }
        problem = _messageForStatus(response.statusCode);
        if (!_isWorthRetrying(response.statusCode)) {
          break;
        }
      } on TimeoutException {
        problem = 'The story helper took too long. Please try again.';
      } on http.ClientException {
        problem = 'No internet. Check your connection and try again.';
      }
    }
    throw StoryGenerationFailure(problem);
  }

  // ── Read the story from the answer ──
  NarrativeResult _readStory(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final message = decoded['choices'][0]['message'] as Map<String, dynamic>;
      final story = jsonDecode(message['content'] as String);
      final result = NarrativeResult.fromMap(story as Map<String, dynamic>);
      if (result.scenes.length != AppConfig.scenesPerStory) {
        throw const FormatException('Wrong number of pages');
      }
      return result;
    } on FormatException {
      throw const StoryGenerationFailure(
        'The story came back incomplete. Please try again.',
      );
    } on TypeError {
      throw const StoryGenerationFailure(
        'The story came back incomplete. Please try again.',
      );
    }
  }

  // ── HTTP status to plain English ──
  String _messageForStatus(int statusCode) {
    if (statusCode == 429) {
      return 'The story helper is busy. Please try again in a minute.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'The story helper key is not working. Please check the app setup.';
    }
    return 'Something went wrong while writing the story. Please try again.';
  }

  bool _isWorthRetrying(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }
}
