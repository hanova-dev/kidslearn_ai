import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/app/providers.dart';
import 'package:kidslearn_ai/features/auth/controllers/parent_unlock.dart';
import 'package:kidslearn_ai/main.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_child_repository.dart';
import '../fakes/fake_illustrator.dart';
import '../fakes/fake_image_file_store.dart';
import '../fakes/fake_reading_session_repository.dart';
import '../fakes/fake_speech_to_text.dart';
import '../fakes/fake_story_generator.dart';
import '../fakes/fake_story_repository.dart';
import '../fakes/fake_text_to_speech.dart';

/// Makes the test screen the size of a typical Android phone (360 × 800 dp).
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// The whole app with fake sign-in, storage, story writer, illustrators and speech (no Firebase, disk, network or microphone).
Widget buildTestApp({
  required FakeAuthRepository auth,
  FakeChildRepository? children,
  FakeStoryRepository? stories,
  FakeReadingSessionRepository? sessions,
  FakeTextToSpeech? voice,
  FakeSpeechToText? speech,
  FakeStoryGenerator? storyGenerator,
  FakeIllustrator? illustrator,
  bool parentUnlocked = false,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      childRepositoryProvider.overrideWithValue(
        children ?? FakeChildRepository(),
      ),
      storyRepositoryProvider.overrideWithValue(
        stories ?? FakeStoryRepository(),
      ),
      readingSessionRepositoryProvider.overrideWithValue(
        sessions ?? FakeReadingSessionRepository(),
      ),
      storyGenerationServiceProvider.overrideWithValue(
        storyGenerator ?? FakeStoryGenerator(),
      ),
      illustrationServiceProvider.overrideWithValue(
        illustrator ?? FakeIllustrator(),
      ),
      fallbackIllustrationServiceProvider.overrideWithValue(
        FakeIllustrator(source: 'PLACEHOLDER'),
      ),
      imageFileStoreProvider.overrideWithValue(FakeImageFileStore()),
      textToSpeechServiceProvider.overrideWithValue(
        voice ?? FakeTextToSpeech(),
      ),
      speechToTextServiceProvider.overrideWithValue(
        speech ?? FakeSpeechToText(source: 'WHISPER'),
      ),
      if (parentUnlocked) parentUnlockProvider.overrideWith(_StartUnlocked.new),
    ],
    child: const KidsLearnApp(),
  );
}

/// Starts with the parent area already open, to test parent screens quickly.
class _StartUnlocked extends ParentUnlock {
  @override
  bool build() {
    return true;
  }
}
