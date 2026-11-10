/// What the child said, as text, and which service heard it (SRS Figure 7.2).
class TranscriptResult {
  const TranscriptResult({required this.text, required this.source});

  final String text;

  /// 'WHISPER' or 'DEVICE'.
  final String source;
}
