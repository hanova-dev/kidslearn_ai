/// The two child age groups (SRS 10.4); each one picks a reading mode.
enum AgeGroup {
  listener(
    'listener_2_4',
    '2–4',
    'Little Listener',
    'Listens along, sees words light up',
  ),
  reader(
    'reader_5_7',
    '5–7',
    'Growing Reader',
    'Reads aloud, gets gentle feedback',
  );

  const AgeGroup(this.dbValue, this.ageRange, this.title, this.description);

  /// Text saved in SQLite (child_profiles.age_group).
  final String dbValue;
  final String ageRange;
  final String title;
  final String description;

  /// Turns the saved SQLite text back into an [AgeGroup].
  static AgeGroup fromDbValue(String value) {
    if (value == reader.dbValue) {
      return reader;
    }
    return listener;
  }
}
