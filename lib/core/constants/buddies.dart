import 'package:flutter/painting.dart';

/// One story buddy: its name replaces the child's real name in AI prompts.
class Buddy {
  const Buddy({
    required this.id,
    required this.name,
    required this.animal,
    required this.color,
  });

  /// Saved in SQLite (child_profiles.buddy).
  final String id;

  /// Used as the story hero's name (FR-STORY-08).
  final String name;

  /// Tells the story model what the hero looks like.
  final String animal;

  final Color color;
}

/// The 4 fixed buddies from decision 001 and 015.
class Buddies {
  static const Buddy mango = Buddy(
    id: 'mango',
    name: 'Mango',
    animal: 'fox',
    color: Color(0xFFF28A2E),
  );
  static const Buddy sky = Buddy(
    id: 'sky',
    name: 'Sky',
    animal: 'bunny',
    color: Color(0xFF5CC8F5),
  );
  static const Buddy leafy = Buddy(
    id: 'leafy',
    name: 'Leafy',
    animal: 'turtle',
    color: Color(0xFF34C47C),
  );
  static const Buddy rosy = Buddy(
    id: 'rosy',
    name: 'Rosy',
    animal: 'kitten',
    color: Color(0xFFFF7BAC),
  );

  static const List<Buddy> all = [mango, sky, leafy, rosy];

  /// Finds a buddy by its saved id; unknown ids fall back to Mango.
  static Buddy byId(String id) {
    for (final buddy in all) {
      if (buddy.id == id) {
        return buddy;
      }
    }
    return mango;
  }
}
