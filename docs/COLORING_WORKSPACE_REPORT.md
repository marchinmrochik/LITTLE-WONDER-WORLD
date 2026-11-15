# Coloring workspace, source 0.31.0

The coloring paper now occupies the available height with navigation on the left, a two-column palette and tools on the right, and a compact footer. The authored illustration bounds determine display zoom; the image is never stretched. Screen touches map back into the original 1024 x 640 source coordinates. The optional color reference remains available without modifying the drawing.

All ten pages use stronger outlines and eye highlights where applicable. The fox has rounded cheek patches instead of angular straps across its face. This is an incremental cleanup of the existing vector artwork, not a complete replacement illustration collection.

## Saved artwork compatibility

`coloring_legacy.json` retains the original ten templates. Nonblank legacy drafts and gallery states keep their original artwork revision and render identical pixels. Blank legacy pages use the new artwork. New states explicitly store art_revision 2; old states without the field mean revision 1. Unknown revisions are rejected. Existing PNGs are never rewritten by this change. Export remains 1024 x 640.

## Validation

- Coloring: 1820 checks, no failures.
- Native layout and compatibility: 146 checks, no failures; eight captures across EN/UK and 1024x768, 1280x800, 1280x600, 1600x740. Covers real source-coordinate touch routing, visible controls, paper size, all ten legacy pixel comparisons and JSON reloads.
- Gallery/reference: 177 checks, 12 native captures; drawing: 596; word drawing: 1545; release: 2259. All passed. Python: 27 tests passed. Content: 27 JSON documents, 708 locale keys, 947 resource references; no errors. Speech pack: 710 PCM/hash checks passed; pronunciation still requires listening.
- Native screenshots: .local/qa/coloring-031 (ignored).

Source version 0.31.0 / future Android code 35. No tablet build or installation in this increment; existing installed APK remains 0.28.0 / code 32.

Catalog renderer refreshed all 197 native previews. Publication guard: 2491 candidate files, zero blockers; git diff --check passed.
