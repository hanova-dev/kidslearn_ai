# 007 — SQLite only for app data this semester

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-SYNC-01 (spirit), FR-AUTH-06

**Context:** SyncEngine (M9) is out of scope. Writing to Firestore without the SyncEngine would mean half-built sync code that we must still explain.

**Decision:** Child profiles, stories, scenes, sessions, scores and practice words are saved in SQLite only. Firebase is used only for **Auth** (sign-up, login, and the saved session for FR-AUTH-06). `cloud_firestore` is not added this semester.

**Alternatives:** Write to SQLite + Firestore with no conflict handling (extra code, data can disagree). Firestore only (breaks offline-first).

**Consequences:** If the app is uninstalled, local data is lost. This is acceptable for the demo phone. The `data/remote/` folder stays empty until the 8th semester.
