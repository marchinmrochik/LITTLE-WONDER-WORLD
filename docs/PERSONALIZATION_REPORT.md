# People, companions, balloons and letter speech — 0.18.0

2026-11-14. PC checkpoint. User authorized a replacement human illustration, a matching girl with selection, a companion row with about ten additional animals, an individual audit/fix of every letter recording, and exactly1.5x free-balloon speed/2x count. Source0.18.0/future Android code20; tablet remainsinstalled0.17.0/code19. No tablet operations, APK export or Git actions in this increment.

## People

The boy approved by the user in chat and a matching girl replace the geometric figure. Original transparent1024x1536PNG assets are stored unchanged at assets/objects/people/boy.png (1,901,261bytes) and girl.png (1,885,898bytes). Built-in image_gen produced both; exact prompts are in PEOPLE_GENERATION_PROMPTS.md. No CLI/API key was used for images. Reference study considered educational body illustrations at https://www.vectorstock.com/royalty-free-vectors/body-parts-kids-vectors and https://es.123rf.com/photo_94695798_diccionario-visual-de-dibujos-animados-para-ni%C3%B1os-sobre-el-cuerpo-humano-partes-de-mi-cuerpo-para-un.html ; no stock artwork was downloaded or bundled.

Both figures have naturally posed open hands with five digits and continuous palm/wrist silhouettes, natural bare legs/feet, eyebrows and detailed faces. Portrait buttons choose boy/girl without requiring reading. Selection persists in settings. Twenty voiced body parts retain their identifiers. Each sprite has its own reviewed hit geometry in data/game_content/body_characters.json, with full-body, face and hand views. Body topic revision3 keeps comparisons separate from older geometry revisions. Word assembly uses AtlasTexture regions from the selected sprite; it no longer shows the old SVG body crops.

## Companions

The home screen has a horizontal scroll row with fox plus cat,dog,rabbit,bear,lion,elephant,duck,pig,sheep,horse:eleven total. Existing original game art is reused. Selection changes the large home portrait, meadow/celebration companion and a compact64px companion beside navigation throughout the app. It does not cover play areas. Existing gentle motion/reduced-motion behavior is retained. New companion and body_character settings are optional for reading legacy settings; invalid IDs are rejected. Both choices were verified across separate write/read processes.

## Balloons

Free play now has12 independently recycled balloons (previously6), with upward speed39–66logical pixels/s (previously26–44), exactly1.5x. The six-balloon task-completion party remains its separate existing interaction. Initial distribution now waits for container layout, preventing a narrow left-side cluster. Random color/size/position,sway,pop burst,pause and bounded recycling remain.

## Every letter recording

Audited26EN+33UK clips individually. The previous English source spelling Ay was confirmed by the actual eSpeak frontend to produce /aɪ/, while A must produce /eɪ/. Corrected English jobs to literal letters and checked all26 against an explicit expected pronunciation table. Earlier short clips also had inconsistent durations and long tails:for example ENN3.33s,ENS2.24s,ENZ3.18s.

All59 names were regenerated from the existing licensed Cori/Tetiana weights. The development backend exposes the model's phoneme-duration output, synthesizes a short contextual phrase, then keeps only the letter span. The contextual phrase is absent from gameplay audio. Minimum duration and reduced stochastic duration variation stabilize short vowels; EnglishX gets a clearer sustained vowel. Per-clip phonemes,source bounds,inference settings and extraction method are recorded in the voice manifest. The source models are unchanged; augmented graphs remain under.local/letter-models and are not shipped.

Final individual-letter durations0.423–0.713s. All59 pass voiced-signal and expected-phoneme checks; X has270ms of voiced content after refinement. This is technical and phonetic-source verification,not a claim that every file was manually listened to or independently recognized by ASR. Final subjective pronunciation still needs listening. A separate player for each of the59 recordings is available at.local/qa/letter-audio/listen.html, alongside audit.csv,audit.json and the before.json snapshot. Pre-change letter files are retained in.local/voice-backup/letters-017.

The whole voice pack remains614clips,34,215,400bytes,0.42–4.76s; format/checksums/signal checks passed. The other game voices/music remain unchanged. Implementation references: https://github.com/rhasspy/piper/discussions/425 and https://onnx.ai/onnx/intro/python.html .

Development-only dependencies were installed locally under.tools/python-audio:NumPy2.5.4,ONNX1.23.2,ONNX Runtime1.32.0 plus their dependencies. Pin file:tools/requirements-audio.txt. No new voice model downloads. ONNX Runtime telemetry is disabled. Runtime app still contains only finite audio/images/data; these libraries and modified models do not enter the APK.

## Verification

Full tools/Test-Friends.ps1 chain passed:foundation633,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3031,Counting10875,Drawing420,Coloring1820,Xylophone86,release2067,UX834,celebration547,Feedback498,World940,Friends368; zero failures. Cross-process settings/progress/artwork/coloring/history probes passed. The initial full run stopped on a persistence-probe audio-shutdown resource warning; the probe now applies reloaded settings and lets startup audio settle before shutdown. The complete repeated chain passed cleanly.

Friends tests cover all11 companion choices in both locales, immediate/header/game persistence, both human choices and all20 real touch targets per locale, selected-character word atlases, legacy/invalid settings,12balloons,exact speed range and the initial distribution width.106 final rendered captures cover EN/UK at1280x800,1440x810,1024x768,home first/last pets,all companions,people full/face/hand/check states,word atlas and balloons;zero button-boundary issues. Selected captures were visually inspected. Source validation:18JSON documents,582keys per locale,794resource references,zero errors.

Logs:.local/logs/friends-full-final.log,friends-tests-final.log,friends-render.log,letter-audio-after.log. Physical Android touch/performance and user voice preference remain unverified for this version.

Run isolated Ukrainian preview:
`powershell -ExecutionPolicy Bypass -File tools/Start-Godot.ps1 --path . --scene tests/friends_native_review.tscn`

Next:user PC/listening feedback or explicitly requested tablet update. Do not overwrite the approved PNGs by regenerating geometric art; prepare_people_layout.py restores the active people metadata after historical content helpers.
