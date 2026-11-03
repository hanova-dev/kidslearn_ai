# 020 — How scenes are drawn: FLUX first, placeholder per scene, READY after pictures

- **Date:** 2026-11-02 · **Status:** Accepted · **FR:** FR-ILLUS-01, 02, 03, 04, 06, FR-STORY-04, NFR-REL-04

**Context:** Each story has 6 scenes to draw. FLUX can fail for a single scene: it can be busy, give a false NSFW alarm (seen in the spike), have no internet, or run out of quota. The SRS says one failed scene must not fail the story (NFR-REL-04), and READY means "all scenes illustrated" (FR-STORY-04). CLAUDE.md says the choice of primary and fallback adapter lives only in `providers.dart`.

**Decision:**
- `providers.dart` has two providers: `illustrationServiceProvider` (FluxIllustrator) and `fallbackIllustrationServiceProvider` (PlaceholderIllustrator). For each scene, the controller tries the first one and uses the second if the first throws.
- `FluxIllustrator` retries 2 times (waiting 1 s, then 2 s) before giving up (FR-ILLUS-04). A wrong key is not retried. The prompt is the style text + "Character: <sheet>" + "Scene: <prompt>", cut to 2048 characters (the API limit).
- Scenes are drawn **one at a time**, in order. This is simpler to explain, it stays inside rate limits, and the screen can show "Drawing scene 3 of 6" (FR-ILLUS-03).
- Pictures are saved as `story_images/<sceneId>.jpg` (FLUX) or `.png` (placeholder) in the app documents folder. The path and the source go into `scenes.image_path` and `scenes.image_source` (FR-ILLUS-02).
- The story becomes READY only after every scene has a picture. This ends the temporary rule in decision 018.
- The story's `seed` is now filled in (from the clock) and passed to `renderScene`. FLUX ignores it (decision 012).
- `StoryCreationController` becomes a `Notifier<StoryCreation>`. The state class holds the step (idle / writing / drawing / ready / failed), the story, its scenes and a message. `AsyncValue` has only 3 states, which is not enough for "writing" vs "drawing scene 3".

**Alternatives:**
- Draw all 6 scenes at the same time: faster, but it hits rate limits and is harder to explain.
- Use one combined "fallback illustrator" class: this adds a class that is not in the SRS diagram.
- Mark a scene FAILED with no picture: the child would then see an empty page.

**Consequences:**
- On the emulator (2 Nov) a story took about 16 s with 6 FLUX pictures.
- With the network cut during drawing, all 6 scenes got placeholders and the story was still READY.
- Each story uses about 350 of the 10,000 free daily neurons.
- Problem seen: FLUX sometimes writes the hero's name ("Mango") on the picture, even though the prompt says "no text". Fixed in decision 021.
- "Retry pictures later" (FR-ILLUS-06) comes with the preview screen.
