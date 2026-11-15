# Little Wonder World

Godot 4.7.2 Standard educational application for ages 3-5. English is the first-run language; Ukrainian is available in the parent section. Distribution remains local/private, without Google Play.

## Current desktop version - 0.25.0

Fourteen activities, **Learn Animals**, **Learn Colors**, **Feed the Animals**, **Shape Sorting**, **Animal Puzzles**, **Memory Match**, **Numbers and counting**, **Magic Drawing**, **Coloring Book** and **Magic Xylophone**, are playable on the PC:

- Magic drawing: 149 paint choices, three sizes, regular/soft/rainbow brushes, eraser, bounded undo/redo, guarded clear, draft recovery and editable local PNG gallery.
- Numbers and counting: 1-5/1-10, four picture sets, number choice and unique-object basket modes, English numbers, return/correct/check and saved progress.
- Find the pairs: 2/3/4 pairs from twelve familiar pictures, guarded flips, gentle mismatch/retry, replay and saved pair/session counts.
- Animal puzzles: six original pictures, 2/4/6 real image fragments, hint, restart, snap/return and three-picture sessions with saved progress.
- Shape garden: six forms, three independently shuffled layouts, 2/3/4 pieces, forgiving snap/return, English names and separate saved progress.
- Snack time: twelve foods, English requests, three/four/five choices, pointer-owned drag/drop, eating feedback, five-task rounds and saved progress.
- Eight colors on two exploration pages, English color words/search, repeat, five-task sessions and separate saved progress.
- Twelve original illustrated animals on three exploration pages; tapping repeats the English word.
- Find mode with two/three/four choices for Easy/Normal/Advanced.
- Five different targets per short session, gentle retry, repeat instruction, positive feedback, completion and replay.
- Names, instructions and speech follow the selected language. Ukrainian mode is fully Ukrainian, as requested in tablet feedback.
- Local English/Ukrainian synthesized speech, independent audio controls and music ducking during voice playback.
- Actual attempts, completed tasks and completed sessions saved locally. No mastery assessment is inferred.

The activity menu exposes Animals, Colors, Snack time, Shape garden, Animal puzzles, Find the pairs, Numbers and counting, Magic drawing and the working Foxie meadow. All ten games are available in the scrollable activity grid. All ten activities have desktop implementations; final Android acceptance remains pending. The user's approved meadow artwork, palette and music are retained; Animals illustrations and additional Foxie poses extend that style. New voice timbre/pronunciation still need listening review.

The new **Living drawings / Живі малюнки** gallery contains four open-ended stories: House and yard, Spring garden, Autumn adventure and Winter wonderland. Categories and stories are displayed four per row. In House and yard, trace enlarged elements, then play with a barking puppy, day/night sun, rain, butterflies and colored chimney smoke. There is no final task or completion screen. See [the seasonal report](docs/SEASONS_REPORT.md). The drawing palette now has 149 choices, and the home screen has a single horizontal companion strip with selection arrows.

The alphabet now includes **Trace / Обвести**, for endless uppercase-letter practice. Digit tracing is in **Numbers and counting → Trace digits**, next to How many? and Basket. Both use spoken names and small fireworks. Ukrainian speech has been rebuilt with Tetiana High and explicit word stress. See [the tracing and voice report](docs/SYMBOL_TRACING_VOICE_REPORT.md) and the local comparison players under `.local/qa/uk-high/listen.html`.

Magic drawing now places tools on the left and colors/actions on the right, with clear space above the paper. See [the current layout/category report](docs/LAYOUT_CATEGORIES_REPORT.md).

Parents can now enable **Language → Ukrainian word translations** for English-mode vocabulary. A small text card above the game shows the English word and Ukrainian translation; speech stays English. It defaults off. See [the translation report](docs/WORD_TRANSLATIONS_REPORT.md).

## Run on this Windows PC

From PowerShell in `C:\git\LITTLE-WONDER-WORLD`:

```powershell
.\tools\Run-App.ps1
```

Choose **Let's play!**, then **Animals**, **Colors**, **Snack time**, **Shape garden**, **Animal puzzles**, **Find the pairs**, **Numbers and counting** or **Magic drawing**. Scroll the virtual activity grid to reach any game; Foxie's meadow is available on every page. In Snack time, tap food to hear its English name and drag the requested food to Foxie. A drop outside the target cancels without scoring. Explore pages or select **Find**. Explore also has a speaker button for the selected English word; Find has a separate repeat-instruction button. In Shape garden, drag each piece to its matching outline. In Numbers and counting, choose How many? or Basket. Drag objects into the basket, tap a stored object to return it, then press All ready! to check the exact quantity. In Animal puzzles, assemble three pictures; use Picture hint or Restart picture when needed. Next picture unlocks only after all parts are placed. Escape cancels an active drag; otherwise Back/Escape returns to the containing gallery. Hold **Grown-ups** for two seconds and answer the addition question to change language, difficulty, audio or reduced motion.

No new installation is needed to play. Portable Godot is already under `.tools/`. Windows saves are kept under `.local/windows-appdata/Godot/app_userdata/Little Wonder World/`; Android will use private app storage. Do not delete `.local/` if you want to retain desktop saves.

Open the editor with `.\tools\Start-Godot.ps1 --editor --path .`.

## Verification

```powershell
.\tools\Test-Feedback.ps1
```

This runs the shared foundation checks, persistence across separate processes, Animals, Colors, Feeding, Shapes, Puzzles, Memory, Counting, Drawing, Coloring and Xylophone model/UI checks and local voice-file verification. Current completion results are recorded in `docs/CELEBRATION_REPORT.md`; UX details remain in `docs/UX_REPORT.md`; the earlier general review is historical. Coloring includes ten original pages, independent region fills, palette, undo/redo, protected reset and editable gallery saves. The wrapper also checks Coloring and separate-process semantic persistence. Most Animals assertions cover 90 generated sessions across three difficulties; the assertion count is not a count of distinct manual tests.

Rendered review: `.\tools\Start-Godot.ps1 --path . --scene tests/animal_render_review.tscn`. It generates 48 screenshots and checks that visible buttons fit the viewport at three aspect ratios in EN/UK. Captures/logs are under `.local/qa/animals/` and `.local/logs/`. Tests use isolated save fixtures.

English speech now uses Cori, with slower pacing, gentler peaks and treble smoothing. Ukrainian Lada keeps its model with the same gentler processing. Final listening preference remains pending.

Drawing render review: `.\tools\Start-Godot.ps1 --path . --scene tests/drawing_render_review.tscn` (42 captures and scaled mouse-to-pixel checks).

Counting render review: `.\tools\Start-Godot.ps1 --path . --scene tests/counting_render_review.tscn` (60 captures, including quantities/basket up to ten).

Memory render review: `.\tools\Start-Godot.ps1 --path . --scene tests/memory_render_review.tscn` (54 captures, including both activity pages).

Puzzle render review: `.\tools\Start-Godot.ps1 --path . --scene tests/puzzle_render_review.tscn` (54 captures).

Shapes render review: `.\tools\Start-Godot.ps1 --path . --scene tests/shape_render_review.tscn` (48 captures).

Feeding render review: `.\tools\Start-Godot.ps1 --path . --scene tests/feeding_render_review.tscn` (48 captures; target/tray/card/label boundary checks).

Colors render review: `.\tools\Start-Godot.ps1 --path . --scene tests/color_render_review.tscn` (42 captures).

## Android status

Version0.12.1/code13 was built,verified,installed andlaunched on the authorized Redmi tablet2026-11-14. APK: `build/android/little-wonder-world-debug.apk`,32,942,842bytes (31.42MiB),ARM64,minSDK24,targetSDK36. Signature,ZIP alignment,permissions andresourcepackaging passed. Installedversion confirmed;startup mainloop observed without Godot script/resource errors. This is initiallaunch evidence,not complete deviceacceptance. See `docs/TABLET_BUILD_REPORT.md`; user is now reviewing ontablet.


## Project and reports

- `scenes/`, `scripts/`: application shell, companion, parent settings, Animals and shared services/components.
- `data/`: EN/UK catalogs, foundation and Animals content, development-only speech jobs.
- `assets/`: original vectors/music/effects, generated speech, licensed font and attribution notices.
- `tests/`, `tools/`: logic/integration/render fixtures, launch/build/asset-generation helpers.
- `.tools/`, `.local/`, `build/`: ignored development tools/models, local state/evidence and generated artifacts.

Current report: `docs/DRAWING_REPORT.md`; previous increments: `docs/COUNTING_REPORT.md`, `docs/MEMORY_REPORT.md`, `docs/PUZZLES_REPORT.md`, `docs/SHAPES_REPORT.md`, `docs/FEEDING_REPORT.md`, `docs/COLORS_REPORT.md` and `docs/ANIMALS_REPORT.md`. Other references: ARCHITECTURE, IMPLEMENTATION_PLAN, GAME_DESIGN, DESIGN_SYSTEM, CONTENT_MANIFEST, AUDIO_MANIFEST, ANDROID_BUILD and QA_CHECKLIST. `docs/PHASE1_REPORT.md` and `docs/ENVIRONMENT.md` are historical checkpoints. The original brief is preserved under `docs/requirements/`.

No Git identity, remotes, commits or pushes were configured/performed. Further Git setup belongs to the user.


## Drawing storage

Drawings are 1024x640 editable raster PNGs in private artwork storage. Saved copies are not overwritten when reopened/edited; Save creates a new copy after changes. Undo history is session-only (at most 24 patch transactions / 32 MiB), not stored vector strokes. A debounced draft is flushed on interruption/navigation and retained with one validated backup. Gallery: at most 24 drawings / 64 MiB of PNG storage; capacity errors preserve existing pictures. A child can open pictures but deletion is only in the guarded adult gallery, with confirmation. Full Android performance and physical touch acceptance remain pending.



PC UX 0.13.0: scroll or drag the virtual game catalog, without pagination. Drawing and Coloring actions use icon buttons with localized tooltips; brush widths use dots. After ten idle seconds, one short finger gesture suggests a concrete tap or drag; it stops on interaction and does not act for the child. UK mode now includes all178 native Ukrainian phrases using Piper medium/Tetiana, with English recordings preserved. Listening preference remains unapproved. `tools/prepare_full_ukrainian.py` enforces the full-locale policy after content authoring helpers; `generate_voice_pack.py --locale uk` replaces only Ukrainian recordings.

The tablet still has0.12.1. Per the user's latest instruction,0.13.0 is PC-only for now: no Android export/install or ADB work. A separate Ukrainian review window can be launched with `tools/Start-Godot.ps1` using scene `tests/ux_native_review.tscn`; it uses isolated preview saves. Normal desktop artwork remains untouched.

Completion0.14.0: finishing a learning round brings short fireworks and six large touch balloons. Pop all six to reveal the existing result/replay screen. Parent/focus pause and reduced-motion settings apply; idle help points to one remaining balloon. Free Drawing/Coloring/Xylophone remain open-ended. No extra practice scores are awarded for popping. PC only; tablet stays0.12.1. Finale preview: `tests/celebration_native_review.tscn` with isolated saves.

Android update2026-11-14: current0.14.0/code15 APK installed andlaunched on the authorized tablet,using data-preserving update (no uninstall/clear-data). Prior PC-only/tablet0.12.1 notes are historical. See latest entries in docs/TABLET_BUILD_REPORT.md. APK build/android/little-wonder-world-debug.apk,35,151,396bytes. Physical gameplay feedback remains pending.

Feedback pack0.15.0 adds Letters (26English/33Ukrainian,uppercase/lowercase,local names),Build a syllable (20Ukrainian/6English introductory pairs,five short tasks) andBalloon meadow (free,slow,renewing balloons,no scores). Select АБВ/ABC explicitly for lesson language; the surrounding interface keeps its selected language. Drawing/Coloring now share25flat colors and6gradient presets through the palette icon. Existing artwork is retained andgradient Coloring saves remain editable. Shapes/Puzzles allow immediate pickup of the next piece during praise. See `docs/FEEDBACK_PACK_REPORT.md`. PC review only for this increment;tablet remains0.14.0.

World0.16.0 adds a separate bilingual discovery hub (animals/body/plants), five-question checks and private comparable history. See [World report](docs/WORLD_REPORT.md). PC only; installed tablet remains0.14.0.

Desktop0.17.0: locale-bound alphabet with letter/picture tabs,59 illustrated examples,short letter speech; pictured word assembly from86EN/93UK words; detailed20-part interactive body with face/hand zoom. Includes the slow flying balloon revision. See [Learning/body report](docs/LEARNING_BODY_REPORT.md). Tablet remains0.16.0.

Desktop0.18.0 replaces the body with an approved illustrated boy and matching girl,adds eleven selectable persistent companions,changes free balloons to12at1.5x speed,and fixes all59letter recordings with phoneme-duration extraction. See [Personalization report](docs/PERSONALIZATION_REPORT.md). Tablet remains0.17.0.

Desktop0.19.0 adds unified whole-content touch scrolling for home/settings/catalog/palette,149paint choices,andcompactdrawingtools withlarger920x575visiblepaper at1280x800. See[Scroll/paint report](docs/SCROLL_PAINT_REPORT.md). Tablet remains0.18.0.

Home correction0.19.1:one horizontal swipeable pet strip at the bottom;previous/next arrows beside the large companion,cyclicselection andautomatic selected-thumbnail reveal. This supersedes the0.19.0homepetgrid. Other vertical scroll/drawing changes remain. PC only;tablet0.18.0.
