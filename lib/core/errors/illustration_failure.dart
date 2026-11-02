/// A picture could not be drawn; the message is plain language (NFR-USE-03).
class IllustrationFailure implements Exception {
  const IllustrationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
