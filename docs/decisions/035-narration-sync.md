# 035 — Motion Comic Engine phase 3: narration sync, cue-word camera ease and Lumi's mouth

- **Date:** 2026-11-14 · **Status:** Accepted · **FR:** FR-MOTION-07, FR-MOTION-08 (draft, `docs/srs_addendum_m11_motion.md`), FR-TTS-01

**Context:**
- The brief asks the camera to ease to the focus point when the cue word is spoken, and a narrating mascot whose mouth moves on word boundaries. Before this, `TextToSpeechService.speak` gave no word events.
- flutter_tts 4.2.5 (already in the app) has `setProgressHandler`, fed by Android `onRangeStart` (API 26 = our minSdk). Some voice engines never call it.

**Decision:**
- `TextToSpeechService.speak` gets an optional `onWord` callback; `DeviceTtsNarrator` fills it from `setProgressHandler`. No new package.
- **`NarrationTracker`** (`features/reading/controllers/`) wraps the voice: real word events win; if none came by the time `speak` returns, it plays a **word-length guess** (`WordTiming.estimate`, pure Dart) with Timers and cancels the guess at the first real word.
- `WordTiming` constants measured on the emulator voice at rate 0.4 (27 words): 20 ms per word + 80 ms per letter (mean error about 108 ms per word), comma +400 ms. Full-stop pause 600 ms is not measured yet.
- **Mouth:** open 200 ms per word, at most once per 340 ms (≤ about 3 per second, NFR-USE-06). **Mascot = Lumi** (the app's guide, SRS 10), shown in the story viewer's `ChildScaffold` `topCentre` slot (empty before); drawn in code (`mouthOpen` in `LumiMascot`).
- **Cue ease:** the first time the cue word is heard on a page, `MotionScenePlayer` builds `SceneChoreographer.cueTimelineFor(currentFrame, …)` and eases to the focus frame in `MotionProfile.cueMs` (1,500 ms). Ignored when `settled` (Reader Mode) and still with "Remove animations".
- Story viewer (ages 2–4) only. Reader Mode does not narrate pages, so it is unchanged.

**Alternatives:** the child's buddy as narrator (the buddy appears on the path map, but Lumi is the guide character in the designs); guess-only timing (simpler but wrong whenever the voice speed differs); a mouth that toggles on every word (could exceed 3 changes per second).

**Consequences:**
- 18 new tests (274 in total). Emulator (14 Nov): Lumi's mouth opened while reading aloud; on a new 12-page story, page 6 (`pan_up`, focus right, cue "owl") stayed still until about "owl", then eased right in about 1.5 s; the text never changed.
- The word-length guess is only unit-tested: the emulator voice reports words. Real phones may differ.
- `story_viewer_screen.dart` is now 218 lines (aim < 200).
- Lumi in the viewer's top bar is a small design addition (designs p13 have no mascot there).
