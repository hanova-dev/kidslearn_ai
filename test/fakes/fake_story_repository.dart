import 'package:kidslearn_ai/data/models/narrative_result.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/data/story_repository.dart';

/// In-memory [StoryRepository] that follows the same status rules as SQLite.
class FakeStoryRepository implements StoryRepository {
  final Map<String, Story> stories = {};

  /// Every status a story moved to, in order, e.g. [GENERATING, READY].
  final List<StoryStatus> statusHistory = [];

  @override
  Future<void> saveDraft(Story story) async {
    stories[story.id] = story;
  }

  @override
  Future<void> updateStatus(String storyId, StoryStatus status) async {
    final story = stories[storyId]!;
    if (!story.status.canMoveTo(status)) {
      throw StateError('Cannot move to ${status.dbValue}');
    }
    stories[storyId] = _copy(story, status: status);
    statusHistory.add(status);
  }

  @override
  Future<void> saveNarrative(String storyId, NarrativeResult narrative) async {
    stories[storyId] = _copy(
      stories[storyId]!,
      title: narrative.title,
      moralValue: narrative.moralValue,
    );
  }

  @override
  Future<Story?> getStory(String storyId) async {
    return stories[storyId];
  }

  @override
  Future<List<Scene>> getScenes(String storyId) async {
    return [];
  }

  Story _copy(
    Story story, {
    StoryStatus? status,
    String? title,
    String? moralValue,
  }) {
    return Story(
      id: story.id,
      parentId: story.parentId,
      childId: story.childId,
      promptText: story.promptText,
      promptValue: story.promptValue,
      title: title ?? story.title,
      moralValue: moralValue ?? story.moralValue,
      language: story.language,
      characterSheet: story.characterSheet,
      seed: story.seed,
      status: status ?? story.status,
      approved: story.approved,
      createdAt: story.createdAt,
    );
  }
}
