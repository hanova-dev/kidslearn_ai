import 'dart:convert';
import 'dart:io';

import 'dev_env.dart';

// ── Settings ──
const String modelId = 'openai/gpt-oss-120b';
const String endpoint = 'https://api.groq.com/openai/v1/chat/completions';

const String systemPrompt =
    'You write gentle, age-appropriate picture-book stories for children '
    'aged 2 to 7. Never include violence, fear, danger, sadness that is not '
    'resolved, or adult themes. Use short, simple sentences of 5 to 12 words. '
    'Write exactly 6 scenes, one sentence per scene. The main character must '
    'be the buddy named in the request. The character_sheet is a fixed visual '
    'description of the main character (animal, colours, clothes). Each '
    'image_prompt describes only what is visible in that scene, with no text '
    'or letters in the picture.';

const String parentRequest =
    'Buddy name: Mango. Lesson: Mango does not want to share his toys with '
    'his baby sister.';

/// The JSON shape the model must return (strict mode needs every field).
final Map<String, dynamic> storySchema = {
  'type': 'object',
  'properties': {
    'title': {'type': 'string'},
    'moral_value': {'type': 'string'},
    'character_sheet': {'type': 'string'},
    'scenes': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'text': {'type': 'string'},
          'image_prompt': {'type': 'string'},
        },
        'required': ['text', 'image_prompt'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['title', 'moral_value', 'character_sheet', 'scenes'],
  'additionalProperties': false,
};

/// Spike test: asks Groq gpt-oss-120b for one short children's story as JSON.
Future<void> main() async {
  final apiKey = readDevKey('GROQ_API_KEY');

  // ── Build request body ──
  final body = {
    'model': modelId,
    'reasoning_effort': 'low',
    'messages': [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': parentRequest},
    ],
    'response_format': {
      'type': 'json_schema',
      'json_schema': {'name': 'story', 'strict': true, 'schema': storySchema},
    },
  };

  // ── Call Groq API ──
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(endpoint));
  request.headers.set('Authorization', 'Bearer $apiKey');
  request.headers.contentType = ContentType.json;
  request.add(utf8.encode(jsonEncode(body)));
  final response = await request.close();
  final responseText = await response.transform(utf8.decoder).join();
  client.close();
  stopwatch.stop();

  // ── Show result ──
  print(
    'HTTP status: ${response.statusCode} '
    '(${stopwatch.elapsedMilliseconds} ms)',
  );
  print(
    'Requests left today: '
    '${response.headers.value('x-ratelimit-remaining-requests')}',
  );
  print(
    'Tokens left this minute: '
    '${response.headers.value('x-ratelimit-remaining-tokens')}',
  );
  if (response.statusCode != 200) {
    print(responseText);
    exit(1);
  }

  final decoded = jsonDecode(responseText) as Map<String, dynamic>;
  final message = decoded['choices'][0]['message'] as Map<String, dynamic>;
  final story =
      jsonDecode(message['content'] as String) as Map<String, dynamic>;
  print('Tokens used: ${decoded['usage']}');
  print('');
  print('Title: ${story['title']}');
  print('Moral: ${story['moral_value']}');
  print('Character: ${story['character_sheet']}');
  final scenes = story['scenes'] as List<dynamic>;
  for (var i = 0; i < scenes.length; i++) {
    print('Scene ${i + 1}: ${scenes[i]['text']}');
  }

  // ── Save story to file ──
  final outputFile = File('tool/output/story.json');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(story),
  );
  print('');
  print('Saved: ${outputFile.path}');
}
