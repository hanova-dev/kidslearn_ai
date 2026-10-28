/// What the app needs from a sign-in system; screens only know this interface.
abstract class AuthRepository {
  /// The signed-in parent's user ID, or null when nobody is signed in.
  String? get currentUserId;

  /// Creates a new parent account and signs it in.
  Future<void> signUp({required String email, required String password});

  /// Signs in an existing parent.
  Future<void> logIn({required String email, required String password});

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordReset(String email);

  /// Signs the parent out on this device.
  Future<void> logOut();
}
