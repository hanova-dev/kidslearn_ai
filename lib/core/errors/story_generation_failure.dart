/// A story-writing problem with a plain-language message for the parent (NFR-USE-03).
class StoryGenerationFailure implements Exception {
  const StoryGenerationFailure(this.message);

  /// Short, friendly text that can be shown on screen as it is.
  final String message;

  @override
  String toString() => message;
}
