/// One step of a word alignment: a target word and the spoken word matched to it (SRS 8.1.6).
///
/// [spoken] is null when the child skipped [target]; [target] is null for an extra spoken word.
class WordPair {
  const WordPair({required this.target, required this.spoken});

  final String? target;
  final String? spoken;
}
