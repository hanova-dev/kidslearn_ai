/// A sign-in problem with a plain-language message for the parent (NFR-USE-03).
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  /// Short, friendly text that can be shown on screen as it is.
  final String message;

  @override
  String toString() => message;
}
