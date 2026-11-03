# 021 — Keep the buddy name out of picture prompts, and say "wordless picture"

- **Date:** 2026-11-02 · **Status:** Accepted · **FR:** FR-ILLUS-01

**Context:**
- In the first real FLUX story ("Mango Tries New Food"), 3 of the 6 pictures had writing on them: "Mango" as a big title on two, and a small signature-like scribble on one.
- The name comes from the character sheet that Groq writes ("Mango is a bright orange fox…"). We send that sheet with every scene.
- FLUX schnell has no negative prompt, so "no text" is only a hint.

**Test (2 Nov, direct calls to the real API, same 3 scenes):**
- Old prompt, run again: 0 of 3 with text. The problem is random.
- Name removed: 1 of 6, with a tiny signature in a corner.
- Name removed + new no-writing wording: 0 of 6.

**Decision:**
- `StoryPromptBuilder.imageText` replaces the buddy name with "the <animal>" ("the fox is a bright orange fox…"). The controller uses it on the character sheet and the scene prompt just before drawing.
- SQLite still keeps the original text.
- `FluxIllustrator.styleText` now ends with "A wordless picture: no writing, letters, titles, labels or signatures."

**Alternatives:**
- Ask Groq not to use the name in the sheet. This depends on the model obeying, so it is not guaranteed.
- Change the `IllustrationService` interface to pass the name. That interface comes from the SRS class diagram.

**Consequences:**
- The samples are small, so text may still appear sometimes. The "redraw pictures" option planned with the preview screen is the backup.
- On the emulator (3 Nov), "Mango Tries a New Taste" got 6 FLUX pictures with no writing on any of them. The fox looked the same in every picture (orange, red scarf), and SQLite kept "Mango" in the story text.
