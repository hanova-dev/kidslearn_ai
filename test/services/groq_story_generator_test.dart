import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kidslearn_ai/core/errors/story_generation_failure.dart';
import 'package:kidslearn_ai/data/models/story_prompt.dart';
import 'package:kidslearn_ai/services/groq_story_generator.dart';
import 'package:kidslearn_ai/services/story_prompt_builder.dart';

const prompt = StoryPrompt(
  behaviour: 'Mango does not want to share his toys',
  value: 'Sharing',
  language: 'en',
  buddyName: 'Mango',
  buddyAnimal: 'fox',
);

/// A Groq-style answer whose message content is the story JSON as text.
String groqAnswer(Map<String, dynamic> story) {
  return jsonEncode({
    'choices': [
      {
        'message': {'role': 'assistant', 'content': jsonEncode(story)},
      },
    ],
  });
}

/// A story answer with [pageCount] pages, as page_1, page_2, …
Map<String, dynamic> storyWithPages(int pageCount) {
  return {
    'title': 'Mango Learns to Share',
    'moral_value': 'Sharing',
    'character_sheet': 'The fox: small, orange fur, green scarf.',
    'pages': {
      for (var i = 1; i <= pageCount; i++)
        'page_$i': {'text': 'Page $i sentence.', 'image_prompt': 'Picture $i.'},
    },
  };
}

final twelvePageStory = storyWithPages(12);

GroqStoryGenerator makeGenerator(
  MockClient client, {
  String apiKey = 'test-key',
}) {
  return GroqStoryGenerator(
    apiKey: apiKey,
    modelId: 'openai/gpt-oss-120b',
    client: client,
    retryDelay: Duration.zero,
  );
}

void main() {
  // ── Correct answer ──
  test('reads a 12-page story from a correct answer', () async {
    final client = MockClient((request) async {
      return http.Response(groqAnswer(twelvePageStory), 200);
    });

    final story = await makeGenerator(client).generateNarrative(prompt);

    expect(story.title, 'Mango Learns to Share');
    expect(story.characterSheet, contains('The fox: small, orange fur'));
    expect(story.scenes.length, 12);
    expect(story.scenes.first.imagePrompt, 'Picture 1.');
    expect(story.scenes.last.text, 'Page 12 sentence.');
  });

  // ── Exactly 12 pages (decision 032) ──
  test('the schema makes all 12 pages required', () {
    final pages = GroqStoryGenerator.storySchema['properties']['pages'];

    expect(pages['required'], [for (var i = 1; i <= 12; i++) 'page_$i']);
    expect(pages['additionalProperties'], false);
  });

  test('a story with too few pages gives the incomplete message', () async {
    final client = MockClient((request) async {
      return http.Response(groqAnswer(storyWithPages(7)), 200);
    });

    await expectLater(
      makeGenerator(client).generateNarrative(prompt),
      throwsA(
        isA<StoryGenerationFailure>().having(
          (failure) => failure.message,
          'message',
          'The story came back incomplete. Please try again.',
        ),
      ),
    );
  });

  // ── What we send ──
  test(
    'sends the model, strict JSON schema, safety rules and the key',
    () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response(groqAnswer(twelvePageStory), 200);
      });

      await makeGenerator(client).generateNarrative(prompt);
      final body = jsonDecode(sent.body) as Map<String, dynamic>;

      expect(sent.headers['Authorization'], 'Bearer test-key');
      expect(body['model'], 'openai/gpt-oss-120b');
      expect(body['reasoning_effort'], 'medium');
      expect(body['max_completion_tokens'], 6000);
      expect(body['response_format']['json_schema']['strict'], isTrue);
      expect(body['messages'][0]['content'], StoryPromptBuilder.systemPrompt);
      expect(body['messages'][1]['content'], contains('Mango the fox'));
    },
  );

  // ── Busy: retried, then a friendly message ──
  test('429 is retried twice, then says the helper is busy', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"error":"rate limit"}', 429);
    });

    await expectLater(
      makeGenerator(client).generateNarrative(prompt),
      throwsA(
        isA<StoryGenerationFailure>().having(
          (failure) => failure.message,
          'message',
          'The story helper is busy. Please try again in a minute.',
        ),
      ),
    );
    expect(calls, 3);
  });

  // ── Bad key: not retried ──
  test('401 is not retried and explains the key problem', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"error":"invalid key"}', 401);
    });

    await expectLater(
      makeGenerator(client).generateNarrative(prompt),
      throwsA(isA<StoryGenerationFailure>()),
    );
    expect(calls, 1);
  });

  // ── No internet ──
  test('no connection gives the no-internet message', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Failed host lookup');
    });

    await expectLater(
      makeGenerator(client).generateNarrative(prompt),
      throwsA(
        isA<StoryGenerationFailure>().having(
          (failure) => failure.message,
          'message',
          'No internet. Check your connection and try again.',
        ),
      ),
    );
  });

  // ── Broken answer ──
  test('a broken story answer gives the incomplete message', () async {
    final client = MockClient((request) async {
      return http.Response(groqAnswer({'title': 'Half a story'}), 200);
    });

    await expectLater(
      makeGenerator(client).generateNarrative(prompt),
      throwsA(
        isA<StoryGenerationFailure>().having(
          (failure) => failure.message,
          'message',
          'The story came back incomplete. Please try again.',
        ),
      ),
    );
  });

  // ── Missing key: no call at all ──
  test('an empty key fails without calling Groq', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('', 200);
    });

    await expectLater(
      makeGenerator(client, apiKey: '').generateNarrative(prompt),
      throwsA(isA<StoryGenerationFailure>()),
    );
    expect(calls, 0);
  });
}
