# QA Checklist

## Current desktop slice  -  completed

- [x] Headless import without final script/resource errors.
- [x] 346 foundation assertions passed, including live locale/navigation, parent access, data validation and Ukrainian glyph coverage.
- [x] 4,757 Animals assertions passed; most cover 90 generated sessions across three difficulty levels, not distinct manual test scenarios.
- [x] Twelve animal resources and English word/prompt paths validated; duplicate IDs and missing/unsafe references rejected.
- [x] English words retained under UK UI; bundled speech works with system fallback off.
- [x] Wrong answer retains the target; feedback guards prevent duplicate answer/task/session records; replay works.
- [x] Repeat instruction, leaving during feedback, parent-overlay pause and focus handling checked.
- [x] A viewport-injected ScreenTouch selected one card once. This is a desktop fixture, not an Android physical touch claim.
- [x] Actual local voice playback ducked music and restored its level after completion.
- [x] Separate processes restored settings, attempts, task counts and session counts.
- [x] All 214 speech clips matched hashes and PCM/signal/duration bounds. Audible pronunciation/voice preference remains a separate review.
- [x] 48 child-layout captures generated at 1280Г - 800, 1440Г - 810 and 1024Г - 768 in EN/UK; zero button-boundary issues; representative images/all twelve illustrations inspected.
- [x] Native desktop mouse playthrough: incorrect choice, retry, five correct tasks, completion, replay, repeat prompt, home/back and exit.

The current PC run uses native Godot, not an Android OS emulator. Tests use isolated save files. Historical Phase 1 APK verification is recorded in PHASE1_REPORT.md; no new Animals APK/device verification is implied.

## Pending review/polish

- [ ] User listening review of English/Ukrainian synthetic voice candidates, especially Ukrainian stress/tone.
- [ ] Review new animal illustrations and additional Foxie poses within the approved base style.
- [ ] Final voice/loudness/pronunciation polish across the finished content set.

## Pending Android finalization

- [ ] Build and inspect the current APK, including required voice/license material, signatures, ABI, SDK metadata and permissions.
- [ ] Install/open on the updated Redmi; record actual OS build, ABI and installed size.
- [ ] Fresh English/Easy defaults and saved UK/difficulty/audio settings after restart.
- [ ] Comfortable physical touch size, one response per tap and fast/slow interactions.
- [ ] Home/activity/game/parent navigation and Android Back/exit behavior.
- [ ] Parent hold/challenge, release interruption, focus/background interruption and cancellation.
- [ ] Saved attempts/tasks/sessions survive background/resume and process restart.
- [ ] Audio stops in the background, resumes correctly and does not leave music attenuated.
- [ ] Landscape/immersive mode, real safe areas and system gestures.
- [ ] Airplane-mode operation of bundled speech and all implemented mechanics; test optional system speech separately if enabled.
- [ ] Tablet speaker loudness/latency, memory growth and frame pacing measured on the named device.

## Remaining games

coloring regions and multitouch xylophone require their own implementation/tests. Their readiness is not established by the Animals suite.


## Colors / softer speech increment  -  2026-11-13

- [x] Shared foundation: 183 assertions; Animals: 4,757; Colors: 707; zero failures. Cross-process persistence passed.
- [x] 78 speech clips: format, hashes, non-silent bounded PCM and duration.
- [x] Colors render fixture: 42 captures, two locales and three aspect ratios, zero button-boundary issues; selected menu/explore/advanced screenshots visually inspected.
- [x] Native mouse: menu to Colors, word selection, find, wrong answer/retry and correct-answer advance. Completion/replay covered by integration tests.
- [x] Connected tablet authorized in ADB; read-only OS/API/ABI/display/storage queries succeeded.
- [ ] Tablet APK installation/runtime QA, subjective voice acceptance and pronunciation review.

## Feeding increment - 2026-11-13

- [x] Combined final checks: 214 foundation, 4757 Animals, 707 Colors, 2914 Feeding assertions; zero failures, cross-process persistence passed.
- [x] Food model sessions: 60 seeded sessions, five distinct requests each, 3/4/5 valid choices, incorrect/invalid/duplicate input guards.
- [x] Actual viewport mouse and synthetic touch: tap, outside/wrong/right drops, unrelated finger release, canceled touch, focus/overlay cancellation, replay and saved counters. Physical Android touch remains unverified.
- [x] 110 voice clips validated by checksum, format, non-silent signal, fade and duration.
- [x] 48 feeding renders: two locales, three aspect ratios, three difficulties plus drag highlight/retry/eating/complete; zero control/card-label boundary issues. Selected captures visually inspected.
- [x] Native desktop mouse drag: wrong food/retry and correct food/eating feedback; pending final UI polish was subsequently covered by final logic/render reruns.
- [ ] Tablet runtime, subjective voice/pronunciation acceptance, actual eating/touch/audio comfort.

## Shape Sorting - 2026-11-13

- [x] Final combined run: 235 foundation, 4757 Animals, 707 Colors, 2914 Feeding, 5094 Shapes assertions; zero failures. Cross-process persistence passed.
- [x] Shapes: 90 seeded model sessions / 270 boards, every session covers all six forms; unique pieces, shuffled orders, identity matching and full-board completion required.
- [x] Viewport mouse/synthetic touch: word repeat, outside/wrong/near-edge correct drops, unrelated finger, OS cancel, focus/overlay cancel, duplicate release, animated/reduced-motion snap, replay and stored counters.
- [x] 132 speech files matched hashes and PCM/signal/duration bounds.
- [x] 48 renders across two locales/three aspect ratios, menu/three difficulties/drag/retry/placed/complete; zero card/button/card-label boundary issues. Selected images visually inspected.
- [x] Native mouse: wrong contour returns, correct match stays, completion of the first board opens a different second board.
- [ ] Physical tablet input, audio preference/pronunciation, actual Android installation/runtime acceptance.

## Animal Puzzles - 2026-11-13

- [x] Final combined checks: 247 foundation, 4757 Animals, 707 Colors, 2914 Feeding, 5094 Shapes, 8473 Puzzles assertions; zero failures. Cross-process persistence passed.
- [x] 90 seeded puzzle sessions / 270 pictures: 2/4/6 nonoverlapping crops tile the source, no repeated picture within a session, every fragment required, wrong/duplicate placement guarded.
- [x] Actual AtlasTexture sizes/pixels compared against source regions at all difficulties; viewport mouse and synthetic touch cover outside/wrong/right drops, second finger, canceled touch, focus/overlay, hint/restart/next/replay, animation and persisted counters.
- [x] 142 speech files matched checksums, format, signal/fade and duration bounds.
- [x] 54 rendered captures across two locales/three ratios; menu, 2/4/6 pieces, drag, retry, partial, finished picture and session complete. Zero card/button/card-label boundary issues; selected images visually inspected.
- [ ] Physical tablet input/runtime, offline/lifecycle/performance and subjective voice acceptance.

- [x] Native puzzle review: wrong region returns the fragment, correct pieces reconstruct the bear, completion unlocks Next, next animal opens as picture2/3. Final desktop log showed no errors during review.

## Memory Match increment

- [x] Final combined checks:254 foundation,4757 Animals,707 Colors,2914 Feeding,5094 Shapes,8473 Puzzles,3031 Memory assertions;zero failures. Shared cross-process persistence passed.
- [x] 90 seeded memory boards:2/3/4 pairs, exactly two copies each, matching by ID, duplicate/third/matched-card guards and full-board completion.
- [x] Viewport synthetic touch and real-view controls: paused reveal, hold and hide guards, wrong pair closes, correct pair stays open, English repeat, stale-generation restart, exit during hold/hide, replay and saved actual pair counters.
- [x] Puzzles regression now navigates the actual second menu page and launches via its card; menu boundary controls and persistent companion checked.
- [x] All150 voice files passed checksum/format/signal/fade/duration validation.
- [x] 54 renders:both menu pages,2/3/4 pairs,first reveal,mismatch,matched pair,complete;two locales/three ratios,zero control/card-label boundary issues. Selected images inspected.
- [ ] Physical Android touch/offline/lifecycle/performance and subjective voice acceptance remain pending.

## Let's Count increment

- [x] Final combined run:317 foundation,4757 Animals,707 Colors,2914 Feeding,5094 Shapes,8473 Puzzles,3031 Memory,10875 Counting assertions;zero failures. Shared cross-process persistence passed.
- [x] 120 seeded count sessions across both modes/three difficulties:unique in-range targets,number option truth,duplicate/invalid IDs,underfill/overfill correction,exact confirmation and once-only completion.
- [x] Two-locale real-view viewport mouse/synthetic touch:rendered object cardinality,English prompts/numbers,rapid answers/checks,outside drop,focus/overlay cancellation,unique instance storage/return,overfill,replay/mode switch and saved actual practice counts.
- [x] 210 speech files passed checksum,PCM/signal/fade/duration checks.
- [x] 60 rendered captures:page2,three choice difficulties,basket5/10,drag,ten stored objects,retry,complete;EN/UK at three ratios,zero button/card-label boundary issues;selected images visually inspected.
- [x] Native mouse:wrong/right choice,mode switch,basket drag,count1,return to0,empty confirmation rejected.
- [ ] Physical tablet touch/offline/lifecycle/performance,subjective voice/pronunciation approval and final APK remain pending.

## Magic Drawing increment

- [x] Final combined suites: 346 foundation, 4757 Animals, 707 Colors, 2914 Feeding, 5094 Shapes, 8473 Puzzles, 3031 Memory, 10875 Counting, 420 Drawing assertions; zero failures. Counting's UI branch count can vary by one when a random first basket target is already the range maximum.
- [x] Pixel checks: continuous sparse-event line, eraser locality, soft/rainbow differences, exact undo/redo/clear restoration, clipping, history count/byte budget and stamp cache cap. Many drawing assertions sample continuous-line pixels, not independent manual cases.
- [x] Gallery: exact PNG reload/edit, preserved saved original, path/PNG dimension guards, entry/byte quotas, orphan recovery, draft backup fallback, newer-schema refusal and scoped deletion on isolated fixtures.
- [x] Viewport touch/real controls: pointer ownership, save deduplication, protected clear/replacement, gallery open/Back, child delete exclusion, parent route/delete confirmation, focus-interrupted stroke preservation.
- [x] Fresh write/read processes restored gallery and draft pixels; storage probe runs with its own muted settings to avoid unrelated startup audio teardown races.
- [x] 42 rendered images across EN/UK and three ratios, including scaled mouse-to-pixel checks, brushes, child/adult galleries and confirmation states; zero button-boundary issues, selected images inspected.
- [x] Native mouse: regular/rainbow strokes, undo/redo, save, gallery thumbnail and reopen; one review drawing retained in the normal local gallery. No native deletion performed.
- [ ] Actual Android drawing responsiveness/RSS/physical input, offline/lifecycle/performance and final APK acceptance.

Coloring0.11.0 desktop:1822 assertions pass, previous suites pass, isolated fresh-process semantic write/read passes. Render138 EN/UK captures at1280x800,1440x810,1024x768, zero boundary issues; ten-page contact sheet inspected. Native mouse verified independent fills, undo/redo, save/gallery/reopen; old Drawing retained. Physical touch, Android performance/lifecycle and final speaker/voice approval remain pending.

Xylophone0.12.0:86 isolated EN/UK assertions pass; all earlier suites/persistence pass. Eight simultaneous viewport-injected touch events produce eight correct streams; same-key ownership,cancel/outside release,slide/reentry,emulated-mouse dedup,overlay/focus cleanup,mute,100 rapid strikes and music restoration covered. check_instrument.py verifies eight fundamentals,format,edges and16-voice clipping bound.24 render captures,0issues; selected EN/UK images inspected. Native mouse click/slide reviewed, app left open. Subjective sound quality, physical touch, measured latency and Android performance remain pending.

## General PC review - 0.12.1

See RELEASE_REVIEW.md.39,813automated assertions pass,including1263cross-game checks. Parent Cancel bug reproduced60combinations andfixed. Settings/progress/artwork/coloring process persistence pass;228speech and8instrument notes validated. Content12JSON/318locale keys/343refs valid;allPowerShellhelpers parse.120general EN/UK render captures across3ratios,0issues;selectedimagesinspected. No Android/performance/airplane-mode or subjective voice acceptance. Per-game/topic progressUI,persistentstickers andfiveworldzonepresentation remain explicit differences. No personal gallery deletion.

2026-11-14 Android:0.12.1/code13export/signature/alignment/package/permissions/resourcechecks pass;installed Redmi andlaunchedmainloop,processalive,nostartupGodotscripterror/fatalexceptionfound. Actualgameplay/physicaltouch/performance/offline/listeningapprovalpending. See TABLET_BUILD_REPORT.md.

UX0.13.0 PC-only: prior chain andcontent/audio checks pass;633UX assertions pass after fixing touch pan anddelayed scroll restore.180render captures,0issues;selected full images inspected. NativeUK menu mousepan,Drawing icons/stroke/idlefinger reviewed in isolated fixture.356speech clips validated;userlistening anddeviceacceptance pending. No tablet commands/export/install. SeeUX_REPORT.md.

Completion0.14.0: full41,000assertion chain passes,including547celebration checks across7games×2locales×3difficulties.24captures,0layout issues. Distinct/canceled/repeatedtouches,pause,all-six gating,idleguide,cleanup andscore invariants checked. No tablet operations. SeeCELEBRATION_REPORT.md.


## Android 0.14.0 installed - 2026-11-14

User connected tablet and authorized update. Redmi25099RP13G/flute re-enumerated as authorized. Previous installed0.12.1/code13 updated to0.14.0/code15 with install --no-incremental -r (Success). Initial default incremental/streamed attempt failed with an empty diagnostic; explicit non-incremental retry succeeded. No uninstall,clear-data or device settings changes. Update semantics preserve existing private app data; individual artwork contents were not inspected.

APK35,151,396bytes (33.52MiB),SHA256BBC5BA639D7080C7EBCE3934C488230269E46C10047B03775DDEC5F79FAC8844. Signature,alignment,package/ABI/min24/target36,permissions andrequired resource checks passed.358speech+8instrument import targets andballoon-pop resource packaged. Installed version confirmed by package manager. Launcher GodotAppLauncher opened GodotApp,Statusok,cold start606ms/Wait641ms (activity-launch timing,not input latency). App left open for user review. Startup log .local/logs/tablet-014-launch.log; no full physical-gameplay/performance acceptance implied. Current update includes virtual scrolling,full Ukrainian Tetiana speech,idle finger hints,icon tools andsix-balloon completion.

Feedback0.15.0:full41,742assertion chain passed;final focused226checks passed cleanly,including expandedpalette callback/diskreload andrapidsecondpickup.66render captures,0button-boundaryissues;selectedimagesinspected. Native alphabet/syllable/freepop reviewed.443speech checks pass;subjective audio/deviceperformance pending. No tablet updates thisincrement.

Learning/body0.17:seeLEARNING_BODY_REPORT.md for full regression and final focused498Feedback/940World assertions,171+96captures,59card correspondence review,andseparate technical versus user-listening/device acceptance limits. No tablet update in this increment.

Personalization0.18:completeTest-Friends chain passed,including368newselection/geometry/balloon assertions and59individual letter signal/phoneme checks.106render captures/zero boundary issues;seePERSONALIZATION_REPORT.md for evidence and manual-listening/device limits.

Scroll/paint0.19:36focused gesture/drawing checks passed;54render captures/0boundaryissues. Casesinclude sliders,duplicate mouseevents,multiple/canceledcontacts,inertia stopping,palette swipe/tap andtouchink. Full regression tracked in.local/logs/scroll-paint-full.log;seeSCROLL_PAINT_REPORT.md. Physical Android feel pending.
