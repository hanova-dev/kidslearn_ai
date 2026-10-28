# 002 — A story belongs to one child

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-STORY-01, FR-STORY-07, FR-STORY-08

**Context:** The Create story design has a "FOR: Zayan / Fatima" choice, and the library shows "Zayan · UR". But the SRS `stories` table (Section 6.2) has only `parent_id`. We also need the child to know whose name to replace (FR-STORY-08).

**Decision:** Add a `child_id` column (FK to `child_profiles`) to the `stories` table. The path map shows only approved stories where `child_id` is the active child.

**Alternatives:** Every story is shared by all children (does not match the design). A many-to-many link table (more complex than we need).

**Consequences:** This is a small change from SRS Section 6.2 and Figure 6.1. It is recorded here and must be written into the next SRS version.
