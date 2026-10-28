import 'package:sqflite/sqflite.dart';

import '../child_repository.dart';
import '../models/child_profile.dart';

/// [ChildRepository] that keeps child profiles in local SQLite (decision 007).
class SqliteChildRepository implements ChildRepository {
  SqliteChildRepository(this._db);

  final Database _db;

  // ── Load children ──
  @override
  Future<List<ChildProfile>> getChildren(String parentId) async {
    final rows = await _db.query(
      'child_profiles',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'created_at ASC',
    );
    final children = <ChildProfile>[];
    for (final row in rows) {
      children.add(ChildProfile.fromMap(row));
    }
    return children;
  }

  // ── Save a child ──
  @override
  Future<void> addChild(ChildProfile child) async {
    await _db.insert('child_profiles', child.toMap());
  }
}
