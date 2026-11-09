# 027 — PhoneticScorer: our own Double Metaphone subset, word alignment and thresholds

- **Date:** 2026-11-09 · **Status:** Accepted · **FR:** FR-SCORE-01..05, FR-SCORE-08, NFR-PERF-01, SRS 8.1

**Context:**
- SRS 8.1 needs Double Metaphone + Levenshtein + per-language thresholds, plus word alignment (8.1.6).
- pub.dev has one Double Metaphone package, `dart_phonetics 1.0.1` (Apache-2.0, last update June 2021, a 937-line file).
- CLAUDE.md: code we can explain is more important than more features.

**Decision (the team chose on 9 Nov):**
- **Our own Double Metaphone subset** (`algorithms/double_metaphone.dart`), primary code only. The rules:
  - silent KN, GN, PN, WR at the start; WH → W; X at the start → S;
  - a first vowel → A, other vowels dropped; double letters count once;
  - PH → F; GH silent (K at the start); CH, SH, TIO, SIA → X; TH → 0; CK → K;
  - C → S before E/I/Y, else K; G → J before E/I/Y, else K; DGE → J;
  - B → P (silent after M at the end); V → F; Q → K; X → KS; Z → S;
  - H, W, Y count only before a vowel.
- **Class names from Figure 7.2:** `PhoneticScorer` (`thresholds`, `scoreSentence`, `score`, and the private `alignWords`, `toDoubleMetaphone`, `levenshteinDistance`), `ScoreResult`, `Verdict`, `WordPair`. The steps sit in small helper files (`levenshtein.dart`, `double_metaphone.dart`, `word_aligner.dart`), as the CLAUDE.md folder plan says, so each one has its own tests.
- **Thresholds (SRS 8.1.3):** CORRECT from 0.80 (en) and 0.72 (ur); NEAR_MISS from 0.25 below that (en 0.55, ur 0.47); unknown language → English. They are a constructor value, so they can be tuned without changing the code.
- **Alignment:** two words match when their similarity reaches the NEAR_MISS cut. A skipped word is TRY_AGAIN with similarity 0; extra and repeated words are ignored.

**Alternatives:**
- `dart_phonetics`: it has the full rule set, but it is 5 years old and 937 lines we could not explain in the viva.
- Exact word match: gives no "near miss" signal (SRS 8.1.1).

**Consequences:**
- 42 unit tests, written before the code. One long sentence takes 0.75 ms on the laptop (`tool/scorer_speed_check.dart`), against a 300 ms limit. The phone has not been measured yet.
- Our codes are not always the same as full Double Metaphone (for example, "laugh" → L, not LF). Both words go through the same rules, so the comparison stays fair.
- **Short words are strict:** "red" read as "wed" is RT vs WT, similarity 0.50 → TRY_AGAIN. This follows the SRS formula; the thresholds are to be tuned with real children's recordings (SRS 8.1.5).
- Not done yet: Urdu romanisation (SRS 8.1.5, Urdu is out of scope this semester), number words ("3" vs "three"), the practice-word list (FR-SCORE-06) and the colours on screen (FR-SCORE-07). The last two come with Reader Mode.
