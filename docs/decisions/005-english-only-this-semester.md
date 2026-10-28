# 005 — English only for reading and scoring this semester

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-STORY-01, FR-STT-03, FR-SCORE-05, FR-I18N-*

**Context:** Create story and Add child both have an اردو button. Urdu scoring needs a romanisation table and its own tuned thresholds (SRS 8.1.5), and Urdu RTL layout (M10) is out of scope.

**Decision:** This semester, stories, transcription and scoring are English only. The `language` field stays in the data model and in `PhoneticScorer`'s per-language thresholds. The اردو button is shown but disabled, with a "coming soon" label.

**Alternatives:** Allow Urdu story text without scoring (half a feature, and confusing to demo). Build full Urdu now (not enough time before 2 Dec).

**Consequences:** No Urdu in the demo. The 8th semester adds the romanisation table, Urdu thresholds, the Nastaliq story text and RTL.
