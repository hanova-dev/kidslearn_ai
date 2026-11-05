import 'models/narrative_result.dart';
import 'models/scene.dart';
import 'models/story.dart';
import 'models/story_status.dart';

/// Saves and loads stories and their scenes; screens only know this interface.
abstract class StoryRepository {
  /// Saves a new story with status DRAFT, before any network call (FR-STORY-03).
  Future<void> saveDraft(Story story);

  /// Moves a story to [status]; throws StateError if the lifecycle forbids it.
  Future<void> updateStatus(String storyId, StoryStatus status);

  /// Stores the model's title, moral, character sheet and scenes (replacing old scenes).
  Future<void> saveNarrative(String storyId, NarrativeResult narrative);

  /// Records where a scene's picture file is and who drew it (FR-ILLUS-02).
  Future<void> saveSceneImage(String sceneId, String imagePath, String source);

  /// Marks the story approved or not approved; only approved stories reach the child (FR-STORY-07).
  Future<void> setApproved(String storyId, bool approved);

  /// Removes the story and its scenes; the caller deletes the picture files (FR-STORY-07).
  Future<void> deleteStory(String storyId);

  /// One story, or null if it does not exist.
  Future<Story?> getStory(String storyId);

  /// The story's scenes in reading order.
  Future<List<Scene>> getScenes(String storyId);

  /// Every story of one parent, newest first (Story library, design p9).
  Future<List<Story>> getStoriesForParent(String parentId);

  /// The approved, READY stories of one child, oldest first (path map, FR-STORY-07).
  Future<List<Story>> getApprovedStoriesForChild(String childId);

  /// Marks stories left in DRAFT or GENERATING by an app close as FAILED; returns how many (decision 023).
  Future<int> failInterruptedStories();
}
