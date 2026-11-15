# Implementation Plan

Status: Phases 0-1 complete; Phase 2 baseline and Phase 3 Animals desktop slice delivered for review; phases 4-7 pending. Date: 2026-11-13. Current evidence is in `ANIMALS_REPORT.md`; `PHASE1_REPORT.md` and `ENVIRONMENT.md` are historical checkpoints.

## Delivery rules

Implement complete, reviewable increments. After each increment record changed files, executed checks, actual results, limitations and next task. Stop at agreed review gates before expanding scope. Never present placeholder art, fallback speech, a desktop check or an export-only result as finished production/device evidence.

## Phase 0  -  Setup and audit completion

- Install/locate pinned Godot and export templates; verify versions.
- Prepare Java/Android SDK, review licenses and set export paths.
- Ignore generated artifacts. Local Git was initialized before the user clarified that Git setup is deferred; do not create commits, configure identity/remotes or connect hosting. The user owns all further Git setup.
- Record tool versions and device target. Preserve the source brief as project requirements.

Exit: editor/headless executables run; Android export dependencies are identified with concrete results.

Completed evidence: pinned Godot and Java run; Android SDK and matching templates are installed; headless editor/runtime probes pass; an ARM64 service APK was exported and its signature verified. Final artifact metadata and ZIP alignment were also checked. No tablet execution occurred. No application source was created. The original brief is preserved byte-for-byte under `docs/requirements/MASTER_PROMPT.ru.md`.

## Phase 1  -  Foundation and early Android probe

Build AppRoot, navigation, game registry, English/Ukrainian localization, settings/progress storage and audio buses. English/Easy are first-run defaults. Add parent barrier, volume controls and safe-area layout. Avoid empty future game buttons.

Check startup, settings reload, switching languages without restart, corrupt-save recovery and desktop layout at 16:10, 16:9 and 4:3. Export a minimal debug APK immediately. Install/launch on the tablet when available; otherwise explicitly leave device verification pending.

Exit: runnable shell with proven persistence and an early export result.

Completed: running Godot app, home/meadow navigation, parent hold/challenge, EN/UK, first-run English/Easy, independent audio controls, optional reduced motion, versioned settings/progress, backup recovery and an ARM64 debug APK. Validation: 118 checks passed; separate-process persistence passed; 18 rendered desktop screenshots across three aspect ratios and two locales were generated/reviewed; native UI navigation, parent challenge, language switching, slider and scrolling were exercised. APK export/signature/ZIP alignment/metadata/permissions/assets checks passed. Android device checks remain deferred. Empty educational sections are hidden until real games are registered. The companion meadow is not counted as one of the ten games.

## Phase 2  -  Visual and content baseline

Create the palette/theme, child buttons, card states, world-map composition, Foxie's first states, reusable feedback and reduced-motion behavior. Create an Animals art batch and EN/UK voice samples before producing the full set. Establish asset IDs, licenses and content/audio manifests.

Review gate: user sees actual rendered home/Animals visuals and hears proposed voices. Approve style before broad asset production. More Foxie states can follow using the accepted design.

Current outcome: user approved the existing graphics/music and requested PC review until final tablet work. The approved meadow/palette/music are retained. Twelve original animal vectors, seven Foxie states, activity/choice cards and 52 finite EN/UK synthesized speech files are prepared. Voices are candidates for listening review, not approved actor recordings or final pronunciation QA.

## Phase 3  -  Learn Animals complete slice

Implement twelve animals; exploration, English word playback, find mode, difficulty-appropriate choices, repeat instruction, feedback, replay, home navigation and saved practice. Use real touch and full EN/UK UI. Supply local speech or explicitly flag temporary missing/fallback audio.

Test actual choice logic, data references, language changes, repeat tapping, leaving during feedback, persistence and airplane mode on Android.

Review gate: a playable APK, verified desktop checks and separately documented device checks. Do not mass-produce other games until this slice is usable and visually accepted.

Updated review gate by user instruction: review the playable native Godot desktop build now; defer Android export/device acceptance to the mobile/final phase. The desktop slice has exploration, find/repeat, 2/3/4 choices, five-task rounds, gentle retry, completion/replay and saved practice. Evidence and limitations are in `ANIMALS_REPORT.md`. The retained Phase 1 APK is not updated/current.

## Phase 4  -  Remaining nine games

Order is based on reuse and technical risk, not the original numbering.

| Order | Game | Required increment and acceptance evidence |
| --- | --- | --- |
| 1 | Learn Colors | Desktop increment delivered in 0.4.0; eight colors, exploration/search/repeat, five-task sessions, saved progress. See COLORS_REPORT.md. Tablet acceptance pending. |
| 2 | Feed the Animals | Desktop increment delivered in 0.5.0; twelve foods, 3/4/5 choices, owned drag/drop, cancel/retry/eating/replay and persistence. See FEEDING_REPORT.md. Tablet acceptance pending. |
| 3 | Shape Sorting | Desktop increment delivered in 0.6.0; six forms, three shuffled boards, identity matching, snap/return, names and persistence. See SHAPES_REPORT.md. Tablet acceptance pending. |
| 4 | Animal Puzzles | Desktop increment delivered in 0.7.0; six pictures, 2/4/6 real crops, hint, snap/return/restart, three-picture sessions and persistence. See PUZZLES_REPORT.md. Tablet acceptance pending. |
| 5 | Memory Match | Desktop increment delivered in 0.8.0; 2/3/4 pairs, guarded flips/holds/hides, replay, lifecycle cleanup and saved counters. See MEMORY_REPORT.md. Tablet acceptance pending. |
| 6 | Let's Count | Desktop increment delivered in0.9.0;1-5/1-10,four themes,choice/basket modes,unique-object exact checks,English numbers and progress. See COUNTING_REPORT.md. Tablet acceptance pending. |
| 7 | Magic Drawing | Desktop increment delivered in 0.10.0; nine colors, brushes/eraser, continuous strokes, bounded undo/redo, guarded clear, editable PNG saves/draft/gallery and adult deletion. See DRAWING_REPORT.md. Tablet acceptance pending. |
| 8 | Coloring Book | Desktop 0.11.0 delivered: ten original pages, independent regions, palette, bounded undo/redo, protected reset, semantic draft and editable PNG gallery. See COLORING_REPORT.md; tablet acceptance pending. |
| 9 | Magic Xylophone | Desktop0.12.0 delivered: eight original tuned notes,16 bounded voices, independent touch/slide, parent SFX volume, focus/overlay cleanup. See XYLOPHONE_REPORT.md; physical multitouch pending. |

Run a focused check and update progress after every game. Prototype the risky drawing and multitouch techniques early if the first device pass reveals constraints; do not open unfinished activities in the child menu.

## Phase 5  -  Content and audio finish

Complete Foxie's seven states, consistent world art, illustrations, coloring masks, prompts, vocabulary audio, SFX, music and instrument samples. Normalize perceptual loudness, check Ukrainian wording and English pronunciation, verify reduced motion and stop voice overlap. Separate code readiness, art readiness and audio readiness in manifests.

Exit: no untracked placeholder or missing required resource; each bundled asset has known provenance and redistribution rights.

## Phase 6  -  Full Android QA and polish

Run headless project checks, content/translation validators, pure game logic tests and persistence tests. Perform rendered checks at all target ratios. On the real tablet cover all ten games, multitouch, fast/slow/cancelled drags, saves/gallery, language changes, airplane mode, background/resume, Android Back, navigation/system gestures and repeated sessions.

Measure frame pacing, memory growth and sound responsiveness on the named device. Target 60 FPS where supported; do not claim universal performance. Confirm the release export has no unnecessary permissions or unintended network dependencies.

Exit: no known blocking failures; list all remaining nonblocking limitations and exactly what was tested.

## Phase 7  -  Deliverable build and handoff

Produce and verify a debug APK plus the complete Godot source. Record engine/tool versions, export command result, APK location and device results. Provide launch/install steps and update README, ARCHITECTURE, IMPLEMENTATION_PLAN, DESIGN_SYSTEM, GAME_DESIGN, CONTENT_MANIFEST, AUDIO_MANIFEST, ANDROID_BUILD and QA_CHECKLIST to match reality. Release signing/store publication is a separate task.

## Overall acceptance

All ten games have working mechanics and replay/home paths; EN/UK switch live and persist; learned words stay English; drawings and individual coloring regions save correctly; puzzle/sorting touch and instrument multitouch work; progress survives restart; main functions run offline; layouts fit the target tablet; no blocking bugs. Any unfinished final voice or artwork remains explicitly disclosed rather than hidden by technical completion.

## Next task

PC0.15.0 feedback pack is implemented andverified:25colors/6gradients,immediate next-piece pickup,26EN/33UKletters,beginning syllable assembly andstandalone balloon play.13activities. Review user PC feedback andspoken letter/blend quality next. Tablet remains0.14.0;do not export/install0.15until requested. Known earlier progress/sticker/worldzone follow-ups remain separate. SeeFEEDBACK_PACK_REPORT.md andCONTINUATION.md.

Latest checkpoint: World0.16.0 implemented and verified in EN/UK. See WORLD_REPORT.md. Next: user PC/listening review, then everyday vocabulary/phrases as a separate extension. Tablet remains0.14.0; no update in this increment.

Latest0.17.0 supersedes prior syllable/alphabet plans:locale-bound letters/picture cards,random illustrated words86EN/93UK,and20-part detailedbody completed onPC. User acceptance/listening next;tablet remains0.16.0. SeeLEARNING_BODY_REPORT.md.

Latest0.18.0 PC increment completed:approved boy+matching girl,11persistent companions,12free balloons at1.5x speed,and59individually checked letter recordings. SeePERSONALIZATION_REPORT.md. Next user PC/listening review or requested tablet update;installedtablet0.17.0 remains unchanged.

Latest0.19.0 PC increment:unifiedcontent scrolling,homepetgrid,149paintchoices,compactsidecontrols/largerdrawingpaper. SeeSCROLL_PAINT_REPORT.md. Tablet remains0.18.0;next PC gesture/layout review or requesteddeviceupdate.


## Living drawings prototype - complete on PC

0.20.0 adds one guided house with six parts, ten strokes, zoom, completion celebration and interactive final scene in EN/UK. Gallery expansion awaits user review. Verification and limits: LIVING_DRAWING_REPORT.md. Tablet installation is outside this increment.


## Living yard 0.21.0 - supersedes task-style prototype

One open-ended House and yard story in a child-accessible gallery, Back to stories, session-only drawing restoration, marker-only undiscovered elements, wider ink/leader and half-density dots. Six house parts unlock four freely chosen sun/cloud/dog/flower elements. Continuous colored smoke, day/night, rain, barking/running puppy and butterflies; no task result, score or final party. Add more scenarios only after this mockup is reviewed.


## Seasonal stories0.22 - complete on PC

Added Spring/Autumn/Winter,12interactiveactors each;gallery4stories,categorycatalog4columns. Freeballoons another1.5speed,closedtracingmousefixwithbothdirections. No newdependencies/tabletops. See SEASONS_REPORT.md. NextuserPCreview or explicitlyrequestedtabletupdate.


## Symbol repetition and Ukrainian speech0.23 - complete on PC

Alphabet third Trace tab with Letters/Numbers,26EN/33UKuppercase/digits0-9,endlessshuffle,noending/score;nameaudio+smallfireworks+automaticnext. Replacedall369UKclipswithTetianaHigh+authoredstress/explicitletternames;preserved339oldENclips. SeeSYMBOL_TRACING_VOICE_REPORT.md. NextPC/listeningrevieworrequestedtabletupdate.


## Layout/categories0.24 - complete on PC

DigittracingmovedoutofAlphabetintoNumbersandcountingwithHowmany/Basket/Trace digitstabs;Alphabetletter-only. Drawinglefttools/rightpalette-actions/footerlayout,fullyvisiblepaper. Targetedchecks/renderreviewpassed;seeLAYOUT_CATEGORIES_REPORT.md. No tabletupdate.


0.25optionalEN→UKwordcaptionscompleteonPC,parentLanguageOn/Off,defaultoff,persistent,text-onlyheadercard. VoiceEnglishandallpriorfeaturesretained. Focusedchecks/renderspassed;seeWORD_TRANSLATIONS_REPORT.md.
