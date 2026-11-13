# 029 — Basic Reader Mode: age policy, whole-sentence reading, colours and the phone's voice

- **Date:** 2026-11-11 · **Status:** Accepted · **FR:** FR-MODE-01, FR-MODE-04, FR-MODE-05, FR-MODE-06, FR-SCORE-07, FR-STT-01, FR-STT-05, FR-HCI-01, FR-HCI-05, SRS 10.6–10.8

**Context:**
- Until now both age groups opened the story viewer (decision 025). SRS 10.6 wants an `AgeExperiencePolicy` with `ListenerPolicy` and `ReaderPolicy`.
- Designs p18–p20: mic, "I'm listening…", coloured words, a feedback line, stars, Read again / Next page.
- Decision 008 planned short sound files, which need one more package (for example `audioplayers`).
- FR-SCORE-06 (practice-word list) has no screen in this semester's list (design p21 is not in CLAUDE.md).

**Decision (the team chose on 10–11 Nov):**
- **Policy:** `lib/policy/age_experience_policy.dart` with `ListenerPolicy` (2–4) and `ReaderPolicy` (5–7): session mode, reads aloud, touch target, text size. `activePolicyProvider` follows the active child. `AppRoutes.openStoryOf(policy, id)` opens `/read` (Reader Mode) or `/story` (viewer).
- **Reading:** the whole sentence at once (decision 004): mic → stop → `ReadingController` → `PhoneticScorer.scoreSentence` → `SentenceCheck`. The mic turns itself off after 20 s and when the screen closes.
- **Feedback:** green / amber / soft coral boxes, a dotted (TRY_AGAIN) or dashed (NEAR_MISS) underline, a banner with an icon, and the **phone's voice** saying "Great reading!", "So close! Listen: shared" or "Let's try that one together: rabbit". **No sound files, no new package** (team choice, 10 Nov). This replaces the sound-file part of decision 008.
- **Stars:** 3/2/1 per sentence from the weakest word (decision 009); the best try of each page counts; saved at "The end" through `StoryFinisher`, which now takes the stars from the screen.
- **Practice words (FR-SCORE-06): left for later** (team choice, 10 Nov), with the Word practice screen.

**Alternatives:**
- `audioplayers` + 3 CC0 sounds: closer to SRS 10.8, but one more package and files to explain.
- Save practice words now in a new table (DB version 4) without a screen: data nobody can see yet.
- `if (child.ageGroup == ...)` in each screen instead of a policy: simpler today, but the rule would be repeated.

**Consequences:**
- 20 new tests (207 in total). **Emulator (11 Nov):** permission dialog; recording; WAV deleted; coloured words in day and night; offline → "Let's read that sentence once more" → phone recogniser; READER session +6 saved; story 3 unlocked the path.
- The emulator hears the laptop speaker very quietly (about 7% of full scale), so **reading accuracy was not judged**. A real voice on the phone is still needed.
- On the emulator, the phone's recogniser needed the internet (no offline English pack) and stopped after about 1 s of silence.
- `reader_screen.dart` is 231 lines, a little above the 200-line aim (224 after ChildScaffold, 13 Nov).
