import 'dart:convert';
import 'dart:io';

import 'dev_env.dart';

// ── Settings ──
const String modelId = '@cf/black-forest-labs/flux-1-schnell';
const int steps = 4;

const String prompt =
    'Children\'s picture-book comic style, soft warm colours, simple rounded '
    'shapes, no text. Character: Mango, a small orange fox cub with a cream '
    'belly and a green scarf. Scene: Mango sits on a rug hugging a red toy '
    'car while a smiling baby fox looks at it.';

/// Spike test: draws one scene twice with the same prompt and saves both images.
Future<void> main() async {
  final accountId = readDevKey('CLOUDFLARE_ACCOUNT_ID');
  final apiToken = readDevKey('CLOUDFLARE_API_TOKEN');
  final url =
      'https://api.cloudflare.com/client/v4/accounts/$accountId'
      '/ai/run/$modelId';

  // ── Draw the same scene two times ──
  final first = await drawImage(url, apiToken);
  final second = await drawImage(url, apiToken);

  // ── Save images to files ──
  final firstFile = File('tool/output/scene_a.jpg');
  final secondFile = File('tool/output/scene_b.jpg');
  firstFile.createSync(recursive: true);
  firstFile.writeAsBytesSync(first);
  secondFile.writeAsBytesSync(second);
  print('Saved: ${firstFile.path} (${first.length} bytes)');
  print('Saved: ${secondFile.path} (${second.length} bytes)');

  // ── Compare the two images ──
  var same = first.length == second.length;
  for (var i = 0; same && i < first.length; i++) {
    if (first[i] != second[i]) {
      same = false;
    }
  }
  print('Same prompt gave the exact same image: ${same ? 'yes' : 'no'}');
}

/// Calls Cloudflare Workers AI once and returns the JPEG image bytes.
Future<List<int>> drawImage(String url, String apiToken) async {
  // ── Call Cloudflare API ──
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(url));
  request.headers.set('Authorization', 'Bearer $apiToken');
  request.headers.contentType = ContentType.json;
  request.add(utf8.encode(jsonEncode({'prompt': prompt, 'steps': steps})));
  final response = await request.close();
  final responseText = await response.transform(utf8.decoder).join();
  client.close();
  stopwatch.stop();

  // ── Read base64 image ──
  print(
    'HTTP status: ${response.statusCode} '
    '(${stopwatch.elapsedMilliseconds} ms)',
  );
  if (response.statusCode != 200) {
    print(responseText);
    exit(1);
  }
  final decoded = jsonDecode(responseText) as Map<String, dynamic>;
  final base64Image = decoded['result']['image'] as String;
  return base64Decode(base64Image);
}
