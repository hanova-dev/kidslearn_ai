import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/auth_failure.dart';
import '../auth_repository.dart';

/// [AuthRepository] that uses Firebase Authentication with email and password.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  // ── Sign up ──
  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code));
    }
  }

  // ── Log in ──
  @override
  Future<void> logIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code));
    }
  }

  // ── Password reset ──
  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code));
    }
  }

  // ── Log out ──
  @override
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // ── Firebase error codes to plain English ──
  String _friendlyMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is not right. Please try again.';
      case 'email-already-in-use':
        return 'This email already has an account. Try Log in instead.';
      case 'weak-password':
        return 'Please use a password with at least 6 characters.';
      case 'network-request-failed':
        return 'No internet. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many tries. Please wait a minute and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
