# Content Manifest

Status: current desktop Animals, Colors, Feeding, Shapes, Puzzles, Memory, Counting and Drawing slice, 2026-11-13.

| Content | Status |
| --- | --- |
| EN/UK interface catalogs | Complete for implemented screens; stable-key completeness checked |
| Animals | Cat, Dog, Cow, Pig, Sheep, Horse, Duck, Chicken, Rabbit, Bear, Lion, Elephant |
| Animal illustrations | Twelve original SVGs; authored in the approved soft vector style |
| Animal data | data/game_content/animals.json: IDs, EN/UK names, illustration, English word/prompt keys and paths, optional animal sound field |
| English learning labels | Kept in English under both interface languages |
| Foxie | Idle, resting, happy, waving, thinking, encouraging and celebrating SVG states |
| Meadow and base UI | Retained original foundation assets |
| Colors | Red, Blue, Yellow, Green, Orange, Purple, Pink, Brown; eight original ball SVGs, two exploration pages, shared choice-game controller |
| Foods | Apple, Banana, Carrot, Bread, Cheese, Milk, Strawberry, Watermelon, Orange, Pear, Cucumber, Tomato; twelve original SVGs and foods.json |
| Shapes | Circle, Square, Triangle, Rectangle, Star, Heart; six colored SVG pieces, six neutral silhouettes and shapes.json |
| Puzzles | Cat, Dog, Rabbit, Bear, Lion, Elephant; original animal SVGs and English word audio reused, real AtlasTexture crop pieces generated at runtime |
| Memory | Twelve familiar entries: Cat, Dog, Rabbit, Bear; Apple, Banana, Carrot, Strawberry; Circle, Square, Star, Heart. Original art/English words reused; prefixed unique IDs in memory.json |
| Counting | Apples,carrots,strawberries,stars;original art reused,counting.json contains singular/plural/theme instruction keys. 1-5 and1-10 quantity/basket modes |
| Drawing | Original drawing/pencil icon; nine-color raster brushes; child/adult thumbnail galleries. No external artwork pack. |
| Voice pack | 228 generated local EN/UK WAV files; see AUDIO_MANIFEST.md |
| Coloring Book | Ten original closed-region pages, semantic fill state, preview SVGs, editable PNG gallery |
| Magic Xylophone | Eight original mono PCM modal-bar notes C5-C6,44.1kHz/16bit/1.7s each,16 bounded runtime voices, original vector menu icon |
| Artwork storage/gallery | Private 1024x640 PNG gallery, editable reopen, draft/backup, metadata recovery, capacity bounds and confirmed adult deletion; session-only undo |

AnimalCatalog validates required fields, unique IDs, safe resource paths and required word/prompt files. AnimalRound operates on IDs from the catalog rather than hardcoded animal names. Adding content requires assets, catalog entries, localization and voice entries; the question-selection algorithm does not need to change. Authoring/generation helpers are separate from runtime game logic.

Practice records are actual attempts/tasks/sessions, not a developmental assessment. Correct answers and task completion are saved together; repeated input during feedback cannot duplicate them. No animal is silently marked mastered.

Asset provenance and voice-model attribution: assets/PROVENANCE.md and assets/licenses/VOICE_NOTICE.md. Nunito remains unmodified under OFL 1.1, with its license retained. Font SHA-256: bb55a5ca5c2042335b3991af27c4d0705d0ef41cac6164ac737fd8f2a1e85207.

Feedback0.15.0:13activities. letters.json contains26EN+33UKletter cards and6EN+20UKbeginning two-letter targets. Shared palette25solid+6gradients;original palette/letters/syllable/balloon icons.443finite speech clips. SeeFEEDBACK_PACK_REPORT.md.
