/// Where the child is with one sentence in Reader Mode (designs p18–p20, decision 004).
enum ReaderStep {
  /// The mic button waits for a tap.
  ready,

  /// The microphone is being turned on (the permission dialog may be open).
  starting,

  /// The child is reading; the stop button is shown.
  listening,

  /// The transcript is on its way and the words are being scored.
  checking,

  /// The words are coloured; Read again and Next page are shown.
  checked,
}
