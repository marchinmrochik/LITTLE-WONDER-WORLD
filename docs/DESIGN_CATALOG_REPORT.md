# Local design catalog — 2026-11-15

Delivered a repository-local browser catalog covering every registered game,
the world category and shared resources. Existing artwork remains unchanged.
The app/tablet/APK version remains 0.25.0/code 29; no tablet deployment occurred.

## Implementation

- Buildless Russian adult-facing web interface; Python standard-library server.
- Live inventory of assets, content, procedural story actors, tracing paths,
  colors, palettes, UI components and native game screenshots.
- Search, category/type/status filters, source/usage inspection, review notes,
  background comparison and audio playback.
- Draft-first PNG/SVG replacement, tracing point/JSON editor and UiKit color
  changes, followed by explicit apply and history/rollback.
- Godot renderer and isolated interactive game launcher.
- Runtime DesignVisuals bridge for optional story artwork overrides; empty
  registry preserves the existing procedural drawings. Native code remains the
  fallback. Browser tooling is excluded from Android export.

Current scan: **1,386 records / 890 media files / 724 audio files / 46 procedural
actors / 69 symbol paths / 149 paints / 15 game/world screens**. Native capture
set: **178 PNGs**. Generic component entries expose source when no dedicated
sample exists. This is not a visual node editor for every drawing primitive.

## Verified

- Eight Python fixture tests passed: inventory/unique IDs, color/art/file/letter
  and actor path apply/rollback, unchanged originals before apply, conflict
  protection, path whitelist and invalid image/point rejection.
- JavaScript syntax and Python compilation passed.
- Godot house suite: 777 checks, zero failures; seasonal suite: 1,008 checks,
  zero failures. These check the existing game mechanics, not every new editor
  interaction.
- Godot native capture run completed with 178 images. Browser QA found clipped
  actor thumbnails caused by inherited board minimum size; fixed fixture size
  and regenerated all captures. Full hedgehog image was then visually inspected.
- Browser loaded the real library, game/type filters, English-ID search, actor
  details, tracing editor and rendered state cycling. Current artwork is shown,
  including its existing rough appearance; it was not silently redesigned.
- Live HTTP catalog read succeeded. Missing mutation token and foreign Origin
  were rejected with HTTP 403.
- First launch smoke test exposed PowerShell argument binding on --editor; server
  now runs the known local Godot binary directly with isolated APPDATA.
- Repeated launch API completed with an empty error field; import and native
  preview startup logs contain no script/parse error. This verifies launch,
  not exhaustive gameplay of the launched preview.

## Limits / next work

Speech is audition/review only; use the established voice toolchain for changes.
Bitmap actor replacement retains whole-object movement, not internal rigging.
Three-state browser previews are samples; validate final animation in Godot.
Further redesign should start with one approved family of illustrations and
shared UI rules, then migrate category by category through this catalog.

See `design_catalog/README.md` for operation, storage and recovery details.
