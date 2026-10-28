# 013 — Groq story uses strict JSON schema and low reasoning

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-STORY-02

**Context:** FR-STORY-02 needs a structured result: title, moral, character sheet and scenes. A free-text answer would need fragile parsing. The free tier for `openai/gpt-oss-120b` allows only 8,000 tokens per minute.

**Decision:** Send `response_format: json_schema` with `strict: true` (every field is in `required`, and `additionalProperties: false`). Also send `reasoning_effort: "low"`. The spike story used 706 tokens in total (81 of them for reasoning) and took 1.6 s.

**Alternatives:** JSON object mode (valid JSON, but no schema check). Plain text plus our own parser (breaks easily).

**Consequences:** `GroqStoryGenerator` can parse the reply with `jsonDecode` and our own `fromMap`. Streaming is not possible with structured outputs, which is fine because the generating screen shows steps, not live text.
