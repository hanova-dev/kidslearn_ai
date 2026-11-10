# 008 — Device voice and small sounds for Reader feedback

- **Date:** 2026-10-26 · **Status:** Accepted; the sound-file part is replaced by decision 029 (team choice, 10 Nov) · **FR:** FR-SCORE-07, FR-HCI-05, SRS 10.8

**Context:** The rules need colour + icon + **sound** for every feedback state. Design p18 needs "So close! Listen: 'shared'", which means a voice. Narration (M7) is out of scope.

**Decision:** Use `DeviceTtsNarrator` (`flutter_tts`, already in the stack) only for short Reader prompts and the model pronunciation of a word. Add 2–3 short CC0 (public-domain) sound files: correct, so-close and try-again.

**Alternatives:** No sound (breaks the rule). Full narration now (that is M7, out of scope).

**Consequences:** Playing sound files needs one more package (for example `audioplayers`). We will ask before adding it, when Reader Mode is built in Week 4.

**Update 11 Nov:** the team chose **voice only** for now (decision 029). No sound files and no `audioplayers`: the phone's voice says the feedback.
