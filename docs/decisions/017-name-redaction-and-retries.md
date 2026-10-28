# 017 — Name redaction rules and story-call retries

- **Date:** 2026-10-28 · **Status:** Accepted · **FR:** FR-STORY-02, FR-STORY-08, NFR-REL-02, NFR-USE-03

**Context:** FR-STORY-08 says no real name may reach the language model. Parents type freely ("Zayan's sister", "zayan", "Fatima Khan"). NFR-REL-02 asks for a bounded timeout and retries.

**Decision:**
- `StoryPromptBuilder.redactName` replaces the **full name and each part of 2+ letters**, as **whole words** (`\b…\b`) and **ignoring case**. So "Zayan's" becomes "Mango's", and "Zayana" is left alone.
- `GroqStoryGenerator` only ever receives a `StoryPrompt`, which is built by the builder and is already redacted.
- The prompt names the hero as "Mango the fox" (the buddy's fixed animal, decision 015).
- Groq calls time out after 15 s and are retried up to 2 times (waiting 1 s, then 2 s), but only for timeouts, no internet, 429 and 5xx. A 401/400 is not retried.
- Every failure becomes a `StoryGenerationFailure` with a plain sentence.

**Alternatives:** Ask the parent to never type the name (cannot be enforced). Send the real name and trust the provider (breaks FR-STORY-08 and NFR-PRIV-05).

**Consequences:** Nicknames that differ from the saved name (e.g. "Zayu") are not caught. The parent preview (FR-STORY-07) is the last check. The real-call check (`tool/story_service_check.dart`) on 28 Oct returned a 6-scene fox story in 2.5 s.
