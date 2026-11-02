import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/errors/story_generation_failure.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/models/story.dart';
import '../../../data/models/story_prompt.dart';
import '../../../data/models/story_status.dart';
import '../../../services/story_prompt_builder.dart';

/// Creates one story: DRAFT → GENERATING → READY or FAILED (FR-STORY-03, FR-STORY-04).
///
/// State: loading while writing, data with the ready story, or error with a plain message.
class StoryCreationController extends AsyncNotifier<Story?> {
  String? _storyId;
  StoryPrompt? _prompt;

  @override
  FutureOr<Story?> build() {
    return null;
  }

  /// Saves a draft for [child] and asks the story model to write it.
  Future<void> create({
    required String text,
    required String value,
    required ChildProfile child,
  }) async {
    state = const AsyncLoading();

    // ── Save draft story to SQLite (before the network call) ──
    final parentId = ref.read(authRepositoryProvider).currentUserId ?? '';
    final now = DateTime.now();
    final draft = Story(
      id: 'story-${now.microsecondsSinceEpoch}',
      parentId: parentId,
      childId: child.id,
      promptText: text.trim(),
      promptValue: value,
      title: '',
      moralValue: '',
      language: child.language,
      characterSheet: '',
      seed: 0,
      status: StoryStatus.draft,
      approved: false,
      createdAt: now,
    );
    try {
      await ref.read(storyRepositoryProvider).saveDraft(draft);
    } catch (error) {
      state = AsyncError(
        const StoryGenerationFailure(
          'Could not save the story. Please try again.',
        ),
        StackTrace.current,
      );
      return;
    }

    // ── Build the redacted prompt (no real name) ──
    final buddy = Buddies.byId(child.buddyId);
    _storyId = draft.id;
    _prompt = StoryPromptBuilder.build(
      parentText: text,
      value: value,
      child: child,
      buddyName: buddy.name,
      buddyAnimal: buddy.animal,
    );
    await _write();
  }

  /// Tries the last story again after a failure, with the same prompt (FR-STORY-04).
  Future<void> retry() async {
    if (_storyId == null || _prompt == null) {
      return;
    }
    state = const AsyncLoading();
    await _write();
  }

  // ── Ask the story model and save the answer ──
  Future<void> _write() async {
    final repository = ref.read(storyRepositoryProvider);
    final service = ref.read(storyGenerationServiceProvider);
    final storyId = _storyId!;
    try {
      await repository.updateStatus(storyId, StoryStatus.generating);
      final narrative = await service.generateNarrative(_prompt!);
      await repository.saveNarrative(storyId, narrative);
      await repository.updateStatus(storyId, StoryStatus.ready);
      state = AsyncData(await repository.getStory(storyId));
    } catch (error) {
      await _markFailed(storyId);
      state = AsyncError(_friendly(error), StackTrace.current);
    }
  }

  // ── Mark FAILED so the story can be retried later ──
  Future<void> _markFailed(String storyId) async {
    try {
      await ref
          .read(storyRepositoryProvider)
          .updateStatus(storyId, StoryStatus.failed);
    } catch (error) {
      return;
    }
  }

  StoryGenerationFailure _friendly(Object error) {
    if (error is StoryGenerationFailure) {
      return error;
    }
    return const StoryGenerationFailure(
      'Something went wrong while writing the story. Please try again.',
    );
  }
}

/// Gives the Create story and Story generating screens the [StoryCreationController].
final storyCreationControllerProvider =
    AsyncNotifierProvider<StoryCreationController, Story?>(
      StoryCreationController.new,
    );
