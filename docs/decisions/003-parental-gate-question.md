# 003 — Parental gate: harder maths question, typed answer

- **Date:** 2026-10-26 · **Status:** Accepted · **FR:** FR-AUTH-04, NFR-SEC-05, SRS D7

**Context:** The SRS says "PIN, pattern or equivalent". The design (page 5) shows "3 + 4 = ?" with 3 buttons. A child can guess the right button 1 time in 3, and a 6-year-old can solve 3 + 4.

**Decision:** We keep the design's layout. The question is a random two-digit number (12–29) plus a one-digit number (6–9), for example 14 + 9. The parent types the answer on a number pad. A wrong answer gives a new question. The gate is a `go_router` redirect, not a button check.

**Alternatives:** A 4-digit PIN (the parent must create and remember it, and needs a "forgot PIN" flow). Keep the 3-button design (too easy to guess).

**Consequences:** This differs a little from the design (number pad instead of 3 buttons). A "Parent PIN" (design page 11) can be added later in the 8th semester.
