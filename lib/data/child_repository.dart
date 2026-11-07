import 'models/child_profile.dart';

/// Saves and loads child profiles; screens only know this interface.
abstract class ChildRepository {
  /// All children of one parent, oldest first.
  Future<List<ChildProfile>> getChildren(String parentId);

  /// Saves a new child profile.
  Future<void> addChild(ChildProfile child);

  /// Adds [stars] to the child's star balance; stars are never taken away (FR-HCI-06).
  Future<void> addStars(String childId, int stars);
}
