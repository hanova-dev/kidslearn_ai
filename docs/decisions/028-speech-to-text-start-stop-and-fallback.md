# 028 — Speech-to-text: start/stop interface, Whisper first, phone recogniser after a failure

- **Date:** 2026-11-10 · **Status:** Accepted · **FR:** FR-STT-01..07, NFR-PRIV-01, NFR-REL-05, SRS Figure 7.2

**Context:**
- Figure 7.2 has `SpeechToTextService.transcribe(audio, language)`, and both adapters implement it.
- On Android, the phone's recogniser (`speech_to_text`) listens to the microphone **itself**. It cannot transcribe a file we recorded, and Android cannot record and recognise at the same time (package README).
- So one `transcribe(audio)` method cannot work for `DeviceSpeechRecognizer`. This is a deviation from Figure 7.2.

**Decision (the team chose on 10 Nov):**
- **Packages:** `record: 7.1.2` and `speech_to_text: 7.5.0` (both BSD-3, verified publishers), pinned. `RECORD_AUDIO` and the `RecognitionService` query are in AndroidManifest.xml.
- **Interface:** `SpeechToTextService` has `startListening(language)`, `stopListening()` → `TranscriptResult` (text + source), and `cancel()`. Problems are a `SpeechFailure` with a plain message; `serviceDown` says whether the service itself is unavailable.
- **GroqWhisperTranscriber:** records a 16 kHz mono WAV into the temporary folder (through `VoiceRecorder` / `DeviceVoiceRecorder`), then `transcribe(path, language)` sends it as one multipart request (model, language, `json`, temperature 0). The file is deleted in a `finally`, after success **and** after failure (FR-STT-04). No retries: a busy, offline or broken Whisper switches to the phone instead.
- **The switch** (`SpeechToTextWithFallback`, chosen in `providers.dart`): Whisper first. When Whisper fails with `serviceDown`, the child hears "Let's read that sentence once more." and from then on the phone recogniser is used until the app is closed (FR-STT-07). "We didn't hear anything" does not switch.
- We do **not** send the story sentence as Whisper's `prompt`, because it would push Whisper to "correct" the child's mistakes (SRS 8.1.6).

**Alternatives:**
- A test request before every sentence: the child never reads twice, but every sentence costs an extra request and wait.
- Keep `transcribe(audio)` for Whisper only: then the fallback would not fit the interface.
- Keep the audio in memory only: no temporary file, but we would have to build the WAV header by hand.

**Consequences:**
- 15 tests (mocked Groq, a fake recorder, fake services). One real Whisper call through `GroqWhisperTranscriber.transcribe` (`tool/whisper_transcriber_check.dart`, 10 Nov): word-perfect in 2.1 s, and the file was deleted. The debug APK builds with both plugins.
- **Not tested on a device yet:** recording, permission and the phone recogniser need the Reader Mode screen (next task). For the offline demo, the phone needs the Google app's **offline English** speech pack.
- Whisper may write a few words (for example "Thank you.") for a silent recording; the scorer then marks the words TRY_AGAIN.
- After a switch, Whisper is tried again only when the app is opened again.
