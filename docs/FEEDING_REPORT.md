# Feed the Animals - desktop 0.5.0

Delivered 2026-11-13. Three of ten educational games now have playable desktop increments; companion meadow is additional. No current APK export/install/device runtime validation performed.

## Delivered behavior

The child activity is titled Snack time / Час перекусити. Fantasy Foxie asks for food with an English sentence such as "Give me an apple, please." The exact twelve requested words are included: Apple, Banana, Carrot, Bread, Cheese, Milk, Strawberry, Watermelon, Orange, Pear, Cucumber, Tomato. These are vocabulary requests, not real-animal dietary matching.

Tapping a card selects and speaks its English word; the footer speaker repeats it. A separate speaker repeats the current request. Dragging shows a food preview, fades the source card and highlights the generous character target. A correct drop gives localized gratitude, sparkle audio and a three-step shrinking-food eating animation. Reduced motion uses static food feedback. A wrong food gets a gentle retry with the same request. A drop outside or an OS cancellation restores the card without recording an attempt. Focus loss, parent overlay, Escape and navigation also cancel safely.

Only the initiating pointer can move/release a drag. Other fingers and duplicate releases cannot submit or award progress. Easy/Normal/Advanced use 3/4/5 options. Five distinct requests finish a session; replay resets it. Actual attempts, completed tasks and sessions save under feeding, separate from Animals/Colors.

## Implementation and assets

FeedingRound extends the shared ID-based AnimalRound. FoodCard emits pointer/word intent; feed_animals.gd owns interaction, state, cleanup and lifecycle. Existing catalogs, Foxie assets, UI, local audio, persistence and parent services are reused. The activity menu now builds four cards through one shared helper, fitting the three review ratios. Twelve food SVGs were authored locally; approved music/background/base Foxie artwork remain.

32 additional short offline clips were synthesized using the existing Cori/Lada models and gentler processing. Prefix generation preserves previous clips and verifies matching model/processing provenance. Current pack: 110 clips, 5,559,156 bytes, duration 0.66-2.74s. Models remain PC-only. No new downloads or external account needed. Voice preference/pronunciation remains pending user listening.

## Verification

Final combined run of tools/Test-Feeding.ps1:

- Foundation: 214 assertions, zero failures; separate-process persistence passed.
- Animals: 4757 assertions, zero failures.
- Colors: 707 assertions, zero failures.
- Feeding: 2914 assertions, zero failures, including 60 seeded model sessions and two-locale real-view flows.
- All 110 voice files passed checksums, PCM format, signal/fade and duration bounds.

Feeding integration checks inject actual viewport mouse and synthetic screen-touch events: tap without submission, outside drop, wrong/right drops, duplicate release, unrelated finger, OS cancellation, overlay/focus cancellation, prompt/word playback, completion idempotence, replay, cleanup and saved isolated counters. Synthetic events are not evidence of physical Android input.

Final render fixture produced 48 PNGs: EN/UK at 1280x800, 1440x810, 1024x768; menu, three difficulty requests, drag highlight, retry, eating and completion. Zero target/tray-card/button/card-label boundary issues. Selected screenshots visually inspected. Initial subtitle clipping, stretched stars and changing target padding were fixed before final checks.

Native Windows computer-use verification exercised the real activity menu, a wrong food drag, recovery to the same request and a correct drag with eating/gratitude feedback. Final padding polish was covered by subsequent logic/render runs. Completion/replay tested programmatically. App left open for user play; relaunch for latest source if needed. No runtime errors appeared in the desktop log during this review.

## Run and continue

Play: .\tools\Run-App.ps1, then Let's play! -> Snack time.
Combined checks: .\tools\Test-Feeding.ps1.
Render fixture: tests/feeding_render_review.tscn. Evidence: .local/logs/feeding-*.log and .local/qa/feeding/.

Next increment: Shape Sorting - six shapes, identity matching, forgiving snap/return, multiple layouts and spoken names. Full brief remains docs/requirements/MASTER_PROMPT.ru.md. Current USB readiness was verified in the preceding increment; no tablet commands were needed here. Android source preset is 0.5.0/code5; current APK not exported. No Git operations performed. Resume checkpoint: docs/CONTINUATION.md.
