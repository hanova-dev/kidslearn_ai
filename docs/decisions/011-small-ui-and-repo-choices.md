# 011 — Small UI and repository choices

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-AUTH-01, FR-AUTH-03, SRS 10.7, 10.11

**Context:** Some parts of the designs are out of scope or missing, and some values in the SRS do not agree.

**Decision:**
- Log in: hide "Continue with Google". "Forgot password" uses Firebase's free reset email.
- Parent home bottom bar: Home and Library work. Progress and Settings show "coming soon".
- The profile icon on Parent home opens: Add a reader, Go to child mode, Log out.
- Story generating: show only "Writing the story" and "Drawing scene X of 6" (no "Recording narration").
- Story preview/approve has no design. We build it in the same style: scene list, Approve, Regenerate, Delete.
- Theme follows the phone's day/night setting. Extra tokens `border` and `inkMuted` are taken from the designs.
- Child touch targets: 64 dp (2–4) and 56 dp (5–7), from SRS 10.7. These override the 48 dp in SRS 4.1.
- The git repository root is `kidslearn_ai/`. CLAUDE.md, `docs/` (SRS) and `notes/` stay outside it.

**Consequences:** No out-of-scope features in the demo, but every design screen we build still matches its page.
