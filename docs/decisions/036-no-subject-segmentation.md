# 036 — Motion Comic Engine phase 4: subject segmentation not adopted this semester

- **Date:** 2026-11-14 · **Status:** Accepted (team choice, 14 Nov) · **FR:** FR-MOTION-11 (Could-have), NFR-PRIV-06

**Context:**
- Phase 4 was to cut the hero out of each FLUX picture into its own layer, so it could hop or sway on its own. The only free on-device candidate was Google ML Kit Subject Segmentation (`google_mlkit_subject_segmentation` 0.3.2, MIT; native `play-services-mlkit-subject-segmentation` 16.0.0-beta1).
- Known concerns before the test: beta API; the model is downloaded by Google Play services; ML Kit sends usage metrics to Google; its terms say nothing about children's apps.

**Test (14 Nov, throwaway app outside the repository, 24 FLUX pictures, Pixel_7a emulator x86_64):**
- Without help, the model did not download in over 8 minutes ("Waiting for the subject segmentation optional module to be downloaded").
- With an explicit `ModuleInstallClient.installModules` request, the 19.6 MB module downloaded and installed in about 7 s.
- The first `processImage` then crashed the app in Google's native code (SIGSEGV); a second run crashed at once (SIGBUS). No cut-out was produced, so quality, speed and memory are unknown. The emulator log is in `notes/images/m11_segmentation_test_2026-11-14/`.

**Decision:** Do not add ML Kit or any segmentation this semester. M11 keeps one picture layer: camera motion (phase 2), cue-word ease and Lumi (phase 3), and next the effects drawn in code (phase 5). `characterAction` stays in the motion line and the database, unused, so a later layer can use it without a migration.

**Alternatives:** test on a physical phone first (more time before the 23 Nov freeze, and a beta native library could still crash during the live demo); drop segmentation for good (closes the door for M11 later).

**Consequences:** No new package, no Play services download, no data to Google. The hero never moves separately from the background. FR-MOTION-11 stays Could-have, "Not started (deferred)". The app's code and `pubspec.yaml` were not changed by the test.
