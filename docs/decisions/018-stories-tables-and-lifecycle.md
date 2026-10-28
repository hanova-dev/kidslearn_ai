# 018 — stories/scenes tables, database version 2, status rules in the enum

- **Date:** 2026-10-28 · **Status:** Accepted · **FR:** FR-STORY-03, FR-STORY-04, FR-STORY-06

**Context:** SRS 6.2 lists `stories` (story_id, parent_id, title, moral_value, language, character_sheet, seed, status, approved, created_at) and `scenes` (scene_id, story_id, sequence_number, text, image_prompt, image_path, image_source). Phones that already have database version 1 must keep their child profiles.

**Decision:**
- `stories` gets 3 extra columns. `child_id` (decision 002), and `prompt_text` + `prompt_value`, so a story can be regenerated from the parent's original words (FR-STORY-06). The title and moral start empty and are filled in by the model.
- Database version 2: `createTables` builds everything on new phones, and `upgradeTables` only adds the story tables when `oldVersion < 2`. Existing rows are kept.
- The lifecycle rules live in `StoryStatus.canMoveTo`:
  - DRAFT → GENERATING / FAILED;
  - GENERATING → READY / FAILED;
  - READY → GENERATING (regenerate);
  - FAILED → GENERATING (retry).
  
  `updateStatus` throws `StateError` on any other move.
- `saveNarrative` writes the title and all scenes in **one transaction**. On regenerate, the old scenes are deleted first.
- Deleting scenes is done by the repository, not by a SQL foreign key, so there is no `PRAGMA` to explain.

**Alternatives:** Drop and re-create the database on upgrade (loses children). Check the status rules in each controller (easy to forget one).

**Consequences:** Verified on the emulator on 28 Oct: the database version went from 1 to 2 and `stories`/`scenes` exist. The upgrade test proves an existing child survives. The next SRS version should list the 3 extra columns.
