# Speech, artwork export and coloring references — 0.28.0

Source version 0.28.0; future Android version code32. Installed tablet and
existing APK remain0.25.0/code29. No APK export/install, Git operation, new
dependency or model download. Review is on PC with isolated fixture saves.

## Speech repair, listening still pending

388 recordings were replaced: 364 UK and24 EN. UK uses the existing Tetiana High
standard text frontend for331 words/phrases, replacing the hand-stressed lexical
frontend.33 Ukrainian letter names are synthesized whole with canonical IPA and
bounded minimum phoneme durations, without cutting them from a sentence.

English Red, Bread, Five and20 standalone body-part words use the existing LJ
Speech voice. Z uses whole-letter Cori /zed/. Other English recordings remain
unchanged, including the owner's selected Cat/Sheep and the retained Bear.
All9 selected/explicitly retained recordings, including UK Кіт/Качка/Вівця,
were verified unchanged by SHA256. UI text and cue routing are unchanged.

The repair is an implementation change, **not human pronunciation approval**.
All388 replacements retain an explicit unreviewed status. Please listen to the
updated pack, especially UK letters, body words, Red/Bread/Five/Z. The local
catalog at `/voice-review` shows current recordings and previous versions for20
priority cues. Prior decisions are tied to hashes and expire when audio changes.

`tools/repair_voice_pack.py` prepares candidates without touching runtime;
`--apply` validates source/candidate hashes and protects selected clips before
copying. Per-cue model hashes/methods are in manifest `voice_repair` fields.
Original manifest and388 replaced WAVs remain in ignored
`.local/qa/voice-repair-028/before/`. Repair pins are separate from human-selected
overrides and protect replacements against accidental routine regeneration.
All710 recordings total approximately39.5MiB; development models stay on PC.

## Gallery and PNG export

Gallery capacity increases from24 to200 pictures, with a256MiB total PNG budget
and4MiB per image. Storage is consumed as artwork is saved, not reserved upfront.
Existing version1 gallery indexes remain compatible; no existing drawing is
deleted or evicted. Full storage/save errors retain the draft and report failure.

Touch scrolling uses a virtual card pool and bounded24-entry thumbnail cache,
instead of decoding every full-resolution image when opening the gallery.
Recycled cards retain correct open/delete/export identities.

The parent gallery exposes **Export PNG** per drawing. It opens a native system
save dialog with an overwrite warning and writes only the selected PNG. Source
art, editable coloring metadata and gallery index remain unchanged. Invalid IDs,
non-PNG desktop destinations, internal gallery destinations and write failures
are rejected. Android document-provider URIs use FileAccess directly; no broad
storage permission or internet permission is added. Android provider/device
acceptance remains pending. This increment exports a file; it does not add an
Android share-sheet integration.

Native Windows save dialog opening/cancellation was observed using Computer Use.
Actual export bytes, explicit overwrite, blocked destinations and source safety
were verified with isolated files by the storage/UI tests. No child data was used.

## Optional coloring references

All10 coloring pages have authored pastel examples in
`data/game_content/coloring_references.json`. The palette-icon toggle shows/hides
the current page's example beside the paper. A parent setting offers the same
preference. It defaults off and persists; old settings load with the default.

The reference is rendered from a separate ColoringDocument. It never fills the
child's regions, adds undo history, changes saved colors or scores color choices.
A short EN/UK caption invites the child's own colors. Hiding restores paper width.
Examples, gallery mode and previews are included in the design catalog.

## Validation

- Gallery/reference:177 native checks, zero failures,12 EN/UK captures at1280×800
  and1024×768, including large-gallery scrolling and recycled-card navigation.
- Drawing:596 checks; Coloring:1,820; DrawWord:1,545; Release:2,259 — zero failures
  in focused runs. Gallery growth preserves migration and existing save flows.
- Voice routing:3,556 checks, zero failures; final standalone run exits cleanly.
  All710 stream paths, locale switching and playback startup were checked.
- Voice format/hash/signal audit:710 valid PCM files,0.39–5.32s; content710/0.
  All34 repaired letter clips passed the periodicity screen; this does not
  establish intelligibility.397 selected/repaired clips survive routine synthesis.
- Voice override/review Python tests:10 passed; catalog fixtures:8 passed.
- Content:26 JSON documents,707 EN/UK keys,946 concrete references, zero errors.
- Native catalog:197 captures;1,450 records,932 media,16 game/world screens.
  Inspected coloring on/off and gallery layouts; tablet touch/export is pending.

Repeat focused UI checks:

```powershell
.\tools\Start-Godot.ps1 --headless --path . --scene tests/gallery_reference_tests.tscn
```

Interactive isolated preview:

```powershell
.\tools\Start-Godot.ps1 --path . --scene tests/desktop_028_review.tscn
```

Remaining acceptance: listen and refine individual speech complaints, then test
on the tablet after an explicit installation request. F05 export/capacity and
F08 coloring examples are implemented. The ignored local plan records status.
