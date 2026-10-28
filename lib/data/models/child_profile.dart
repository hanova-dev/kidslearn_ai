import 'age_group.dart';

/// One child linked to a parent (SRS 6.2 child_profiles, decision 015).
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.parentId,
    required this.name,
    required this.buddyId,
    required this.ageGroup,
    required this.language,
    required this.starBalance,
    required this.readingLevel,
    required this.createdAt,
  });

  final String id;
  final String parentId;

  /// The child's real name: stays on the phone, never sent to AI services.
  final String name;
  final String buddyId;
  final AgeGroup ageGroup;

  /// 'en' or 'ur' (only 'en' this semester, decision 005).
  final String language;
  final int starBalance;
  final int readingLevel;
  final DateTime createdAt;

  // ── To SQLite row ──
  /// Converts this profile to a map whose keys are the SQLite column names.
  Map<String, Object> toMap() {
    return {
      'child_id': id,
      'parent_id': parentId,
      'name': name,
      'buddy': buddyId,
      'age_group': ageGroup.dbValue,
      'language': language,
      'star_balance': starBalance,
      'reading_level': readingLevel,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // ── From SQLite row ──
  /// Builds a profile from one SQLite row.
  factory ChildProfile.fromMap(Map<String, Object?> map) {
    return ChildProfile(
      id: map['child_id'] as String,
      parentId: map['parent_id'] as String,
      name: map['name'] as String,
      buddyId: map['buddy'] as String,
      ageGroup: AgeGroup.fromDbValue(map['age_group'] as String),
      language: map['language'] as String,
      starBalance: map['star_balance'] as int,
      readingLevel: map['reading_level'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
