# Magic Drawing - desktop 0.10.0

Eight of ten educational games now have complete desktop increments, plus Foxie's meadow. Android acceptance remains pending.

## Delivered behavior

Magic drawing / Чарівне малювання provides a fitted white page, nine colors, three brush widths (8/20/40 image pixels), regular, soft and rainbow brushes, a white eraser, undo/redo, protected Clear, Save and local gallery. Interpolated clipped stamps connect sparse input events without leaving large gaps. Only one mouse/touch pointer owns an active stroke. Focus loss, parent overlay, Escape and navigation terminate visible work safely and flush the draft; unrelated fingers cannot finish the active stroke.

Clear requires a separate confirmation and can be undone. Reopening a saved image permits painting and erasing it; saving edits creates a new gallery copy rather than silently overwriting the original. Replacing unpublished current work also asks first. Child gallery has Open/Back and no deletion. Adult gallery is reached from guarded parent settings; deletion has another confirmation. Reset learning progress does not delete artwork.

Drawings are editable raster PNGs, not vector documents. Undo history is session-only and starts fresh after reopening. There is no invented correct-answer score for free drawing.

## Resource and storage bounds

- Canvas: opaque RGBA8, 1024x640. GPU texture updates at most once per frame.
- History: changed-region before/after patches, at most 24 transactions and 32 MiB combined undo/redo pixel payload. One active pre-stroke image is temporary; no full image per input point is retained.
- Brush stamp cache: at most 64 small images. Native Image.blend_rect applies stamps; interpolation and clipping bound per-segment work.
- Gallery: at most 24 saved PNGs and 64 MiB of gallery PNG/staged storage. Capacity failures preserve existing pictures; there is no silent eviction.
- Each PNG: at most 4 MiB, exact expected dimensions checked before decompression. Thumbnail textures are reduced to 192x120.
- Draft: fixed draft PNG plus one validated backup and fixed staging paths, separate from the gallery cap. Gallery metadata is versioned via JsonStore. Recoverable unindexed PNGs are surfaced after interrupted publication; newer index versions refuse writes.

These are design/enforced bounds, not a measured Android RSS/FPS or installed-size claim. File publication and backups reduce corruption exposure but do not guarantee every power-loss scenario. Write failures are shown; final device storage/lifecycle acceptance remains pending.

## Implementation and content

PaintDocument owns raster edits, clipping and bounded history. PaintCanvas maps fitted display coordinates to image space and manages pointer ownership/texture refresh. ArtworkManager owns private image/index/draft storage. ArtworkGallery is shared by child and adult views; parent gallery navigation is guarded alongside settings. The root Back action closes the child gallery before leaving the drawing.

Original paper/pencil icon and software-generated brush stamps match the existing palette. No external brush pack, new dependency or download is required. Four new localized intro/save WAVs were generated with DRAW_ prefix, preserving previous 210 clips. Current speech pack: 214 files, 12,722,994 bytes, duration 0.66-2.74s. Existing music and softened Cori/Lada processing are retained; voice preference/pronunciation still needs user listening approval.

## Verified

Final combined tools/Test-Drawing.ps1 run:

- Foundation 346 assertions, zero failures; shared cross-process settings/progress persistence passed.
- Animals 4757, Colors 707, Feeding 2914, Shapes 5094, Puzzles 8473, Memory 3031, Counting 10875 assertions, zero failures.
- Drawing 420 assertions, zero failures. Many sample continuity pixels rather than representing independent manual scenarios.
- Separate artwork write/read processes restored exact decoded gallery and draft pixels.
- All 214 voice clips passed hashes, PCM format, bounded non-silent signal/fade and duration checks.

Drawing checks cover continuous sparse-event lines, localized erase, exact undo/redo/clear restoration, soft/rainbow behavior, clipping, history/stamp bounds, editable PNG reload, preserved original, path/PNG guards, gallery count/byte quotas, orphan recovery, draft fallback, future-schema refusal and deletion scoped to isolated fixtures. Real-view viewport touch checks cover coordinate mapping, second-finger rejection, clear/cancel/undo, save deduplication, gallery open/Back, dirty-page replacement protection, adult route/delete confirmation and draft preservation during an interrupted active stroke. The fresh-process storage probe uses isolated muted settings; an unrelated startup-audio teardown race found while building the probe was resolved in the probe setup, without changing production audio.

Renderer generated 42 captures across EN/UK at 1280x800, 1440x810 and 1024x768: menu, blank/painted page, child/adult gallery, clear/delete confirmations. Zero button-boundary issues. Scaled viewport mouse strokes were checked against actual image pixels at every ratio. Selected images visually inspected. Physical tablet input is not established by these fixtures.

Native Windows mouse review exercised regular/rainbow strokes, undo/redo, Save, thumbnail gallery and reopening the saved picture. One review drawing remains in the normal local gallery; no native deletion performed. App remains open on the reopened canvas. Desktop log showed no errors during review. Pixel correctness and bounded storage were tested; actual Android drawing latency, memory usage and touch cancellation still need device QA.

## Run and continue

Play: .\tools\Run-App.ps1 -> Let's play! -> page 2 -> Magic drawing.
Combined checks: .\tools\Test-Drawing.ps1.
Renderer: tests/drawing_render_review.tscn; evidence under .local/logs/drawing-*.log, artwork-{write,read}.log and .local/qa/drawing/.

Private Windows artwork: .local/windows-appdata/Godot/app_userdata/Little Wonder World/artwork/. Do not delete .local if retaining desktop pictures/saves. Android will use app-private user storage. Current source/export preset: 0.10.0/code10, ARM64; no current APK exported or installed, no tablet/Git operations performed.

Next: Coloring Book, ten specified pages with independently fillable regions, palette, undo/redo, reset and save. Gallery can be extended backwards-compatibly for page/region state; preserve existing drawing PNGs. Magic Xylophone follows, then content/audio finish and Android acceptance. Exact resume state is in docs/CONTINUATION.md.
