import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/local/app_database.dart';
import 'package:kidslearn_ai/data/local/sqlite_child_repository.dart';
import 'package:kidslearn_ai/data/models/age_group.dart';
import 'package:kidslearn_ai/data/models/child_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

ChildProfile makeChild(String id, String parentId, String name, int minute) {
  return ChildProfile(
    id: id,
    parentId: parentId,
    name: name,
    buddyId: 'sky',
    ageGroup: AgeGroup.listener,
    language: 'en',
    starBalance: 0,
    readingLevel: 1,
    createdAt: DateTime(2026, 10, 27, 10, minute),
  );
}

void main() {
  late Database db;
  late SqliteChildRepository repository;

  // ── Fresh in-memory database for every test (real SQL, no phone) ──
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.version,
        onCreate: AppDatabase.createTables,
      ),
    );
    repository = SqliteChildRepository(db);
  });
  tearDown(() => db.close());

  // ── Save and load ──
  test('a saved child comes back with the same values', () async {
    await repository.addChild(makeChild('c1', 'parent-1', 'Zayan', 0));

    final children = await repository.getChildren('parent-1');

    expect(children.length, 1);
    expect(children.first.name, 'Zayan');
    expect(children.first.ageGroup, AgeGroup.listener);
  });

  // ── Only this parent's children, oldest first ──
  test('returns only one parent\'s children, oldest first', () async {
    await repository.addChild(makeChild('c2', 'parent-1', 'Fatima', 5));
    await repository.addChild(makeChild('c1', 'parent-1', 'Zayan', 1));
    await repository.addChild(makeChild('c3', 'parent-2', 'Ali', 0));

    final children = await repository.getChildren('parent-1');

    expect(children.map((child) => child.name).toList(), ['Zayan', 'Fatima']);
  });

  // ── Empty list for a new parent ──
  test('a parent with no children gets an empty list', () async {
    expect(await repository.getChildren('parent-9'), isEmpty);
  });

  // ── Stars only go up (FR-HCI-06) ──
  test('addStars adds to the balance; zero or less changes nothing', () async {
    await repository.addChild(makeChild('c1', 'parent-1', 'Zayan', 0));

    await repository.addStars('c1', 6);
    await repository.addStars('c1', 3);
    await repository.addStars('c1', -5);
    await repository.addStars('c1', 0);

    final children = await repository.getChildren('parent-1');
    expect(children.first.starBalance, 9);
  });
}
