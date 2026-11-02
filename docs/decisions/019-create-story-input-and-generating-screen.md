# 019 — Create story input rule and the Story generating screen

- **Date:** 2026-11-02 · **Status:** Accepted (team chose both options on 2 Nov) · **FR:** FR-STORY-01, FR-STORY-03, FR-STORY-04, FR-STORY-05

**Context:** Design p7 says "What should this story teach? … OR PICK A VALUE", but FR-STORY-05 says to reject empty or very short prompts. Design p8 has a Cancel button, but a Groq call cannot be stopped once it has started. Design p8 also shows "Drawing scene 3 of 6" and "Recording narration". Pictures come in M3 (Week 3), and narration is spoken live by device TTS (decision 008).

**Decision:**
- **Valid input:** the parent types text **or** picks a value. If there is text, it must be 15–300 characters (`AppConfig.minPromptLength` / `maxPromptLength`). A value on its own is fine. The check runs before anything is saved or sent (`StoryInputCheck`).
- With only a value, the message to the model has no "Situation:" line.
- **Cancel** becomes **"Back to home"**. The story keeps being written and is saved as READY or FAILED (p8: "You can leave this screen").
- The generating screen shows 2 steps: "Writing the story" and "Drawing the pictures". The drawing step stays grey until M3, and the narration step is left out.
- Until the preview screen exists (task 4), the ready screen shows the title and the lesson.
- `StoryCreationController` is an `AsyncNotifier<Story?>`. Loading means writing, data means ready, and error means failed with a plain message. "Try again" reuses the same story ID and prompt.

**Alternatives:**
- Always require text (closest to FR-STORY-05).
- Keep Cancel and throw the result away (the story would sit as FAILED for no reason).

**Consequences:**
- A value-only story is more generic.
- The controller is not auto-disposed, so leaving the screen does not stop the story.
- For now only the newest story can be retried from this screen. The library (Week 3) will list FAILED stories.
