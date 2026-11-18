# 038 — Motion Comic Engine phase 6: effects off on a slow phone, viewer split, offline test

- **Date:** 2026-11-18 · **Status:** Accepted · **FR:** FR-MOTION-12, NFR-PERF-05 (draft, `docs/srs_addendum_m11_motion.md`), FR-STT-07

**Context:**
- FR-MOTION-12: if frames drop on a low-end device, turn off ambient effects first, then the character layer, and keep camera motion. We have no character layer (decision 036).
- `story_viewer_screen.dart` was 218 lines (aim < 200). An offline end-to-end check of M11 was still open.

**Decision:**
- Pure-Dart **`FrameDropDetector`**: a frame is slow above 33 ms (build + raster); 6 slow frames among the latest 60 trips it, once.
- **`EffectsSwitch`** (`Notifier<bool>`, `effectsAllowedProvider`, not autoDispose): `turnOff()` hides effects on every page until the app restarts; the camera keeps moving.
- `AmbientEffectLayer` feeds the detector from `SchedulerBinding.addTimingsCallback`, only while its ticker runs, and calls `onTooSlow`; `MotionScenePlayer` (now a `ConsumerStatefulWidget`) turns the switch off and watches it.
- The viewer's picture and sentence moved unchanged into `viewer_page.dart`; the screen is 177 lines.

**Alternatives:** turn effects back on after some fast seconds (could flicker on a borderline phone); fewer particles instead of none (more code, harder to explain); measure the FPS of the ticker (does not see raster time).

**Consequences:**
- 7 new tests (294 in total), including a widget test that feeds slow `FrameTiming`s through `onReportTimings`.
- Pixel 7, debug build (18 Nov): 1 slow frame in 5,124 while rain and butterflies played, so no false switch-off. The switch has not been seen on a really slow phone.
- Offline on the Pixel 7 (airplane mode, app restarted): pictures, camera, rain, Read aloud (built-in voice) and Lumi's mouth worked; Reader Mode said "Let's read that sentence once more." after Whisper failed, then scored the second try with the phone's recogniser.
