# Coloring Book desktop increment

Delivered 2026-11-14, source0.11.0 / Android preset11. Nine of ten games now playable on PC. Android export and tablet acceptance are deferred.

## Behavior

Ten original pages: Cat, Dog, Fox, Butterfly, Fish, House, Flower, Car, Dinosaur, Rainbow. Large closed regions fill independently on a single pointer press. Outlines, eyes and outer background stay protected. Nine colors plus white, English nouns/repeat, undo/redo bounded64 transactions/page, protected undoable reset, perpage working states and debounced semantic draft.

PNG saves include validated region metadata in the existing private gallery index. Reopening preserves editable regions; existing Drawing PNGs retain their editor. Saved copies are immutable, dirty replacement asks. Draft is separate from Drawing. Gallery limits remain24 pictures/64MiB, individual PNG4MiB maximum. If semantic metadata is missing, a recovered orphan PNG opens as raster Drawing. No fabricated educational scores.

## Verification

Test-Coloring.ps1 passed all suites: foundation366; Animals4757; Colors707; Feeding2914; Shapes5094; Puzzles8473; Memory3033; Counting10875; Drawing420; Coloring1822. All zero failures. Counts are assertions, not distinct manual scenarios. Separate-process Artwork and Coloring write/read checks passed. Coloring covers every authored region, one-region state/pixel isolation, undo/redo/reset, validation, bounded history, draft, old gallery compatibility, EN/UK real scene navigation, focus and cross-editor routing.

Rendered138 captures across1280x800,1440x810,1024x768 and both locales: zero button-boundary issues. Allten plain/colored pages inspected via contact sheet plus selected full images. Native mouse verified independent Cat areas, undo/redo, Save, gallery/reopen and the new menu icon. The old Drawing and one review Coloring remain in the normal local gallery; app left open on Cat. Runtime log clean at check.

228 speech clips verified,13,421,964bytes,0.66-2.74s. Fourteen new BOOK_ clips preserve earlier214; existing Cori/Lada models and gentle processing. Final pronunciation/voice preference needs user listening. No new downloads or dependencies.

## Files and continuation

Core: scripts/games/coloring_document.gd, coloring_book.gd, scripts/components/coloring_canvas.gd, scripts/core/artwork_manager.gd. Content: data/game_content/coloring.json, assets/objects/coloring, assets/ui/coloring.svg. Authoring helper: tools/prepare_coloring_content.py. Tests: tools/Test-Coloring.ps1. Evidence under .local/logs and .local/qa/coloring (private/ignored).

Next: Magic Xylophone, then final content/audio and Android device checks. No APK exported/installed, tablet operations or Git actions this increment. Desktop tests do not verify physical touch, polyphony, Android lifecycle, memory or frame pacing.
