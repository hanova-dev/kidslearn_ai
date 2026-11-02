import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kidslearn_ai/core/errors/illustration_failure.dart';
import 'package:kidslearn_ai/services/flux_illustrator.dart';

const sheet = 'Mango is a small orange fox with a green scarf.';

/// A Cloudflare-style answer with the picture as base64.
String cloudflareAnswer(List<int> bytes) {
  return jsonEncode({
    'result': {'image': base64Encode(bytes)},
    'success': true,
  });
}

FluxIllustrator makeIllustrator(MockClient client, {String token = 'token'}) {
  return FluxIllustrator(
    accountId: 'account-1',
    apiToken: token,
    client: client,
    retryDelay: Duration.zero,
  );
}

void main() {
  // ── Request shape (FR-ILLUS-01, decision 012) ──
  test('sends style + character sheet + scene, 4 steps, no seed', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(cloudflareAnswer([1, 2, 3]), 200);
    });

    final image = await makeIllustrator(client)
        .renderScene('Mango hugs a red ball.', sheet, 42);

    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(sent.url.path, contains('/accounts/account-1/ai/run/'));
    expect(sent.headers['Authorization'], 'Bearer token');
    expect(body['prompt'], startsWith(FluxIllustrator.styleText));
    expect(body['prompt'], contains(sheet));
    expect(body['prompt'], endsWith('Mango hugs a red ball.'));
    expect(body['steps'], 4);
    expect(body.containsKey('seed'), isFalse);
    expect(image.bytes, [1, 2, 3]);
    expect(image.source, 'FLUX');
    expect(image.fileExtension, 'jpg');
  });

  test('a very long prompt is cut to 2048 characters', () {
    final prompt = FluxIllustrator.buildPrompt('a' * 3000, sheet);

    expect(prompt.length, FluxIllustrator.maxPromptLength);
  });

  // ── Retries (FR-ILLUS-04) ──
  test('a busy answer is retried and then succeeds', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls < 3) {
        return http.Response('{"success":false}', 500);
      }
      return http.Response(cloudflareAnswer([9]), 200);
    });

    final image = await makeIllustrator(client).renderScene('x', sheet, 0);

    expect(calls, 3);
    expect(image.bytes, [9]);
  });

  test('after 3 failed calls it throws a plain failure', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"success":false}', 400);
    });

    await expectLater(
      makeIllustrator(client).renderScene('x', sheet, 0),
      throwsA(isA<IllustrationFailure>()),
    );
    expect(calls, 3);
  });

  test('a wrong key is not retried', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"success":false}', 401);
    });

    await expectLater(
      makeIllustrator(client).renderScene('x', sheet, 0),
      throwsA(isA<IllustrationFailure>()),
    );
    expect(calls, 1);
  });

  test('no internet gives a plain failure', () async {
    final client = MockClient((request) async {
      throw http.ClientException('offline');
    });

    await expectLater(
      makeIllustrator(client).renderScene('x', sheet, 0),
      throwsA(
        isA<IllustrationFailure>().having(
          (failure) => failure.message,
          'message',
          'No internet for pictures.',
        ),
      ),
    );
  });

  test('missing keys fail at once without a call', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('', 200);
    });

    await expectLater(
      makeIllustrator(client, token: '').renderScene('x', sheet, 0),
      throwsA(isA<IllustrationFailure>()),
    );
    expect(calls, 0);
  });
}
