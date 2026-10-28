import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';

void main() {
  final fatima = ChildProfile(
    id: 'child-1',
    parentId: 'parent-1',
    name: 'Fatima',
    buddyId: 'mango',
    ageGroup: AgeGroup.reader,
    language: 'en',
    starBalance: 12,
    readingLevel: 1,
    createdAt: DateTime(2026, 10, 27, 9, 30),
  );

  // ── toMap uses the SQLite column names ──
  test('toMap writes SQLite column names and simple values', () {
    final map = fatima.toMap();

    expect(map['child_id'], 'child-1');
    expect(map['buddy'], 'mango');
    expect(map['age_group'], 'reader_5_7');
    expect(
      map['created_at'],
      DateTime(2026, 10, 27, 9, 30).millisecondsSinceEpoch,
    );
  });

  // ── fromMap reads it back ──
  test('fromMap(toMap()) gives the same profile back', () {
    final copy = ChildProfile.fromMap(fatima.toMap());

    expect(copy.name, 'Fatima');
    expect(copy.ageGroup, AgeGroup.reader);
    expect(copy.starBalance, 12);
    expect(copy.createdAt, fatima.createdAt);
  });
}
