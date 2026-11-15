# Learning and body revision — desktop 0.17.0

2026-11-14. User authorized alphabet presentation/speech corrections, illustrated word building and a more detailed interactive body. PC checkpoint; tablet stays0.16.0/code17 until a separate update request. Future Android preset is0.17.0/code19. No Git operations, downloads, device changes or APK export in this increment.

## Alphabet

The alphabet follows the application language:33 Ukrainian or26 English letters. Removed the child-facing alphabet-language selector. Two tabs offer a colorful letter grid and one large illustrated letter card. Horizontal touch/mouse swipes and previous/next arrows navigate cards; boundaries stop at the first/last card. Selecting a letter in the grid remembers its corresponding picture position. Letter and picture are separately tappable: short letter name versus example word. The English recordings no longer include “The letter”. These are letter names, not a claim of a full phonics/isolated-phoneme course.

All59 entries explicitly bind upper/lower glyph, example, highlighted character index, image and separate recordings. Common words begin with that letter. Ukrainian И uses сир and Ь uses кінь, explicitly marked as a letter inside the word; neither is presented as an initial-letter example. This avoids forced unfamiliar initial words and a false initial correspondence. Ukrainian names/order were checked against the Ministry of Education official spelling reference: https://mon.gov.ua/static-objects/mon/sites/1/zagalna%20serednya/Pravopys.2019/ukrayinskii-pravopis-oficiine-vidannia-2026.pdf .

32 new original SVG illustrations complement existing animal/food/plant art. No emoji/font substitution for picture assets. Authoring: tools/prepare_alphabet_cards.py, chained by prepare_learning_pack.py so regeneration preserves the corrections.

## Picture words

Replaced fixed two-letter syllable exercises with “Build a word” / “Збери слово”, retaining the internal route/progress key syllables for existing saves. WordCatalog lazily merges pictured vocabulary from Animals, Feeding, Colors, Shapes, Plants, Body, Coloring, Counting, Memory, Puzzles and the new alphabet examples; repeated spellings are deduplicated per locale. Current pool:86 EN and93 UK words.

Each session draws five unique random words with their existing image and locale-specific spoken word. All letters are shuffled once per word. Repeated letters have distinct consumable tiles. Taps place letters in order; wrong taps do not consume tiles. Easy mode shows a faint letter template; other levels leave slots empty. Spaces/hyphens are fixed separators, not guessed letters. Correct completion enables Next; five words earn the existing pop-balloon finale. Pause/input guards and a single idle finger remain active. Historical syllable totals are retained; new item IDs use word: prefixes, not invented historical comparisons.

## Detailed body

Replaced the original figure with a more detailed original vector: visible eyebrows, irises/highlights, hair detail, ear folds, smile/teeth, neck/collar, shirt detail, elbow/knee creases, five distinct digits per hand, nails/palm creases and bare feet with visible toes.

20 voiced/tappable entries:head,eye,nose,mouth,ear,arm,hand,leg,foot,eyebrow,cheek,chin,hair,finger,elbow,shoulder,neck,belly,torso,knee. Small parts take hit priority over enclosing regions; both hands/limbs have mirrored hit regions. Clicking a hand/finger opens a hand close-up; face and full-body views are retained. Torso and belly are selectable through the clothed figure. Body comparison revision increases to2 because hit regions/distractors changed; old history remains readable and is not compared across revisions.

Twenty explicit SVG crops reuse the same character for picture-word tasks. Crops clip to their declared part region. Authoring:tools/prepare_body_details.py, chained by prepare_world_content.py.

## Verification

- Full tools/Test-World.ps1 chain passed after the first complete integration: foundation619, all earlier game suites, release2067, UX834, celebration547, Feedback483, World928, and separate-process history write/read.
- After expanding the final vocabulary pool and refining brow/thumb geometry:focused Feedback498 and World940 assertions passed, zero failures. Touch tests cover actual swipe input, pause, rejected foreign alphabet changes, matching example characters, repeated tiles, picture presence, broad pool coverage and body hit anchors including the actual brow stroke/thumb.
- Final rendering:171 Feedback captures including all59 alphabet cards and both20-part body-word sheets;96 World captures across EN/UK at1280x800,1440x810,1024x768. Zero button-boundary issues. All59 card examples and selected grid/long-word/body/face/hand views were visually inspected. Renderer output is separate from physical-device acceptance.
- Static source check:17 JSON documents,568 keys in each locale,812 concrete resource references,zero errors.
- Speech:614 non-silent PCM clips,35,563,904bytes,0.49–4.76seconds; checksums/format/signal passed. Existing pinned Cori/Tetiana voices and gentle processing retained. Short-name regeneration plus example/body recordings; no model downloads. Correspondence was checked in data/jobs/assets; subjective pronunciation still requires user listening, especially single-letter TTS.

Logs:.local/logs/learning-details-{full,tests,render}.log,body-details-{tests,render}.log. Captures:.local/qa/feedback and.local/qa/world. The preview uses isolated test-runs saves and does not fabricate normal user history.

Run the isolated Ukrainian PC preview:

`powershell -ExecutionPolicy Bypass -File tools/Start-Godot.ps1 --path . --scene tests/learning_native_review.tscn`

Next: user PC/listening feedback or explicitly requested tablet update. The earlier slow upward balloon revision is included in this source version.
