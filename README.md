# KidsLearn AI

Bilingual comic storyteller and adaptive speech tutor for children aged 2–7.
Final Year Project, BS Software Engineering, COMSATS University Islamabad, Attock Campus.
Team: Muhammad Abdul Hanan, Abdul Wahab. Supervisor: Ms. Anum Moin.

## Run
1. Copy `env/dev.example.json` to `env/dev.json` and add your free Groq and Cloudflare keys.
2. Start an emulator or connect an Android phone (USB debugging on).
3. Run:
   ```
   flutter run --dart-define-from-file=env/dev.json
   ```

## Check
```
flutter analyze
flutter test
```

## Spike scripts (API checks)
```
dart run tool/groq_story_test.dart
dart run tool/flux_image_test.dart
dart run tool/whisper_test.dart
```

## Records
- Progress per requirement: `PROGRESS.md`
- Decisions: `docs/decisions/`
- Font licences (SIL OFL): `assets/fonts/licenses/`
