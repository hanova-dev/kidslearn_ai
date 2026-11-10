import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app/app_config.dart';
import '../core/errors/speech_failure.dart';
import '../data/models/transcript_result.dart';
import 'speech_to_text_service.dart';
import 'voice_recorder.dart';

/// [SpeechToTextService] that records a sentence and sends it to Groq Whisper (FR-STT-02, decision 028).
class GroqWhisperTranscriber implements SpeechToTextService {
  GroqWhisperTranscriber({
    required this.recorder,
    required this.apiKey,
    required this.modelId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final VoiceRecorder recorder;
  final String apiKey;
  final String modelId;
  final http.Client _client;
  String _language = 'en';

  static const String noSpeechMessage =
      "We didn't hear anything. Tap the microphone and read again.";

  // ── Start: check the microphone, then record ──
  @override
  Future<void> startListening(String languageCode) async {
    if (!await recorder.hasPermission()) {
      throw const SpeechFailure(
        'Please let KidsLearn use the microphone. '
        'A grown-up can allow it in Settings.',
      );
    }
    _language = languageCode;
    await recorder.start();
  }

  // ── Stop: send the recording to Whisper ──
  @override
  Future<TranscriptResult> stopListening() async {
    final path = await recorder.stop();
    if (path == null) {
      throw const SpeechFailure(noSpeechMessage);
    }
    return transcribe(path, _language);
  }

  @override
  Future<void> cancel() {
    return recorder.cancel();
  }

  /// Sends the WAV file at [path] to Whisper and always deletes it afterwards (FR-STT-04).
  Future<TranscriptResult> transcribe(String path, String languageCode) async {
    try {
      return await _send(path, languageCode);
    } finally {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // ── Call Groq API: one sentence, one request (FR-STT-06) ──
  Future<TranscriptResult> _send(String path, String languageCode) async {
    if (apiKey.isEmpty) {
      throw const SpeechFailure(
        'Listening is not set up on this phone.',
        serviceDown: true,
      );
    }
    final request =
        http.MultipartRequest('POST', Uri.parse(AppConfig.groqTranscriptionUrl))
          ..headers['Authorization'] = 'Bearer $apiKey'
          ..fields['model'] = modelId
          ..fields['language'] = languageCode
          ..fields['response_format'] = 'json'
          ..fields['temperature'] = '0'
          ..files.add(await http.MultipartFile.fromPath('file', path));
    http.Response response;
    try {
      final streamed = await _client
          .send(request)
          .timeout(AppConfig.requestTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const SpeechFailure(
        'The listening helper took too long.',
        serviceDown: true,
      );
    } on http.ClientException {
      throw const SpeechFailure(
        'No internet for listening.',
        serviceDown: true,
      );
    }
    if (response.statusCode != 200) {
      throw SpeechFailure(
        _messageForStatus(response.statusCode),
        serviceDown: true,
      );
    }
    return TranscriptResult(text: _readText(response.body), source: 'WHISPER');
  }

  // ── Read the text from the answer ──
  String _readText(String responseBody) {
    String text;
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      text = (decoded['text'] as String).trim();
    } on FormatException {
      throw const SpeechFailure(
        'The listening helper sent a broken answer.',
        serviceDown: true,
      );
    } on TypeError {
      throw const SpeechFailure(
        'The listening helper sent a broken answer.',
        serviceDown: true,
      );
    }
    if (text.isEmpty) {
      throw const SpeechFailure(noSpeechMessage);
    }
    return text;
  }

  // ── HTTP status to plain English ──
  String _messageForStatus(int statusCode) {
    if (statusCode == 429) {
      return 'The listening helper is busy.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'The listening helper key is not working.';
    }
    return 'Something went wrong while listening.';
  }
}
