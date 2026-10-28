import 'package:kidslearn_ai/core/errors/auth_failure.dart';
import 'package:kidslearn_ai/data/auth_repository.dart';

/// In-memory [AuthRepository] for tests: one known parent, no network.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.signedInUserId});

  static const String knownEmail = 'ayesha@email.com';
  static const String knownPassword = 'secret123';

  String? signedInUserId;
  final List<String> resetEmailsSent = [];

  @override
  String? get currentUserId => signedInUserId;

  @override
  Future<void> logIn({required String email, required String password}) async {
    if (email != knownEmail || password != knownPassword) {
      throw const AuthFailure(
        'Email or password is not right. Please try again.',
      );
    }
    signedInUserId = 'parent-1';
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    if (email == knownEmail) {
      throw const AuthFailure(
        'This email already has an account. Try Log in instead.',
      );
    }
    signedInUserId = 'parent-2';
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmailsSent.add(email);
  }

  @override
  Future<void> logOut() async {
    signedInUserId = null;
  }
}
