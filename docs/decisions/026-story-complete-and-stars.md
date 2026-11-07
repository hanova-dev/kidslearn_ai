# 026 — Story complete: save the reading, one star per page, spoken cheer

- **Date:** 2026-11-06 · **Status:** Accepted · **FR:** FR-MODE-06, FR-HCI-06, SRS D6, 10.10

**Context:**
- Design p22 shows "You did it, Fatima!", words read, stars earned, **Next adventure** and **Read it again**.
- Decision 009's star rule (3/2/1 per sentence) needs the scorer, which comes in Week 4. The viewer has no scoring.
- The path map (024) unlocks the next story only when a `reading_sessions` row exists.

**Decision (the team chose on 6 Nov):**
- **"The end" saves the reading** through `StoryFinisher`:
  - one `reading_sessions` row, with mode LISTENER or READER from the child's age group, words read and stars earned;
  - `child_profiles.star_balance` grows by the stars;
  - the active child in memory is updated too, so the path shows the new count at once.
- **One star per page** for now (SRS 10.10, FR-MODE-06: a star on each scene completion). Reader Mode will use decision 009's 3/2/1 rule in Week 4.
- **Reading again saves a new session and gives the stars again.** Stars are never taken away (FR-HCI-06).
- **Celebration:** still confetti and three stars (`CelebrationPainter`), the child's buddy, and the phone's voice saying "You did it, <name>!" once. This gives colour + icon + sound, with no new package.
- The words and stars reach the screen as query parameters: `/story-complete?id=…&words=…&stars=…`.

**Alternatives:**
- 3 stars per story: the same for every story, and not "per scene" like FR-MODE-06.
- Stars only the first time: needs an extra check, and the gain is small at this stage.
- No sound: CLAUDE.md asks for colour + icon + sound in child feedback.

**Consequences:**
- **Emulator (6 Nov):**
  - Sara finished her story: +6 stars, 48 words, a LISTENER session.
  - Ali finished story 2: +6, and **story 3 unlocked by itself**.
  - "Read it again" gave another +6 (12 in total), and the stars were still there after an app restart.
  - The voice said the cheer (logcat). Night mode was checked.
- A child can collect many stars by reading the same short story again. This is accepted for now.
- The hand-inserted test session from 5 Nov (`manual-test-1`) is still on the emulator. Clearing the app's data removes it.
