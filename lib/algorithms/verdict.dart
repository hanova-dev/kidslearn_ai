/// The result of scoring one spoken word (FR-SCORE-04, SRS D4: TRY_AGAIN, never "wrong").
enum Verdict {
  correct('CORRECT'),
  nearMiss('NEAR_MISS'),
  tryAgain('TRY_AGAIN');

  const Verdict(this.dbValue);

  /// Text saved in SQLite (score_results.verdict).
  final String dbValue;
}
