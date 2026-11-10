/// Records one sentence from the microphone into a temporary file; tests use a fake.
abstract class VoiceRecorder {
  /// True when the microphone may be used; asks the user the first time.
  Future<bool> hasPermission();

  /// Starts recording into a new temporary file.
  Future<void> start();

  /// Stops recording and returns the file path, or null if nothing was recorded.
  Future<String?> stop();

  /// Stops recording and deletes the file.
  Future<void> cancel();
}
