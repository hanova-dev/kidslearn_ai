# 032 — 12-page stories with a cast, matching pictures and stars by share of words

- **Date:** 2026-11-13 · **Status:** Accepted (replaces the page size of decision 031 and the star rule of decision 009) · **FR:** FR-STORY-02, FR-ILLUS-01, FR-MODE-06, FR-SCORE-07, SRS 10.5, 10.7

**Context:**
- After decision 031 the team still found the stories too short and thin: 6 one-sentence scenes, weak characters, pictures that did not follow the story.
- SRS 10.5 asks for one short sentence per scene and SRS 10.7 for 28–32 sp Listener text.

**Decision (the team chose on 13 Nov):**
- **12 pages, 2–3 sentences each (20–40 words)**, with a 12-step story shape, a playful adventure even for routine topics, speech, 1–2 friends (different animals, fun invented names), and family as the same animal as the hero. Hero stays the child's buddy (FR-STORY-08).
- **Exactly 12 pages:** the schema has a `pages` object with the required keys `page_1` … `page_12` (Groq's docs do not list `minItems`; with a list the model stopped after 2–7 pages). A story with another count is "incomplete".
- **`max_completion_tokens: 6000`**: without it Groq stopped with "max completion tokens reached". Reasoning stays `medium`.
- **Pictures:** the character sheet has one line per character ("The fox: …"); `FluxIllustrator.sheetFor` puts only the lines for animals named in that page's picture prompt before it (the whole sheet for old stories).
- **Screens:** Listener text 24 (below SRS 28–32), Reader text 22, flatter pictures, smaller word gaps, mic limit 45 s.
- **Stars (replaces decision 009):** share of words not TRY_AGAIN: ≥ 90% → 3, ≥ 60% → 2, else 1. The spoken line still comes from the first TRY_AGAIN (else NEAR_MISS) word.

**Alternatives:** 10 or 8 pages; 1–2 sentences per page; warm everyday friend names; a parent-typed hero name; keeping the old star rule (most long pages would give 1 star).

**Consequences:**
- Real checks (13 Nov): 4 stories through the app's generator, all exactly 12 pages, 21–40 words, 8–10 s. In the app, a 12-page story was written and drawn (all FLUX); after `sheetFor`, the fox, baby fox, rabbit and turtle kept their looks and the same meadow on all pages. Evidence in `notes/images/m2_long_stories_2026-11-13/`.
- One story uses about 5,200 Groq tokens (free limit 8,000 per minute) and 12 of about 173 free pictures per day (about 14 new stories a day). Making one takes about a minute.
- A 40-word page is hard for a 5–7 child to read aloud in one go; FLUX still sometimes adds an odd extra animal or a scribble.
- Old 6-scene stories still work; "Make a new version" rewrites them as 12 pages.
