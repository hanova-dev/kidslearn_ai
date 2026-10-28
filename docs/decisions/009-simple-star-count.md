# 009 — Simple star count, no worlds or unlocks

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-MODE-06 (partial), FR-HCI-06

**Context:** The designs show stars on the reading screen (12, 15, 18), "+3", "+15 stars earned" and a world map with unlocks. Full rewards (rest of M6/M7) are out of scope, but Story complete (p22) is in scope.

**Decision:** Stars per sentence: 3 if all words are CORRECT, 2 if all words are CORRECT or NEAR_MISS, otherwise 1. Stars are never taken away. The total is saved in `reading_sessions.stars_earned` and `child_profiles.star_balance`. The path map shows the stories in order, all unlocked, and has no worlds.

**Alternatives:** No stars at all (Story complete has nothing to show). Full worlds and unlocks (out of scope).

**Consequences:** The star rule is one short function, easy to change in a viva drill.
