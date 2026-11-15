# Feedback pack: colors, responsive dragging and new activities

2026-11-14. Desktop source0.15.0 / future Android preset16. All four feedback items implemented. PC review only in this increment;tablet still0.14.0. No ADB,APK export/install,Git commands ornew downloads.

## Colors and gradients

The shared palette has25solid colors and6two-color gradient presets. Nine familiar quick colors remain on the main toolbar;the artist-palette icon opens the expanded selector. Picking a swatch closes it andresumes drawing;the background canvas is paused while choosing.

Drawing blends two chosen colors along stroke distance,with a quantized25-step ramp to keep the stamp cache bounded. It preserves regular/soft brushes,eraser,rainbow andexact raster undo/redo. Coloring stores validated gradient descriptors perregion andrenders actual SVG gradients;semantic saves/drafts andgallery reopen retain editable regions. Existing hex-color pages andordinary PNG drawings remain readable. New files are not claimed compatible with an older downgraded application. No external color service orimage pack.

## Delay between drags

Shapes andPuzzles intentionally blocked input inFEEDBACK for0.9–1second oruntil praise speech ended. This matched the reported delayed next pickup. A new valid pickup can now settle the previous snap immediately,stop its timer andstart the next drag. Old tween callbacks cannot dispose the new preview. Completed boards/pictures retain their normal transition;focus,parent pause,wrong/outside-drop andduplicate-placement guards remain. This removes a verified interaction lock,not a claim that every tablet FPS issue is resolved.

## Three new activities

Letters: all26English and33Ukrainian letters,uppercase/lowercase pairs,each with local spoken name. АБВ/ABC chooses the alphabet explicitly;the default follows interface locale. This is free exploration andawards no fake correct-answer scores.

Build a syllable: two ordered slots and2/3/4letter choices by difficulty. Ukrainian has20beginning CV combinations fromМ/Н/С/Т withА/О/У/И/І. English starts withAT,AN,IN,IT,ON,UP. These are introductory two-letter blending units,not a complete reading curriculum. A wrong letter leaves the slot empty;correct letters fill in order,then Next advances. Five assembled items lead to the existing six-balloon completion. Actual attempts/tasks/sessions save locally. The whole target is spoken again after assembly.

Lesson language is explicit. English alphabet/blend speech staysEnglish whenABC is selected in a Ukrainian interface;Ukrainian lessons keepUkrainian speech. This is distinct from the earlier bug where unrelated UK game instructions were forcedEnglish. foundation.study_locales declares these finite learning-resource exceptions. Surrounding UI andordinary instructions still follow the selected interface language.

Balloon meadow: a separate free activity with six large gently floating balloons,soft pop feedback andan automatically renewed set after allsix. Six nodes are reused,without a growing object collection. No stopwatch,miss penalty,leaderboard orfabricated learning score. Parent/focus pause and reduced-motion settings apply;Home remains available.

Menu now exposes13working activities through the existing virtual scroll grid. The new content is in data/game_content/letters.json;logic does not contain alphabet/target lists.

## Verification

The full Test-Feedback.ps1 chain passed41,742assertions with0failures,including the initial218focused feedback checks. After final palette-selection anddisk-reload checks were added,the focused suite passed226assertions with0failures andno leaked nodes/RIDs. An initial pair of unattached Syllable options containers was found andremoved before final verification. A final focus-notification timer guard was corrected andthe226checks rerun cleanly.

Focused coverage: real gradient raster differences,exact undo/redo,semantic Coloring validation/gallery save,reload andeditable reopen,SVG injection rejection,actual palette swatch callbacks/pause/resume,immediate second-piece pickup acrossbothlocales andall difficulties,complete alphabet sizes/resources,wrong/correct letter assembly,five-task completion,renewable bounded balloon state andno fake scores. Prior settings/progress,Artwork andColoring process persistence checks passed.

Renderer:66captures at1280x800,1440x810,1024x768 inEN/UK;zero checked button-boundary issues. Both alphabets,both lesson modes,partial assembly,free balloons,expanded palette andboth gradient editors covered. Selected fullscreens inspected. The final palette icon differs from the earlier rainbow shortcut butuses the same layout footprint. Native PC review verified alphabet taps/language switch,assemblingСО,andfree-balloon pop. An isolated Ukrainian NewActivities preview remains open onBalloon meadow;normal personal gallery data was not touched.

85new finite recordings use existing Cori/Tetiana models. Final total443PCM clips,27,789,806bytes,0.49–4.76seconds;hash/format/signal checks pass. English blend targets were regenerated as standalone utterances to avoid an unstressed phrase prefix. Pronunciation andteaching suitability still need user listening,not inferred from signal tests. No model/dependency download.

## Files and next review

Core changes: scripts/components/paint_palette.gd;paint_document.gd;coloring_document.gd;shape_sorting.gd;animal_puzzles.gd. New games: alphabet_garden.gd,syllable_garden.gd,balloon_meadow.gd andtheir scenes. Data/helper:letters.json,tools/prepare_learning_pack.py. tools/prepare_full_ukrainian.py preserves declared study voices;Animals authoring preserves ALPH_/BLEND_ jobs. Future Android helper checks letters.json,without exporting an APK now.

Combined checks:.\tools\Test-Feedback.ps1. Normal launch:.\tools\Run-App.ps1. Isolated preview:tools/Start-Godot.ps1 with scene tests/feedback_native_review.tscn. Logs:.local/logs/feedback-{full,tests,render,native}.log;captures:.local/qa/feedback. Listening/sample feedback andphysical tablet performance remain pending. Next: user PC review,then update tablet only when requested.
