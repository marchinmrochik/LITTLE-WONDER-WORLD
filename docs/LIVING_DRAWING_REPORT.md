# Living drawings - House and yard, 0.21.0

This checkpoint supersedes the 0.20.0 task-style house prototype. The child builds one open-ended living scene, without a final task, completion balloons, result screen or saved score.

## Scene and navigation

The activity tile opens a child-accessible story gallery. Its single available card is House and yard. The drawing screen has a Back to stories arrow; Escape/Android Back uses the same route. Additional scenario cards can be added later. Completed elements, accepted partial tracing, day/night, window lights and smoke color survive gallery navigation within the current app process. They are not written as permanent artwork and reset after closing the app. Replay explicitly clears this scene.

The six house parts are offered one at a time. Undrawn elements have no gray silhouette or background preview. Only their glowing marker is visible until selected. Selecting it reveals that element's colored guide in the enlarged drawing view. The accepted line is now 9 screen pixels (previously 7), earlier completed strokes 8 (previously 6), and the green leading point has a 12-pixel radius (previously 10). Dotted guide spacing is 36 pixels instead of 18, approximately halving density. Ordered input, off-path recovery and forgiving difficulty-based tolerance remain.

After the house, four independent markers appear. The child can choose them in any order, and finished objects remain interactive while other markers are still available:

- Sun: a smiling sun changes the sky to night with stars and a crescent moon; window lights turn on. Tapping the moon restores day and switches those lights off.
- Cloud: tapping makes gentle rain; flowers get a small puddle when present.
- Puppy: tapping plays a gentle, original synthesized two-woof effect, wags the tail and sends the puppy across the yard and back. Reduced motion retains barking and a stationary puppy.
- Flowers: tapping invites three animated butterflies.

The chimney starts emitting smoke as soon as it is drawn. Every chimney tap cycles through five smoke colors. Door/selected-companion, window lights and roof bird interactions remain. Pause freezes scene movement, camera, accepted drawing and puppy audio. All elements can be tapped repeatedly after drawing; nothing forces an ending.

## Assets and verification

One original code-native scene: ten elements, fifteen guided strokes. No third-party game assets, new models or dependencies downloaded. English/Ukrainian UI and 28 finite LIVE speech clips use existing Cori/Tetiana voices. The full speech pack now has 642 clips, 37,651,034 bytes, 0.42-5.15 seconds. Format/hash/signal checks passed; listening preference remains a user review item. Bark is a deterministic local mono 22,050 Hz, 16-bit, 0.62-second synthesis on the SFX bus.

Focused functional checks: 777 assertions, zero failures, covering bilingual actual viewport touch tracing at all three difficulties, gallery navigation and partial drawing restoration, arbitrary extra-marker choice, no completion overlay/scoring, sun/moon taps, moving/barking puppy and pause. Render review: 192 captures across two languages and three resolutions, zero boundary issues; selected marker-only, tracing, gallery and day/night frames visually inspected. Full regression results are recorded in CONTINUATION.md. Content audit: 19 JSON documents, 604 EN/UK keys, 829 concrete resource references, zero errors.

Run tools/Test-LivingHouse.ps1 for the regression chain; tests/living_house_render_review.tscn produces bilingual three-resolution captures under .local/qa/living-yard. Run tools/Run-App.ps1 normally, or launch tests/living_house_native_review.tscn with tools/Start-Godot.ps1 for the isolated Ukrainian preview.

Source is 0.21.0, future Android code24. No APK export, ADB or tablet installation was performed. Existing APK and installed tablet remain 0.18.0/code20; PC gesture automation does not replace tablet acceptance.
