/// A listening problem with a plain-language message (NFR-USE-03).
class SpeechFailure implements Exception {
  const SpeechFailure(this.message, {this.serviceDown = false});

  /// Short, friendly text that can be shown on screen as it is.
  final String message;

  /// True when the service itself cannot work now (no internet, quota, key), so the fallback should take over (FR-STT-07).
  final bool serviceDown;

  @override
  String toString() => message;
}
