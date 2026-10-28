# 012 — FLUX on Workers AI has no seed and no size choice

- **Date:** 2026-10-26 · **Status:** Accepted (approved by the team 26 Oct 2026) · **FR:** FR-ILLUS-01, FR-ILLUS-05

**Context:** FR-ILLUS-01 says every scene reuses the story's seed, and FR-ILLUS-05 says the parent can choose 512×512 or 1024×1024. The live API rejected `seed` with "Additional or unevaluated properties '/seed' … not allowed". Only `prompt` and `steps` are accepted, and every image comes back as 1024×1024 JPEG. In the spike, the same prompt sent twice gave two different images, but the character still looked the same (orange fox, green scarf, cream belly) because the character sheet was in the prompt.

**Decision:** `FluxIllustrator` sends only the style text + character sheet + scene prompt, with `steps: 4`. The story still saves a `seed` column, so a future adapter that supports seeds (for example `NanoBananaIllustrator`) can use it. FR-ILLUS-05 (a Could-have) is dropped for this adapter.

**Alternatives:** Another FLUX host that accepts a seed (all need a card, SRS 5.5). Another Workers AI image model with a seed (not checked yet, and it changes the SRS model choice).

**Consequences:** Consistency depends on the character sheet only. Each image costs about 58 neurons (4 tiles + 4 steps), so the free 10,000 per day gives about 173 images, about 28 six-scene stories. The next SRS version must update FR-ILLUS-01 and FR-ILLUS-05.
