# 015 — One child_profiles table; buddies have a fixed animal

- **Date:** 2026-10-27 · **Status:** Accepted · **FR:** FR-AUTH-02, FR-STORY-08

**Context:** SRS 6.2 keeps the child's name and language in a `users` table and the rest in `child_profiles`. Parents live in Firebase Auth, not SQLite, so a local `users` table would hold only children. In the Groq spike, the buddy "Mango" became a monkey because the prompt had no animal.

**Decision:**
- One SQLite table `child_profiles` (child_id, parent_id, name, buddy, age_group, language, star_balance, reading_level, created_at). `parent_id` is the Firebase user ID.
- Times are stored as milliseconds (INTEGER). Age group is stored as `listener_2_4` / `reader_5_7` (from the ER diagram).
- Each buddy has a fixed animal: Mango the fox (orange), Sky the bunny (blue), Leafy the turtle (green), Rosy the kitten (pink). They live in `core/constants/buddies.dart`.
- The database is opened once in `main()` and given to Riverpod with `databaseProvider.overrideWithValue`.
- Repository tests run real SQL on the laptop with `sqflite_common_ffi` (dev dependency only).

**Alternatives:** Follow the SRS with users + child_profiles (two tables and a join for no benefit now). Store buddies in the database (more code, nothing to gain while there are only 4).

**Consequences:** The next SRS version should show one table. The child's real name stays on the phone only. Story prompts will use the buddy's name and animal.
