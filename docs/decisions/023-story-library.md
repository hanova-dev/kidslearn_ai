# 023 — Story library: Home + Library bar, status badges, stopped stories become FAILED

- **Date:** 2026-11-04 · **Status:** Accepted · **FR:** FR-STORY-04, FR-STORY-06, FR-STORY-07

**Context:**
- Design p9 shows a grid of story cards, child chips, a search button and a bottom bar with Home, Library, Progress and Settings.
- Progress (M8) and Settings are not in this semester's scope.
- Before this task, a story that finished after the parent left the generating screen could not be opened again (decision 022).
- If the app is closed while a story is written or drawn, the row stays GENERATING forever, because nothing is running any more.

**Decision (the team chose all four on 4 Nov):**
- **Bottom bar with Home and Library only** (`ParentNavBar`). Progress and Settings will be added when they exist.
- **No search for now.** The child chips (All / Ali / Sara) are enough for a few stories.
- **Five badges** with colour, icon and word: Writing…, Drawing…, Needs check, Approved, Stopped.
- **At app start, DRAFT and GENERATING stories become FAILED** (`failInterruptedStories` in `main.dart`). At start nothing can be running, so these stories were stopped. The parent sees "Stopped" and can tap "Make a new version" or Delete.
- Tapping a card opens the preview. A story still being made opens the Story generating screen instead.
- The preview's Back, Approve and Delete now go to the library, so the parent sees the new badge at once.

**Alternatives:**
- All 4 tabs with "Coming later" screens: two screens that do nothing.
- Only "Ready" like the design: the parent could not see which stories still need a check.
- Leave interrupted stories as GENERATING: the parent could only delete them.

**Consequences:**
- **Emulator (4 Nov):** all the badges worked; the child filter worked; a stopped story got a new version (6 FLUX) and was approved from the library; a force-stopped story became FAILED after restart; Delete removed its rows and its picture file; night mode was checked.
- The cover is the first drawn picture, so the library loads every story's scenes (one query per story). This is fine for tens of stories.
- `main.dart` creates a `SqliteStoryRepository` once at start-up, outside `providers.dart`. This is only for this one clean-up step.
