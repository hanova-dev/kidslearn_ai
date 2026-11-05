# 025 — Story viewer for both age groups, and read aloud with the phone's voice

- **Date:** 2026-11-05 · **Status:** Accepted · **FR:** FR-MODE-01 (partial), FR-STORY-07, FR-TTS-01, FR-TTS-02, FR-TTS-03

**Context:**
- Decision 006 planned a simple viewer for ages 2–4 only.
- Reader Mode (microphone, ages 5–7) comes in Week 4, so a 5–7 child had nothing to open.
- Design p13 has a speaker button. `flutter_tts` is in the fixed stack, but it was not installed.

**Decision (the team chose on 5 Nov):**
- **Both age groups open the story viewer for now**: picture, sentence in Andika 30, page dots, Previous and Next (88 dp), Back, Home. In Week 4 a policy (`ListenerPolicy` / `ReaderPolicy`) will send 5–7 children to Reader Mode.
- **"The end" on the last page goes back to the path.** Nothing is saved. The Story complete screen (next task) will save the reading session, give stars and unlock the next story.
- **Read aloud:**
  - `flutter_tts: 4.2.5` (MIT, verified publisher), with the TTS `<queries>` entry in AndroidManifest;
  - `TextToSpeechService` + `DeviceTtsNarrator`, chosen in `providers.dart`;
  - speech rate 0.4, slower for children;
  - if the phone has no voice for the language, a message tells the grown-up where to add one (FR-TTS-02).
- The viewer only opens approved READY stories with scenes (FR-STORY-07), even if a path is typed by hand.

**Alternatives:**
- Only 2–4 gets the viewer: a 5–7 child's tap would do nothing until Week 4.
- Save a session at the end: the path would unlock today, but this would mix Story complete into the viewer.
- No read aloud: 2–4 children cannot read the sentence alone.

**Consequences:**
- **Emulator (5 Nov):**
  - Google TTS used an embedded (offline) en-US voice;
  - turning the page or tapping "The end" stopped the voice ("Interrupted: true");
  - day and night mode were checked;
  - a story without pictures shows the scenery.
- The build warns that `flutter_tts` (and `firebase_auth`, `firebase_core`, as before) apply the Kotlin Gradle Plugin. This is only a warning for future Flutter versions, and the build works.
- Clips are not cached to files yet (FR-TTS-01, second part). Karaoke highlighting (FR-TTS-04) stays out of scope.
