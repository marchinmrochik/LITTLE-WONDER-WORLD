# Play improvements 0.26.0 — 2026-11-15

Implemented the requested difficulty/settings, content selection, tracing,
balloon challenge and melody practice increment. Source version 0.26.0, future
Android version code30. Installed tablet and existing APK remain0.25.0/code29.
No export, installation, Git commit/push, dependency installation or downloads.

## Behavior

- Activities now has an always-visible three-level difficulty strip before a
  game starts. The setting persists. Games retain their existing difficulty
  logic; no forced mid-round reset. The header entry uses a gear and localized
  Settings label; the existing adult hold/gate remains in place.
- Puzzles can choose a specific picture or the existing random three-picture
  session. A chosen picture is a one-picture session, with correct progress,
  completion speech and replay. Memory can choose exactly the current number
  of pairs, including across available content groups, or randomize as before.
  Word building can choose a pictured word or the existing shuffled session.
  Completion screens also expose the picker.
- Shared MaterialPicker uses a four-column, touch-scrollable virtual list with
  a bounded pool. It previews/voices selected pictures, crops body illustrations,
  shows selected count, and pauses underlying gameplay through AppRoot.modal.
  Back/cancel retains the current attempt; applying a choice starts a new one.
  Positions/pieces still shuffle where that is part of the learning mechanic. Random puzzle/word replay avoids an immediate repeated first item.
- GuidedTrace permits nearby forward re-entry on the current segment after
  leaving the path, within bounded geometric tolerance. It still rejects
  arbitrary jumps/backtracking. Both story and symbol boards process the final
  release position; cancelled touches do not finish a stroke. Nine story actor
  guides now use recognizable rabbit/frog/bee/bird/hedgehog/pumpkin/penguin/lantern
  silhouettes instead of generic circular/rectangular gestures. Illustration
  artwork was not redesigned in this increment. Simple early shapes remain.
- Balloon free play retains12 renewing balloons and prior speed, now with a
  visible count. A separate60-second challenge starts at4 active balloons and
  grows to12 with bounded pace and shorter respawn delay. Pause/focus freezes
  the attempt. An object scores once, hidden objects cannot score. Only finished
  timed attempts enter the local top10 per difficulty; free play cannot write
  a record. The result table scrolls and reports save failure. Data is separate
  `user://balloon_records.json`, using validated JsonStore recovery/atomic writes.
- Xylophone retains free play and adds three short original motifs using its
  eight existing notes. Listen/stop previews at a gentle pace; practice shows
  the next key with a gold outline and note label. Correct notes advance; wrong
  notes give a gentle hint. Demo playback cannot advance the child's progress.
  Pause freezes the demo; replay/selection resets it. Completion is positive,
  with no negative grade or invented rhythm assessment.
- New copy is EN/UK. No speech files were changed in this increment; the prior
  accepted per-cue voice selections remain protected.

## Verification

- Focused integration:73 headless checks, zero failures, including actual touch
  selection, modal pause, single-picture/word completion, exact memory deck,
  timed score/timer/save safeguards, melody/demo separation, bounded re-entry,
  top-ten persistence and1000-item virtual picker.
- Native integration/render:122 checks, zero failures,24 captures across EN/UK
  and1280x800/1024x768. Selected difficulty, picker, memory, melody and result
  images visually inspected. Final runs exit without engine leak warnings.
- Existing focused suites passed: Puzzles8473, Memory3031, Xylophone86,
  SymbolTracing1447, LivingHouse777, Seasonal1008, Friends368, UX882.
- Content:25JSON/672 bilingual keys/902 referenced resources, zero errors.
  All710 speech records still pass the content/hash-route audit.
- All nine revised silhouette paths fit their existing zoom regions.
- Native design-catalog generation completed182 captures. New mode screens are
  indexed there; current inventory1394 records/891 media files. Catalog mutation
  fixture tests are separate from game integration.

Initial integration caught mixed indentation in two edited files and an orphaned
preallocated counter label. Both were fixed and the final runs above repeated.
The first result capture exposed stale remaining time and a potentially unbounded
record layout; final timer/table captures were regenerated after correction.

## Review

Run `tools/Run-App.ps1` for the normal PC app. Isolated review scene:
`tests/play_improvements_native_review.tscn`, starting at the UK activities menu
with separate saves and records. Focused suite wrapper:
`tools/Test-PlayImprovements.ps1`. Captures:
`.local/qa/play-improvements/` (Git-ignored).

Physical tablet gestures, preferred challenge pacing and musical/gameplay appeal
still need user review. These are desktop checks, not tablet acceptance or a full
rerun of every unrelated suite. Exporting artwork, larger gallery capacity,
coloring examples, Crocodile mode and the remaining voice complaints are deferred.
