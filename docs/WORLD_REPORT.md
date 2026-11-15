# World expansion 0.16.0 — PC checkpoint

Implemented in Ukrainian and English, including local speech:
- Separate Discover the world hub: 12 animals, 9 body parts, 8 plants.
- Explore mode; interactive body with face zoom; five-question checks with 2/3/4 choices by difficulty.
- One idle action hint, gentle retry, shared fireworks and six pop balloons after completion.
- Private parent history: last 100 checks, independent first answers, assisted answers, retries and comparison with previous completed check under matching topic/revision/language/level/item set. Interrupted checks stay explicitly incomplete.
- Old aggregate practice counts remain unchanged. Device-local timestamps; no reconstructed old history, profiles, network or leaderboard.

AssessmentHistory stores a separate versioned atomic JSON document with backup and future-schema write refusal. A check completes when its final answer is recorded, before praise animation. Practice exploration creates no scored session.

Validation: prior regression suites passed; 792 new World assertions passed. Cross-process history write/read passed without resource leaks after allowing the audio startup to settle in the probe. The first wrapper stopped on probe shutdown warnings; those were corrected and both probe processes rerun successfully. 84 rendered captures cover EN/UK at 1280x800,1440x810,1024x768; zero button-boundary issues. Selected body, plant and parent-table captures visually inspected. Final visual adjustments were included in the 84-capture rerun.

Content audit: 17 JSON documents, 481 locale keys per language, 657 resource references, zero errors. 511 local speech clips, 31,152,684 bytes, 0.49–4.76 seconds; format/hash/signal checks passed. 68 new clips use existing pinned Cori/Tetiana voices. Pronunciation and voice preference still require listening review.

No downloads, Git actions, APK export or tablet operations. Source 0.16.0 / future Android code17; installed tablet remains 0.14.0. Physical touch/performance acceptance is pending. Everyday vocabulary and short phrases are the next content extension, not part of this checkpoint.

Run isolated Ukrainian PC preview:
`powershell -ExecutionPolicy Bypass -File tools/Start-Godot.ps1 --path . --scene tests/world_native_review.tscn`

Reproduce automated checks: `powershell -ExecutionPolicy Bypass -File tools/Test-World.ps1`.
