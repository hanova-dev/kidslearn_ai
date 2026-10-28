# 004 — Reader Mode scores the whole sentence at once

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-STT-06, FR-MODE-04, FR-MODE-05, FR-SCORE-08

**Context:** Designs p18–19 look like the child reads word by word ("Tap and read 'her'"), with words lighting up while the child speaks. FR-STT-06 says one *sentence* per request. Groq Whisper takes a finished audio file, so it cannot follow the child live.

**Decision:** The child taps the mic, reads the whole sentence and taps stop. The audio goes to Whisper. Then `PhoneticScorer` aligns and scores all the words, and they are all coloured at the same time (as in design p20). While recording, the screen shows "I'm listening…" (p19).

**Alternatives:** Word-by-word requests (breaks the free-tier per-minute limit and FR-STT-06). Live tracking with the device recogniser (two different code paths, hard to explain).

**Consequences:** It is simpler and matches the SRS. The design's word-by-word cursor (p18) is not built.
