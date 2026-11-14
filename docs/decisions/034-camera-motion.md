# 034 — Motion Comic Engine phase 2: SceneChoreographer and single-layer camera motion

- **Date:** 2026-11-14 · **Status:** Accepted · **FR:** FR-MOTION-04, 05, 06, 10 (draft, `docs/srs_addendum_m11_motion.md`)

**Context:**
- Phase 1 saves one motion directive per page (decision 033). Phase 2 must make the picture move on the phone: offline, calm, and never moving the text. In Text Mode (Reader) the camera must be still while the child reads and is scored. "Remove animations" must give a still scene.
- There is no character layer yet (segmentation is Phase 4), so only the whole picture can move.

**Decision:**
- **`MotionProfile` in each policy** (`lib/policy/motion_profile.dart`): Listener 8,000 ms and zoom up to 1.12; Reader 4,000 ms and zoom up to 1.08. These are the motion tunables.
- **`SceneChoreographer`** (pure Dart, `lib/algorithms/`): directive + profile + text direction + reduce motion → `MotionTimeline` of `CameraKeyframe`s (two per page now). Shifts never pass `(zoom - 1) / 2`, so no edge shows. Smoothstep easing. Right-to-left mirrors left/right pans only; the focus point is not mirrored because the picture is not.
- **One move, then still:** the camera plays once per page and holds the last frame (no looping).
- **`MotionScenePlayer`** widget: `AnimationController` + `AnimatedBuilder` + `FractionalTranslation` + `Transform.scale` inside `RepaintBoundary` and `ClipRect`; only the picture is its child. `settled: true` **stops** the camera where it is (no fast catch-up); Reader Mode sets it when the step leaves `ready`, before the microphone starts.
- Character actions, effects and the cue word are ignored until phases 3–5.

**Alternatives:** finishing the move quickly when the mic is tapped (a fast zoom, against SRS 10); delaying the mic until the move ends (slower for the child); looping the camera back and forth (more motion than needed while listening).

**Consequences:**
- 20 new tests (256 in total). Emulator (14 Nov): Reader page 1 `slow_zoom_in` moved and then stopped; the sentence area did not change (0.0 pixel difference); tapping the mic after about 1 s stopped the camera part way; an old story without motion stayed still.
- Not yet checked on a device: "Remove animations" (widget test only) and smoothness on a 3 GB phone.
- Placeholder pictures also get camera motion (FR-MOTION-11 note).
