# 022 — Story preview: one list, a new version replaces the old one, shared SceneDrawer

- **Date:** 2026-11-03 · **Status:** Accepted · **FR:** FR-STORY-06, FR-STORY-07, FR-ILLUS-06

**Context:**
- No design page shows the Story preview (decision 011 says: build it in the same style).
- FR-STORY-06 says "regenerate from the same prompt", but it does not say what happens to the old version.
- Drawing a scene is now needed in three places: a new story, a new version, and "draw pictures again".

**Decision (the team chose the first two on 3 Nov):**
- **One scrolling list:** every scene shows its picture and sentence, and the buttons are fixed at the bottom (Approve for <child>, Make a new version, Delete story).
- **A new version replaces the old one:** the same story row and the same saved prompt get new text and new pictures. The old picture files are deleted, and `approved` goes back to false, so the parent must approve again.
- **Delete** removes the story row, its scenes and its picture files, after a confirm dialog. "Make a new version" asks first too.
- **Draw pictures again** tries FLUX only for scenes whose `image_source` is PLACEHOLDER. When the new file has a different name (`.jpg` instead of `.png`), the old file is removed.
- **`SceneDrawer`** (with `sceneDrawerProvider`) holds "keep the name out → FLUX → placeholder → save file → save path". Both controllers use it.
- **The route is `/story-preview?id=<storyId>`.** The id is a query parameter, so the parental gate's exact-path check still covers it.
- **The Story generating screen** gets a "Preview story" button, and its top part now scrolls, so the buttons never overflow on small phones.

**Alternatives:**
- Swipe page by page, like the reader: this needs more code (PageView and page dots).
- Keep both versions: the library would fill with near-copies.
- Copy the drawing code into each controller: the same logic would live in two places.

**Consequences:**
- On the emulator (3 Nov) all four actions worked.
- A story that finishes after the parent leaves the generating screen can't be opened until the Story library exists (the next task).
- With the emulator's network cut, one test failed fast (16 s for 4 scenes). Another hung, at about 48 s per scene (3 tries × 15 s timeout). A weak connection can make the simple pictures slow to appear.
