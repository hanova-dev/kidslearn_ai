import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'voice_recorder.dart';

/// [VoiceRecorder] that uses the phone's microphone through the record package.
class DeviceVoiceRecorder implements VoiceRecorder {
  AudioRecorder? _recorder;

  /// 16 kHz mono WAV: what Whisper uses inside, so nothing is lost and the file stays small.
  static const RecordConfig sentenceConfig = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  AudioRecorder get _microphone {
    _recorder ??= AudioRecorder();
    return _recorder!;
  }

  // ── Permission ──
  @override
  Future<bool> hasPermission() {
    return _microphone.hasPermission();
  }

  // ── Start: a new file in the temporary folder ──
  @override
  Future<void> start() async {
    final folder = await getTemporaryDirectory();
    final path =
        '${folder.path}/sentence-${DateTime.now().microsecondsSinceEpoch}.wav';
    await _microphone.start(sentenceConfig, path: path);
  }

  // ── Stop and cancel ──
  @override
  Future<String?> stop() {
    return _microphone.stop();
  }

  @override
  Future<void> cancel() {
    return _microphone.cancel();
  }
}
