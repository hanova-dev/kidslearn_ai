# 033 — Motion Comic Engine phase 1: motion line per page, parser, scenes.motion_json, low reasoning

- **Date:** 2026-11-14 · **Status:** Accepted · **FR:** FR-MOTION-01, 02, 03 (draft, `docs/srs_addendum_m11_motion.md`), FR-STORY-02

**Context:**
- The team asked for a Motion Comic Engine (new module M11): pages that move like a short cartoon, rendered on the phone, offline, at zero cost. Phase 1 = directives, parser, schema and migration.
- The brief asked the story model to return a `motion` JSON object per scene. Groq's free tier allows 8,000 tokens per minute and counts prompt + `max_completion_tokens`.

**Decision (the team chose on 14 Nov):**
- **Closed vocabulary** in `MotionDirective` (camera, focus, character action, effect, mood) plus a cue word.
- **One motion line per page** (`"pan_left right hop rain surprised ball"`), a plain string in the schema; the word lists are in the prompt once. Measured: object with `enum` 3,775 prompt tokens (refused at 9,522 requested); `$defs` no change; plain object fields 2,550; **line 1,740**.
- **`MotionDirectiveParser`** (pure Dart): splits the line, keeps only vocabulary words, fills the rest from mood defaults, checks the cue word is on the page, never throws.
- **SQLite version 4:** `ALTER TABLE scenes ADD COLUMN motion_json TEXT`; NULL (old stories) reads as calm. Firestore sync waits for M9 (decision 007).
- **Story model `reasoning_effort: low`, `max_completion_tokens: 5000`** (in `AppConfig`): with medium about one story in nine ran past 6,000 answer tokens and failed; low answered in about 3 s with about 1,200 tokens and kept the 12-page shape. The prompt now asks to use the hero's name on page 1 and often after.

**Alternatives:** motion as a JSON object with low reasoning; a smaller answer limit only (one test story used 5,391); a second request just for motion (double free-tier use and wait).

**Consequences:**
- 19 new tests (236 in total). Real checks (14 Nov): 4 stories through the app's generator, all 12 pages with 12 motions, about 3.2 s each; emulator database 3 → 4 kept 10 stories and 66 scenes; a new version made in the app saved valid motion on all 12 pages.
- The closed vocabulary is enforced by our parser, not by Groq. Wrong words in a line become defaults (seen in tests with low reasoning: e.g. mood "worried" → default).
- Low reasoning is a change from decision 031 (medium); story quality was compared by eye on 3 stories only.
- Nothing moves on screen yet; Phase 2 adds the choreographer and the player.
