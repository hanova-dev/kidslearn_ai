# 006 — Simple story viewer for ages 2–4

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-MODE-01 (partial)

**Context:** Listener Mode (narration and karaoke, design p13) is out of scope. But a 2–4 child can still be picked and can tap a story on the path map. SRS Week 3 mentions a "story viewer", which is not in CLAUDE.md's screen list.

**Decision:** A 2–4 child opens a simple story viewer: the scene image, the sentence in Andika, and a big Next button (64 dp). There is no mic and no scoring. This is chosen by the age group (`ListenerPolicy` vs `ReaderPolicy`).

**Alternatives:** Block 2–4 children with a "coming soon" screen (demo dead end). Reuse the Reader screen without the mic (mixes two modes in one screen).

**Consequences:** One extra small screen. In the 8th semester it grows into the full Listener player.
