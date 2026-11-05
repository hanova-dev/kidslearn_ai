# 024 — Path map: linear unlocking from a reading_sessions table

- **Date:** 2026-11-05 · **Status:** Accepted · **FR:** FR-MODE-01 (screen), FR-STORY-07, SRS D1, D6, 10.10

**Context:**
- Design p15 shows numbered circles on a winding path: finished (green, stars), the next one (big, "Tap to play!") and locked ones, plus world names, a star count and a sound button.
- SRS 10.10: completing a story unlocks the next node.
- Nothing records finished readings yet; Reader Mode and Story complete come in Week 4.
- SRS 6.2 keeps finished readings in `reading_sessions`, not in `stories`.

**Decision (the team chose on 5 Nov):**
- **Linear unlocking.** The active child's approved READY stories, oldest first, are numbered from the bottom. A finished story is green and stays open, the first unfinished one is current, and the rest are locked (`buildPathNodes`).
- **Database version 3 adds `reading_sessions`** with the SRS 6.2 columns. The sync columns (`local_version`, `device_id`, `sync_state`) get simple defaults until the SyncEngine (M9). A story is finished when this child has a session for it. The Story complete screen will write these rows.
- **No world names** for now, only numbered circles.
- **Top bar: Back and the star count** (`star_balance`, 0 until rewards exist). There is no sound button and no stars under the circles yet.
- Tapping a circle shows a short message until the story viewer exists (next task).

**Alternatives:**
- A `completed` column on `stories`: simpler, but against SRS 6.2, and Reader Mode needs `reading_sessions` anyway.
- All circles open for now: no locks, so the screen would change twice.

**Consequences:**
- **Emulator (5 Nov):** the database upgraded from 2 to 3 and kept all 9 stories. Ali's path showed 1 circle, then 3 after approving 2 stories in the parent area. A hand-inserted test session made story 1 green and story 2 current. Locked, current and finished taps gave the right messages. Night mode was checked, and Sara's path shows her own buddy.
- Until Story complete writes sessions, a child can only open the first unfinished story.
