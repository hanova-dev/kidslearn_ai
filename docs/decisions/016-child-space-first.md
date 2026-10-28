# 016 — App opens in child space; parent area unlocked only in memory

- **Date:** 2026-10-27 · **Status:** Accepted · **FR:** FR-AUTH-04, FR-AUTH-05, NFR-SEC-05, SRS D7

**Context:** SRS D7 says the parental gate must be a **route guard, not a button**. On a shared phone a child may close and reopen the app, so restarting must never skip the gate.

**Decision:**
- A signed-in parent's app **always starts on Who's reading** (child space).
- `parentUnlockProvider` (a Riverpod `Notifier<bool>`) is `false` at every start. It becomes `true` after log in / sign up (the password proves it is the parent) or after a correct gate answer. It becomes `false` again on "Go to child mode" and on log out.
- The go_router `redirect` sends `/parent` and `/add-child` to `/gate` while locked. The "Grown-ups" button simply goes to `/parent`, so the router does the guarding.
- The unlock is **not saved** to disk, so a restart always locks.
- All widget tests run at phone size (360 × 800 dp), which found and fixed 4 text overflows.

**Alternatives:** Save "parent mode" in SQLite (a restart could reopen parent screens for a child). Check the gate inside each parent screen (easy to forget one; breaks D7).

**Consequences:** Parents answer one sum each time they open the parent area from child space. The 8th-semester Listener route graph (D1) will plug into the same redirect.
