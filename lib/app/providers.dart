import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';

import '../data/auth_repository.dart';
import '../data/child_repository.dart';
import '../data/local/image_file_store.dart';
import '../data/local/sqlite_child_repository.dart';
import '../data/local/sqlite_reading_session_repository.dart';
import '../data/local/sqlite_story_repository.dart';
import '../data/remote/firebase_auth_repository.dart';
import '../data/reading_session_repository.dart';
import '../data/story_repository.dart';
import '../services/device_tts_narrator.dart';
import '../services/flux_illustrator.dart';
import '../services/groq_story_generator.dart';
import '../services/illustration_service.dart';
import '../services/placeholder_illustrator.dart';
import '../services/story_generation_service.dart';
import '../services/text_to_speech_service.dart';
import 'app_config.dart';
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

/// Where stories and scenes are stored (SQLite on the phone).
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return SqliteStoryRepository(ref.watch(databaseProvider));
});

/// Where finished readings are stored (SQLite on the phone, decision 024).
final readingSessionRepositoryProvider = Provider<ReadingSessionRepository>((
  ref,
) {
  return SqliteReadingSessionRepository(ref.watch(databaseProvider));
});

/// Who writes the stories (Groq gpt-oss-120b today).
final storyGenerationServiceProvider = Provider<StoryGenerationService>((ref) {
  return GroqStoryGenerator(
    apiKey: AppConfig.groqApiKey,
    modelId: AppConfig.storyModelId,
  );
});

/// Who draws the scene pictures first (FLUX.1 schnell on Cloudflare today).
final illustrationServiceProvider = Provider<IllustrationService>((ref) {
  return FluxIllustrator(
    accountId: AppConfig.cloudflareAccountId,
    apiToken: AppConfig.cloudflareApiToken,
  );
});

/// Who draws a scene when the first one fails: no network needed (FR-ILLUS-06).
final fallbackIllustrationServiceProvider = Provider<IllustrationService>((
  ref,
) {
  return PlaceholderIllustrator();
});

/// Who reads the story aloud (the phone's own voice, FR-TTS-01).
final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  return DeviceTtsNarrator();
});

/// Where scene pictures are saved as files (FR-ILLUS-02).
final imageFileStoreProvider = Provider<ImageFileStore>((ref) {
  return ImageFileStore();
});

// ── Navigation ──

/// The app's router, built once with the sign-in and parental-gate guards.
final routerProvider = Provider<GoRouter>((ref) {
  return buildRouter(ref);
});
