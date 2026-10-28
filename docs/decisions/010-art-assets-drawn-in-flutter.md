# 010 — Mascot, buddies and placeholders drawn in Flutter

- **Date:** 2026-10-26 · **Status:** Accepted (until we get the original design files) · **FR:** FR-ILLUS-06

**Context:** We need the Lumi fox mascot, the 4 buddy faces and placeholder scene images (FR-ILLUS-06). We do not have the original design source files.

**Decision:** Buddy faces are coloured circles with a simple smile, drawn with Flutter widgets. Lumi and the placeholder scene (sky, sun, hills) are simple drawings made with `CustomPaint`. `PlaceholderIllustrator` saves the placeholder scene as a PNG file, so a scene always has an `image_path`.

**Alternatives:** Export images from the PDF (low quality, and the licence is unclear). Add `flutter_svg` (a new package).

**Consequences:** No new package and no licence questions. If the original art files appear later, we swap in PNG assets.
