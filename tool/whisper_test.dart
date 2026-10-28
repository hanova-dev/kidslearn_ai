import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dev_env.dart';

// ── Settings ──
const String modelId = 'whisper-large-v3';
const String endpoint = 'https://api.groq.com/openai/v1/audio/transcriptions';
const String audioPath = 'tool/samples/rabbit.wav';
const String expectedText = 'The little rabbit shared her carrots.';

/// Spike test: sends one short sentence recording to Groq Whisper.
Future<void> main(List<String> arguments) async {
  final apiKey = readDevKey('GROQ_API_KEY');
  final path = arguments.isEmpty ? audioPath : arguments.first;
  final audioBytes = File(path).readAsBytesSync();
  final fileName = path.split('/').last;

  // ── Build multipart form body ──
  final boundary = 'kidslearn${DateTime.now().millisecondsSinceEpoch}';
  final body = BytesBuilder();
  void addField(String name, String value) {
    body.add(
      utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="$name"\r\n\r\n'
        '$value\r\n',
      ),
    );
  }

  addField('model', modelId);
  addField('language', 'en');
  addField('response_format', 'json');
  addField('temperature', '0');
  body.add(
    utf8.encode(
      '--$boundary\r\n'
      'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n'
      'Content-Type: application/octet-stream\r\n\r\n',
    ),
  );
  body.add(audioBytes);
  body.add(utf8.encode('\r\n--$boundary--\r\n'));

  // ── Call Groq API ──
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(endpoint));
  request.headers.set('Authorization', 'Bearer $apiKey');
  request.headers.set(
    'Content-Type',
    'multipart/form-data; boundary=$boundary',
  );
  request.add(body.takeBytes());
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
  if (response.statusCode != 200) {
    print(responseText);
    exit(1);
  }
  final decoded = jsonDecode(responseText) as Map<String, dynamic>;
  print('Audio file: $path (${audioBytes.length} bytes)');
  print('Expected:   $expectedText');
  print('Whisper:    ${(decoded['text'] as String).trim()}');
}
