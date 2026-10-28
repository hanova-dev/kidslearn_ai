import 'package:kidslearn_ai/data/child_repository.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';

/// In-memory [ChildRepository] for widget tests.
class FakeChildRepository implements ChildRepository {
  FakeChildRepository({this.failOnSave = false});

  /// When true, [addChild] throws, to test the error message.
  final bool failOnSave;
  final List<ChildProfile> saved = [];

  @override
  Future<List<ChildProfile>> getChildren(String parentId) async {
    final result = <ChildProfile>[];
    for (final child in saved) {
      if (child.parentId == parentId) {
        result.add(child);
      }
    }
    return result;
  }

  @override
  Future<void> addChild(ChildProfile child) async {
    if (failOnSave) {
      throw Exception('disk full');
    }
    saved.add(child);
  }
}
