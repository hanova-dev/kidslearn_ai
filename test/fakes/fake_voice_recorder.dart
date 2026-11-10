import 'dart:io';

import 'package:kidslearn_ai/services/voice_recorder.dart';

/// [VoiceRecorder] for tests: writes a tiny pretend WAV file instead of using the microphone.
class FakeVoiceRecorder implements VoiceRecorder {
  FakeVoiceRecorder(this.folder, {this.allowed = true});

  final Directory folder;

  /// When false, [hasPermission] answers like a phone where the microphone was refused.
  final bool allowed;

  String? lastPath;
  int startCount = 0;
  int cancelCount = 0;

  @override
  Future<bool> hasPermission() async {
    return allowed;
  }

  @override
  Future<void> start() async {
    startCount++;
    final path = '${folder.path}/sentence-$startCount.wav';
    File(path).writeAsStringSync('RIFF pretend audio');
    lastPath = path;
  }

  @override
  Future<String?> stop() async {
    return lastPath;
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
    final path = lastPath;
    if (path != null && File(path).existsSync()) {
      File(path).deleteSync();
    }
  }
}
