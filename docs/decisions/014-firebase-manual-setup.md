# 014 — Firebase connected by hand; sign-in behind AuthRepository

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-AUTH-01, FR-AUTH-03, FR-AUTH-06

**Context:** We need Firebase Auth on Android only, with code we can explain. Firebase's docs suggest the FlutterFire CLI, which needs Node.js tools and generates `lib/firebase_options.dart`.

**Decision:**
- Project `kidslearn-ai-3f309` on the Spark plan. Email/Password sign-in is on; Google Analytics is off (unlinked).
- The Android app `pk.edu.comsats.kidslearn_ai` is registered. `android/app/google-services.json` is committed (private repo, CLAUDE.md §8).
- The Gradle plugin `com.google.gms.google-services` 4.5.0 is added by hand. `Firebase.initializeApp()` runs with no options.
- Screens use the `AuthRepository` interface, and only `FirebaseAuthRepository` imports `firebase_auth`. Its error codes become plain sentences (`AuthFailure`).
- `android/gradle.properties` has `kotlin.incremental=false`, because the project (D:) and the pub cache (C:) are on different drives.

**Alternatives:** FlutterFire CLI (more tools, a generated file). Calling FirebaseAuth inside screens (breaks NFR-MAINT-01 and makes testing hard).

**Consequences:** Tests use `FakeAuthRepository` with no network. iOS would need its own config file later. Android builds are a little slower without the Kotlin incremental cache.
