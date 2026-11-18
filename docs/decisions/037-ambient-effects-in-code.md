# 037 — Motion Comic Engine phase 5: ambient effects drawn in code

- **Date:** 2026-11-18 · **Status:** Accepted · **FR:** FR-MOTION-09 (draft, `docs/srs_addendum_m11_motion.md`), FR-MOTION-05, FR-MOTION-06, NFR-USE-06

**Context:**
- Every motion line has an `effect` word from a closed list: none, falling_leaves, rain, snow, stars_twinkle, sparkles, bubbles, butterflies. Until now nothing drew it.
- Rules from the brief: zero cost, no network during playback, no flashing at 3 or more times a second, text never moves, a still scene under "Remove animations", no new package without asking.

**Decision:**
- Pure-Dart **`AmbientEffect`** (`lib/algorithms/`) gives the place, size, opacity and tilt of each particle at a moment: `progress = (ms / cycleMs + phase) % 1.0`, seeded with `Random(7)` so a page always looks the same. Cycle times are tunables in one map (rain 1.6 s … snow 10 s; stars glow every 3 s; wings beat 1.5 per second).
- **`AmbientEffectPainter`** (a `CustomPainter`) draws the particles as ovals, lines, rings and star paths in `AppColors`; **`AmbientEffectLayer`** runs a `Ticker` and a `ValueNotifier` clock (`repaint:`), with `IgnorePointer` and `RepaintBoundary`.
- `MotionScenePlayer` puts the layer over the picture in a `Stack(fit: StackFit.expand)` inside its `ClipRect`. No layer for `none`, unknown words or "Remove animations". In Reader Mode the layer freezes when the microphone starts (`settled`).
- `MotionProfile.effectCount`: 16 particles for ages 2–4, 10 for ages 5–7.

**Alternatives:** `lottie` (MIT) with licensed animation files (a new package, licences for each asset, harder to explain); hiding the effect in Reader Mode while reading instead of freezing it (also fine; freezing matches the camera).

**Consequences:**
- No new package, no image files, no network. 13 new tests (287 in total).
- Emulator (18 Nov): rain fell over the page 5 picture only; the text area did not change between two screenshots. The same check found a bug, now fixed: without `StackFit.expand` the square picture did not fill the wide box. A widget test now covers it.
- Pixel 7 (18 Nov, Reader Mode, new 12-page story): pictures fill their box; bubbles (page 4) and butterflies (page 5) drawn over the picture only; after reading, two screenshots 1 s apart had 0 changed pixels in the picture (frozen). The first butterflies looked like two dots, so they were redrawn with upper and lower wings and a body; the new drawing is checked only in a full-size preview, not yet on the phone.
- Not checked on a device: "Remove animations" (widget test only). Frame rate on a low-end phone is not measured (FR-MOTION-12, phase 6).
