import 'models/child_profile.dart';

/// Saves and loads child profiles; screens only know this interface.
abstract class ChildRepository {
  /// All children of one parent, oldest first.
  Future<List<ChildProfile>> getChildren(String parentId);

  /// Saves a new child profile.
  Future<void> addChild(ChildProfile child);
}
