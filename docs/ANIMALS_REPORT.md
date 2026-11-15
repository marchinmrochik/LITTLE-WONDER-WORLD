# Animals Desktop Slice — Delivery Report

Date: 2026-11-13. Source version: 0.3.0. Scope: Phase 2 visual/content baseline plus the first educational game's desktop slice. Android finalization is deferred by the user's instruction. The original meadow style and music were approved by the user and retained.

## Delivered

Learn Animals is the first of ten planned educational games. Home → Let's play opens the activity menu, which exposes Animals and the already working Foxie meadow. There are no empty future game sections.

Exploration has twelve project-original illustrations over three pages: Cat, Dog, Cow, Pig, Sheep, Horse, Duck, Chicken, Rabbit, Bear, Lion and Elephant. A tap animates the card and plays its English word from a local WAV file. A dedicated speaker button repeats the selected English word. Paging and repeated taps work without an internet service or an installed system voice.

Find mode uses five distinct targets per short session. Easy gives two choices, Normal three, Advanced four. Choices are unique and include the target. The English instruction can be repeated with the speaker. A wrong answer retains the task and gives gentle localized encouragement. Feedback blocks double submissions. A correct answer/task is saved in one write; completing five tasks records one completed session and shows a five-star celebration. Replay begins a fresh session.

English learning words and find prompts stay English under UK UI; navigation/helper reactions follow the UI locale. Parent settings show completed animal sessions alongside actual practice attempts. Counts are practice evidence, not a mastery/developmental diagnosis.

The current Foxie art now has seven states: idle, resting, happy, waving, thinking, encouraging and celebrating. Existing base art/music are retained. New animal cards use soft mint backing shapes so white animals do not blend into cream cards. Button icons reserve enough width to remain visible for children who cannot read.

## Local speech

52 stock-model synthesized clips are bundled: 32 EN and 20 UK. They contain twelve English words, EN/UK find instructions and eight helper/UI phrases per language. The twelve English word files are used under either UI language. Ukrainian find clips are available in the manifest but do not replace the game's English learning instruction.

The total WAV payload is 1,996,400 bytes, with 0.34–1.75 second clips. Files were checked for matching hashes, valid mono PCM format, non-silent/bounded signal, faded edges and valid duration. Music ducks during local voice playback and restores afterwards. System-voice fallback remains optional/off; bundled speech works without it.

English uses Piper en_US-ljspeech-high; Ukrainian uses uk_UA-lada-x_low. These are voice candidates, not final actor recordings or expert-reviewed pronunciation. Listening review is still needed for tone, clarity and stress, especially the low-complexity Ukrainian model.

Only WAVs and notices are runtime assets. The Piper engine and approximately 135 MB of model weights stay under ignored PC .tools/. Models were pinned to revision 6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3 and checked against official Hugging Face LFS SHA-256 metadata. The official Windows engine release was used; its local archive hash is recorded without claiming an unavailable upstream digest. Dataset/model notices and source links are in assets/licenses/VOICE_NOTICE.md and tools/voice-toolchain.json. No dataset, paid service, account or new user-provided data was needed.

## Verification actually performed

| Area | Result |
| --- | --- |
| Foundation regression | 157 assertions, zero failures |
| Animals model and UI integration | 4,757 assertions, zero failures |
| Generated-session coverage | 90 seeded sessions across three difficulties; uniqueness, target inclusion, wrong answers, duplicate submissions, five-round completion |
| Persistence | Separate processes restored UK/difficulty/music, attempts, completed tasks and completed sessions |
| Local audio | Files resolved/played with system fallback disabled; music attenuation/restoration checked against actual playback completion |
| Touch approximation | A viewport-injected ScreenTouch selected one card exactly once; this is not a physical Android touch test |
| Lifecycle/overlay | Focus loss and parent overlay pause pending feedback; leaving cancels voice/timer work |
| Rendered layout | 48 captures at 1280×800, 1440×810 and 1024×768 in EN/UK; activity menu, three exploration pages, all three choice counts and completion; zero button-boundary violations |
| Visual inspection | All twelve animal illustrations and representative activity/quiz/completion screens reviewed; white-body contrast and icon sizing corrected |
| Native desktop UI | Mouse playthrough: an incorrect answer retained its target, five correct answers reached completion, replay started a new session, speaker repeated the current prompt, home/back and exit worked |
| Speech quality | Technical signal checks passed; audible pronunciation/voice preference is not claimed final |
| Android | No new APK export, OS emulator, tablet launch or mobile performance check in this iteration |

Assertion counts include many per-key/per-seed checks; they are not thousands of distinct manual scenarios. Headless input was injected in viewport coordinates because headless display coordinates differ from a real window. The test fix does not claim mobile emulation fidelity. Audio completion checks wait for playback within a bounded deadline rather than assuming nominal file duration equals actual start/end scheduling.

Final evidence: .local/logs/animals-verification.log, animals-tests.log, animals-render-final.log, phase1-tests.log and the separate-process persistence logs. Images: .local/qa/animals/. Test saves use isolated user://test-runs paths and do not reset real application progress.

## Files and reproduction

Runtime additions: scenes/games/learn_animals.tscn; scripts/games/{animal_catalog,animal_round,learn_animals}.gd; scenes/home/activities.tscn and its script; animals.json; animal/pose SVGs; EN/UK voices and catalogs. Shared changes: game registration, local voice/music handling, additive completion counters, parent preview/statistics and icon sizing. No Git configuration, commit or push was performed.

```powershell
.\tools\Run-App.ps1
.\tools\Test-Animals.ps1
```

For rendered review: tools/Start-Godot.ps1 --path . --scene tests/animal_render_review.tscn. Authoring helpers and generation manifests are under tools/ and data/game_content/; asset provenance is retained with the source.

## Boundaries and next step

This is a native desktop Godot build, not an Android OS emulator. Physical touch, safe areas, system gestures, airplane-mode behavior, tablet speaker latency, installed size, memory and frame pacing remain for final Android QA. The old Phase 1 APK is version 0.1.0 and does not contain this slice. The source/export preset is version 0.3.0 / code 3; no new mobile build is claimed.

The other nine games, editable drawings/gallery management, coloring regions, drag/drop puzzles/sorting and multitouch instrument remain unimplemented. There is no persistent sticker collection or inferred mastery; the current five-star celebration is a session result.

Next review: play Animals on PC and listen to the EN/UK voice candidates. Then proceed with Learn Colors and the remaining games in the implementation plan. Audio polish and real-tablet acceptance remain separate readiness tracks.


