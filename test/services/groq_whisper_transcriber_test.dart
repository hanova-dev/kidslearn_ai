import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/services/groq_whisper_transcriber.dart';

import '../fakes/fake_voice_recorder.dart';

void main() {
  late Directory folder;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('whisper_test');
  });

  tearDown(() {
    folder.deleteSync(recursive: true);
  });

  GroqWhisperTranscriber makeTranscriber(
    MockClient client, {
    String apiKey = 'test-key',
    bool allowed = true,
  }) {
    return GroqWhisperTranscriber(
      recorder: FakeVoiceRecorder(folder, allowed: allowed),
      apiKey: apiKey,
      modelId: 'whisper-large-v3',
      client: client,
    );
  }

  http.Response whisperAnswer(String text) {
    return http.Response(jsonEncode({'text': text}), 200);
  }

  // ── One sentence to Whisper (FR-STT-02, FR-STT-06) ──
  test('sends the recording as a form and returns the text', () async {
    late http.Request sent;
    final transcriber = makeTranscriber(
      MockClient((request) async {
        sent = request;
        return whisperAnswer(' The little rabbit shared her carrots. ');
      }),
    );

    await transcriber.startListening('en');
    final result = await transcriber.stopListening();

    expect(result.text, 'The little rabbit shared her carrots.');
    expect(result.source, 'WHISPER');
    expect(sent.url.toString(), endsWith('/openai/v1/audio/transcriptions'));
    expect(sent.headers['Authorization'], 'Bearer test-key');
    final body = utf8.decode(sent.bodyBytes, allowMalformed: true);
    expect(body, contains('name="model"\r\n\r\nwhisper-large-v3'));
    expect(body, contains('name="language"\r\n\r\nen'));
    expect(body, contains('name="response_format"\r\n\r\njson'));
    expect(body, contains('name="temperature"\r\n\r\n0'));
    expect(body, contains('filename="sentence-1.wav"'));
    expect(body, contains('RIFF pretend audio'));
  });

  // ── The recording is never kept (FR-STT-04, NFR-PRIV-01) ──
  test('the recording is deleted after the transcript', () async {
    final transcriber = makeTranscriber(
      MockClient((request) async => whisperAnswer('Hello')),
    );

    await transcriber.startListening('en');
    await transcriber.stopListening();

    expect(folder.listSync(), isEmpty);
  });

  test('the recording is deleted when the call fails too', () async {
    final transcriber = makeTranscriber(
      MockClient((request) async => http.Response('busy', 429)),
    );

    await transcriber.startListening('en');
    await expectLater(
      transcriber.stopListening(),
      throwsA(isA<SpeechFailure>()),
    );

    expect(folder.listSync(), isEmpty);
  });

  // ── Problems that should switch to the phone recogniser (FR-STT-07) ──
  test('no internet means the service is down', () async {
    final transcriber = makeTranscriber(
      MockClient((request) async => throw http.ClientException('offline')),
    );

    await transcriber.startListening('en');
    final failure = await _failureOf(transcriber.stopListening());

    expect(failure.serviceDown, isTrue);
  });

  test(
    'a busy answer (429) is not retried and means the service is down',
    () async {
      var calls = 0;
      final transcriber = makeTranscriber(
        MockClient((request) async {
          calls++;
          return http.Response('rate limit', 429);
        }),
      );

      await transcriber.startListening('en');
      final failure = await _failureOf(transcriber.stopListening());

      expect(failure.serviceDown, isTrue);
      expect(calls, 1);
    },
  );

  test('a missing key fails without calling Groq', () async {
    var calls = 0;
    final transcriber = makeTranscriber(
      MockClient((request) async {
        calls++;
        return whisperAnswer('Hello');
      }),
      apiKey: '',
    );

    await transcriber.startListening('en');
    final failure = await _failureOf(transcriber.stopListening());

    expect(failure.serviceDown, isTrue);
    expect(calls, 0);
    expect(folder.listSync(), isEmpty);
  });

  // ── Problems the child can fix by trying again (FR-STT-05) ──
  test('an empty transcript asks the child to read again', () async {
    final transcriber = makeTranscriber(
      MockClient((request) async => whisperAnswer('  ')),
    );

    await transcriber.startListening('en');
    final failure = await _failureOf(transcriber.stopListening());

    expect(failure.serviceDown, isFalse);
    expect(failure.message, contains("didn't hear"));
  });

  test(
    'no microphone permission gives a plain message and records nothing',
    () async {
      final transcriber = makeTranscriber(
        MockClient((request) async => whisperAnswer('Hello')),
        allowed: false,
      );

      final failure = await _failureOf(transcriber.startListening('en'));

      expect(failure.serviceDown, isFalse);
      expect(failure.message, contains('microphone'));
      expect(folder.listSync(), isEmpty);
    },
  );
}

/// Waits for [future] to fail and returns its [SpeechFailure].
Future<SpeechFailure> _failureOf(Future<Object?> future) async {
  try {
    await future;
  } on SpeechFailure catch (failure) {
    return failure;
  }
  throw StateError('Expected a SpeechFailure');
}
