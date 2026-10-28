# 001 — Fixed buddies with names

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-AUTH-02, FR-STORY-08

**Context:** The Add child design (page 4) shows the buddy as 4 coloured faces with no name. But FR-STORY-08 needs a buddy *name* to put in the story prompt instead of the child's real name.

**Decision:** There are 4 fixed buddies, and each has a colour and a name: Mango (orange), Sky (blue), Leafy (green), Rosy (pink). Only the buddy name is saved in `child_profiles.buddy_name`. Before the prompt is sent to Groq, every whole-word match of the child's real name (any upper or lower case) is replaced with the buddy name.

**Alternatives:** The parent types a free buddy name (more typing, and the parent might type a real name). Buddy is only a colour, with no name (this fails FR-STORY-08).

**Consequences:** The story hero is called by the buddy name, for example "Mango does not want to share". The list of buddies lives in one constants file, so it is easy to change in a viva drill.
