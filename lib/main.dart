import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/theme.dart';
import 'data/local/app_database.dart';
import 'data/local/sqlite_story_repository.dart';

/// Starts Firebase and the local database, then the KidsLearn AI app.
Future<void> main() async {
  // ── Start Firebase (reads android/app/google-services.json) ──
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ── Open the SQLite database ──
  final database = await AppDatabase.open();

  // ── Stories stopped by an app close become FAILED (decision 023) ──
  await SqliteStoryRepository(database).failInterruptedStories();

  // ── Start the app inside Riverpod ──
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const KidsLearnApp(),
    ),
  );
}

/// Root widget: day or night theme from the phone, screens from the router.
class KidsLearnApp extends ConsumerWidget {
  const KidsLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'KidsLearn AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.day(),
      darkTheme: AppTheme.night(),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
