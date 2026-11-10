import 'dart:io';

import 'package:kidslearn_ai/app/app_config.dart';
import 'package:kidslearn_ai/core/errors/speech_failure.dart';
import 'package:kidslearn_ai/services/groq_whisper_transcriber.dart';
import 'package:kidslearn_ai/services/voice_recorder.dart';

import 'dev_env.dart';

/// Real check: one sample sentence through the app's GroqWhisperTranscriber.transcribe.
Future<void> main() async {
  // ── Copy the sample, because transcribe deletes the file it sends ──
  final copy = File(
    '${Directory.systemTemp.path}/kidslearn_sentence_check.wav',
  );
  File('tool/samples/rabbit.wav').copySync(copy.path);
  print('Sample copied to ${copy.path} (${copy.lengthSync()} bytes)');

  // ── Send it to Groq Whisper ──
  final transcriber = GroqWhisperTranscriber(
    recorder: _NoMicrophone(),
    apiKey: readDevKey('GROQ_API_KEY'),
    modelId: AppConfig.speechModelId,
  );
  final stopwatch = Stopwatch()..start();
  try {
    final result = await transcriber.transcribe(copy.path, 'en');
    print('Done in ${stopwatch.elapsedMilliseconds} ms (${result.source})');
    print('Expected: The little rabbit shared her carrots.');
    print('Whisper:  ${result.text}');
  } on SpeechFailure catch (failure) {
    print('Failed: ${failure.message} (service down: ${failure.serviceDown})');
  }

  // ── The file must be gone (FR-STT-04) ──
  print('Sample file still on disk: ${copy.existsSync()}');
}

/// This check sends a file, so the microphone is never used.
class _NoMicrophone implements VoiceRecorder {
  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> start() async {}

  @override
  Future<String?> stop() async => null;

  @override
  Future<void> cancel() async {}
}
