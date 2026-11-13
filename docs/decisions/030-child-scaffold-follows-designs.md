# 030 — ChildScaffold: fixed Back and Home, top-right slot as in the designs (no Help button)

- **Date:** 2026-11-13 · **Status:** Accepted · **FR:** FR-HCI-04, SRS 10.9, D5

**Context:**
- SRS 10.9: Back always top-left, Home always bottom-centre, **Help** (replay instructions) always top-right. D5: a shared `ChildScaffold` owns these slots.
- The designs put other things top-right: the read-aloud speaker (story viewer, p13), the star count (Reader Mode, p18). The path map has nothing there.
- Each child screen placed its own Back and Home.

**Decision (the team chose on 13 Nov):**
- `lib/core/widgets/child_scaffold.dart`: Back top-left and Home bottom-centre are fixed; a screen gives `onBack`, `body`, and optionally `topCentre`, `topRight` and `scenery`.
- **Follow the designs:** no separate Help button. Top-right is the speaker (viewer), the star count (Reader Mode) or empty (path map).
- Used by the path map, the story viewer and Reader Mode. `PathTopBar` was deleted. Who's reading and Story complete have no Back/Home in the designs and keep their own layout.

**Alternatives:**
- Follow SRS 10.9 exactly: a Help button top-right on every child screen, the Reader star count moved to the middle. Closer to FR-HCI-03, but changes the designs and adds instruction audio for every screen.
- Leave each screen as it was: no guarantee that Back and Home stay in place.

**Consequences:**
- 3 new widget tests (210 in total). **Emulator (13 Nov):** Back at (126, 223) and Home at (540, 2211) on all three screens; Back now also shows while a story is loading or cannot be opened.
- FR-HCI-03 (an audio cue for every instruction) is only partly met: Reader Mode speaks its feedback and problems, the viewer reads the sentence, but there is no Help replay.
