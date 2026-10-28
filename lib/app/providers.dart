import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';

import '../data/auth_repository.dart';
import '../data/child_repository.dart';
import '../data/local/sqlite_child_repository.dart';
import '../data/remote/firebase_auth_repository.dart';
import 'router.dart';

// ── Local database ──

/// The open SQLite database; the real value is given in main().
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('The database is opened in main().');
});

// ── Adapters (the one place that chooses real implementations) ──

/// The sign-in system used by the whole app (Firebase today).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Where child profiles are stored (SQLite on the phone).
final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return SqliteChildRepository(ref.watch(databaseProvider));
});

// ── Navigation ──

/// The app's router, built once with the sign-in and parental-gate guards.
final routerProvider = Provider<GoRouter>((ref) {
  return buildRouter(ref);
});
