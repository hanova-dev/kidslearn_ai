import 'package:kidslearn_ai/data/models/narrative_result.dart';
import 'package:kidslearn_ai/data/models/scene.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/data/story_repository.dart';

/// In-memory [StoryRepository] that follows the same status rules as SQLite.
class FakeStoryRepository implements StoryRepository {
  final Map<String, Story> stories = {};
  final Map<String, List<Scene>> scenes = {};

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
    final list = <Scene>[];
    for (var i = 0; i < narrative.scenes.length; i++) {
      list.add(
        Scene(
          id: '$storyId-scene-${i + 1}',
          storyId: storyId,
          sequenceNumber: i + 1,
          text: narrative.scenes[i].text,
          imagePrompt: narrative.scenes[i].imagePrompt,
          imagePath: null,
          imageSource: null,
        ),
      );
    }
    scenes[storyId] = list;
  }

  @override
  Future<void> saveSceneImage(
    String sceneId,
    String imagePath,
    String source,
  ) async {
    for (final list in scenes.values) {
      for (var i = 0; i < list.length; i++) {
        final old = list[i];
        if (old.id == sceneId) {
          list[i] = Scene(
            id: old.id,
            storyId: old.storyId,
            sequenceNumber: old.sequenceNumber,
            text: old.text,
            imagePrompt: old.imagePrompt,
            imagePath: imagePath,
            imageSource: source,
          );
        }
      }
    }
  }

  @override
  Future<void> setApproved(String storyId, bool approved) async {
    stories[storyId] = _copy(stories[storyId]!, approved: approved);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    stories.remove(storyId);
    scenes.remove(storyId);
  }

  @override
  Future<Story?> getStory(String storyId) async {
    return stories[storyId];
  }

  @override
  Future<List<Scene>> getScenes(String storyId) async {
    return List.of(scenes[storyId] ?? []);
  }

  @override
  Future<List<Story>> getStoriesForParent(String parentId) async {
    final list = <Story>[];
    for (final story in stories.values) {
      if (story.parentId == parentId) {
        list.add(story);
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<int> failInterruptedStories() async {
    var count = 0;
    for (final story in stories.values.toList()) {
      if (story.status == StoryStatus.draft ||
          story.status == StoryStatus.generating) {
        stories[story.id] = _copy(story, status: StoryStatus.failed);
        count++;
      }
    }
    return count;
  }

  Story _copy(
    Story story, {
    StoryStatus? status,
    String? title,
    String? moralValue,
    bool? approved,
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
      approved: approved ?? story.approved,
      createdAt: story.createdAt,
    );
  }
}
