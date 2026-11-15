# Seasonal stories, four-column catalogs and tracing - 0.22.0

Three new open-ended scenarios extend the existing House and yard. The child-accessible story gallery now has four cards in one row. The activity category catalog also uses four columns, with picture-above-label cards and a bounded reusable control pool. Touch scrolling, offset restoration, idle guidance and parent pause remain.

## Scenarios

Each seasonal scenario contains twelve individually drawable and interactive elements. One central anchor unlocks eleven independently selectable markers; undiscovered pictures remain hidden. Every scenario keeps its own accepted partial drawing, completed elements and night state in memory while the app remains open. Replay resets only that scenario. There is no task ending, completion party or score.

- Spring garden: blossoming tree, sun, rain cloud, nest, bird, flowers, butterfly, bee, frog, pond, rainbow and bunny. Tap the tree for falling petals, nest for a chick, insects/bird for flight, frog/bunny for hopping, pond for swimming fish/ripples, rainbow for sparkles and cloud for rain.
- Autumn adventure: golden tree, sun, cloud, falling leaves, hedgehog, mushrooms, pumpkin, apple basket, kite, boots, puddle and squirrel. Tree/leaves release a leaf shower; kite sways, squirrel hops, puddle ripples, pumpkin gets a face and the other harvest objects respond with gentle motion.
- Winter wonderland: cottage, moon, snow cloud, snowman, fir tree, penguin, sled, gift, lantern, star, snowflake and bird. Tap for snow, waving snowman arms, tree ornaments, moving penguin/sled/bird, gift/star sparkles, lantern glow and a rotating snowflake. Moon switches day/night; the cottage windows light at night.

The house story and its puppy, colored continuous chimney smoke, flowers, rain and day/night interactions remain available.

## Tracing and balloons

The previous tracing algorithm required reaching within 8% of every short segment endpoint, which could stall approximate mouse-drawn circles. Endpoint acceptance now uses up to 45% of a short segment (bounded by touch tolerance), accepts small backward jitter and permits either direction on closed contours. Large diagonal shortcuts and leaving the corridor still cannot complete a drawing. The accepted green point remains resumable after lifting or leaving the path.

Free balloons retain twelve independent flights. Speeds increased another 50%, from 39-66 to 58.5-99 logical pixels/second. Random colors, respawning, ellipse hit tests and pause remain. Completion balloons in other games are unchanged.

## Assets and verification

All new artwork/animations/icons are original code-native vectors; no third-party game assets or new dependencies/models downloaded. Seasonal JSON authorship is reproducible with tools/prepare_seasonal_stories.py. English/Ukrainian instructions add 64 local clips using existing Cori/Tetiana models. Pack audit: 706 clips, 41,841,548 bytes, 0.42-5.15 seconds; technical checks passed, subjective pronunciation remains for listening review. Static content: 22 JSON documents, 639 bilingual keys, 895 concrete resource references, zero errors.

Final seasonal functional run: 1008 checks, zero failures and no leak warnings. It uses actual viewport mouse events to trace every seasonal element in both languages at all three difficulties, tests every actor hit target, independent story state and increased balloon movement. Separate mouse-circle tests: 12 checks, zero failures, covering imperfect cursor circles in both directions at all three difficulties. Render review: 102 captures over EN/UK and 1280x800,1440x810,1024x768, zero layout issues; selected category/gallery/day/night images visually inspected. Regression details and final tail-suite results are in CONTINUATION.md.

Run tools/Test-Seasons.ps1 for all regression checks, or tests/seasonal_render_review.tscn for captures. tools/Run-App.ps1 starts the normal app; tests/seasons_native_review.tscn is an isolated Ukrainian gallery preview.

Source 0.22.0, future Android code25. No APK export, ADB or tablet installation occurred; installed tablet and existing APK remain 0.18.0/code20. Mouse tests do not establish tablet finger acceptance. Per-story drafts last only for the current process, with no permanent picture-gallery save.
