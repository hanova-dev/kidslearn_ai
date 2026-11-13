# 031 — Story prompt: one connected story with a clear shape, sentences of 6–15 words

- **Date:** 2026-11-13 · **Status:** Accepted · **FR:** FR-STORY-02, SRS 10.5, CLAUDE.md §8

**Context:**
- The team found the stories weak: six separate captions, not a story (e.g. "Mango sits at dinner, eyes on familiar bowl.").
- Causes in the prompt: one sentence of only 5–12 words per scene, no story shape, friends with no name appearing from nowhere, and `reasoning_effort: low`.
- SRS 10.5 asks for one short sentence per scene, and Reader Mode scores one sentence at a time.

**Decision (the team chose on 13 Nov):**
- Keep **6 scenes, one sentence each**, but a **complete** sentence of **6 to 15** words with common words.
- Give the model a **story shape**: hero → small problem from the request → feeling, someone notices → idea or help → the good thing, which is the lesson itself → happy ending that shows the lesson.
- Joining words (but, so, then, because); at most one short line of speech; a friend with an invented name; family called Mum, Dad, Grandma or baby sister, never by a name.
- `reasoning_effort: medium` so the model plans the story first.

**Alternatives:**
- 8 scenes of 1–2 sentences: richer, but harder for 5–7 readers, longer recordings, 8 pictures per story, and a deviation from SRS 10.5.
- Only raise the word limit: longer captions, still no story.

**Consequences:**
- Checked with real Groq calls through the app's generator (`tool/story_quality_check.dart`, 13 Nov), same four inputs before and after: every new story follows the shape, sentences are 9–13 words, and it takes 3–5 s (timeout 15 s). Outputs saved in `notes/images/m2_story_quality_2026-11-13/`.
- Four calls within a few seconds hit Groq's free per-minute limit; the check tool now waits 20 s between stories. One parent making one story is not affected.
- The story shape lists 6 steps, so changing `scenesPerStory` also needs the shape text changed.
- Old stories keep their old text; the parent can use "Make a new version" (FR-STORY-06).
