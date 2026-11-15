# Continuation checkpoint

Updated for desktop 0.15.0, 2026-11-14. Read first for "continue" / "продолжай". Main plan: docs/IMPLEMENTATION_PLAN.md. Current report: docs/FEEDBACK_PACK_REPORT.md.

## Persistent user decisions

- Native Windows Godot development/review now; real tablet acceptance later. Retain approved base graphics/music.
- Softer/more pleasant speech requested. English Cori and gentler processing delivered; user listening/pronunciation approval pending. Ukrainian Lada retained with softened processing.
- Tablet USB debugging approved earlier; read-only ADB readiness verified then, no APK installation.
- Preserve progress across token renewals. Continue the next unfinished game, not completed phases.
- Private/local APK only, no Google Play/accounts/backend/ads/analytics. Git setup/identity/remotes/commit/push belongs to the user; do not do it.

## Verified baseline: source 0.15.0 / future Android preset code 16

All ten educational games delivered on desktop plus meadow:

1. Animals: 12 originals, exploration/English word/find/repeat, 2/3/4 choices, five targets, completion/replay and saved counts.
2. Colors: eight colors, two pages, shared Animals controller through game_id/text_prefix, separate progress.
3. Feeding: 12 foods, 3/4/5 choices, owned drag/drop, eating/retry/cancel, five requests and feeding counts. Fantasy vocabulary, not real-animal diet matching.
4. Shapes: six forms, three boards, 2/3/4 pieces, all six IDs per session, shuffled orders, identity snap/return and progress.
5. Puzzles: six animals, three pictures/session, actual AtlasTexture 2/4/6 crops, hint/restart/next, full-piece gating, progress.
6. Memory: twelve familiar images, 2/3/4 pairs, guarded reveal/hold/hide, matching stays, mismatches close, stale-token restart and counts.
7. Counting: four themes, 1-5/1-10, choice and unique-instance basket modes, English numbers, explicit exact quantity checks and progress.
8. Magic Drawing: nine colors, three widths, regular/soft/rainbow/eraser, fitted 1024x640 raster page, interpolated clipped strokes, undo/redo, protected undoable Clear, Save, draft/backup, editable PNG reopen and child/adult galleries. No fabricated correct-answer scores.

Historical Drawing combined run passed: 346 foundation, 4757 Animals, 707 Colors, 2914 Feeding, 5094 Shapes, 8473 Puzzles, 3031 Memory, 10875 Counting, 420 Drawing assertions. Counting's UI branch count can vary by one for random first-basket targets; all current checks passed. Many drawing assertions sample continuity pixels, not separate manual cases. Shared cross-process settings/progress passed; new artwork write/read processes restored exact decoded PNG and draft pixels. All 214 speech clips passed format/hash/signal/duration checks.

Drawing pixel tests include clipping, continuity, brushes, exact undo/redo/clear, bounded memory, PNG edit/original preservation, quotas, path/IHDR guards, orphan/draft recovery, future-schema refusal and isolated deletion. Viewport touch verifies ownership, fitted coordinates, clear/open protection and interrupted-stroke draft preservation. Physical Android input remains unverified.

Drawing renderer produced 42 EN/UK captures at 1280x800,1440x810,1024x768, zero button-boundary issues; scaled mouse input checked against real pixels. Selected canvas/gallery/confirmation images inspected. Native mouse: regular/rainbow lines, undo/redo, save, thumbnail gallery and reopen. One test drawing remains in normal local gallery. No native deletion. At the Drawing checkpoint the app was left on that canvas; current state is documented in Coloring below. Log .local/logs/desktop-drawing.log showed no errors.

Drawing checkpoint (historical): 214 local PCM clips, 12,722,994 bytes, duration 0.66-2.74s. Drawing added four DRAW_ helpers, preserving 210 older clips. English en_GB-cori-high revision375a0fe641dea077c2a47b4e9a056d6da521eed3, UK uk_UA-lada-x_low revision6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3. Same verified model provenance, pacing1.12, peak.46,4500Hz smoothing. Models stay PC-only; audio size is not APK/installed size. Final voice preference pending.

No new dependencies/downloads, tablet operations, APK export/install or Git operations. Historical Phase1 APK0.1.0 does not contain current games.

## Next: desktop release/content review, then coordinated tablet acceptance

All ten games are COMPLETE as desktop increments. User explicitly says do the next step and tablet later when ready. Do not restart Xylophone or export/install to tablet without moving deliberately into final device work. Next continue: review overall desktop release/content/audio checklist, resolve any concrete gaps, then prepare a current Android build/checks and coordinate tablet availability for acceptance. Final voice/instrument listening preference needs user feedback. Physical8-finger multitouch, measured latency,FPS,memory,lifecycle/offline/private save acceptance remain unverified.

## Drawing architecture / bounds

- PaintDocument: RGBA8 1024x640, native blend_rect cached stamps, interpolated/clipped segments. Before/after changed-region history, max24 transactions and32MiB combined undo/redo payload. One active pre-stroke image, stamp cache64; texture uploads once/frame.
- Raster PNGs remain editable on reopen; history is session-only, not vector-stroke persistence. Clear adds an undo transaction. Reopening dirty current work needs confirmation.
- ArtworkManager autoload: private user://artwork, version1 index, gallery max24 entries/64MiB PNG+staged storage, each PNG max4MiB/exact IHDR dimensions checked before decode. Immutable new saved copies, orphan PNG recovery, newer index blocks writes. Fixed draft plus validated backup/staging are separate from gallery quota. Not a universal crash/power-loss guarantee.
- Draft after strokes is debounced .65s; focus/overlay/navigation commits visible active strokes and flushes. Write failures surface in UI. No learning scores awarded for drawing.
- Child ArtworkGallery opens without delete. Adult settings -> locked gallery route supports confirmed delete/open. Root Back closes child gallery first. Reset learning progress does not delete artwork.
- Parent gallery and settings both require parents_unlocked; navigate preserves unlock only within those two routes. Opening a drawing leaves adult mode. ArtworkManager.pending_open_id passes the selected picture to Drawing.
- Gallery thumbnails 192x120; existing PNG original never silently overwritten. One saved native review image is real local data; don't remove it casually.

## Menu / source / commands

Menu PAGE_SIZE4, 2x2 cards + persistent companion footer. Page1 Animals/Colors/Feeding/Shapes; page2 Puzzles/Memory/Counting/Drawing. Coloring occupies page3. Tests/fixtures that assume page2 is last must be adapted, preserving actual route checks. GameManager.activities_page is process-local and retained on locale rebuild.

- Play: tools/Run-App.ps1. Current combined checks: tools/Test-Release.ps1 (all prior suites, coloring and separate artwork/coloring processes).
- Render: tools/Start-Godot.ps1 -GodotArguments @('--path',(Get-Location).Path,'--scene','tests/drawing_render_review.tscn'). Godot user -- args need an explicit array so PowerShell doesn't consume them.
- Drawing: scripts/games/{paint_document,magic_drawing}.gd, scripts/components/{paint_canvas,artwork_gallery}.gd, scripts/core/artwork_manager.gd, scripts/settings/parent_gallery.gd; scenes/games/magic_drawing.tscn and scenes/settings/parent_gallery.tscn.
- Artwork probe uses its own SettingsManager.storage_path and music disabled/applied before testing. Initial audio playback teardown caused transient leaked-music refs while creating the probe; fixed in probe setup only, production audio unchanged. Final Test-Drawing run passed cleanly. Keep read/write processes isolated from user data.
- Prior source: CountingRound/lets_count.gd; MemoryRound/memory_match.gd + memory_card.gd; PuzzleRound/animal_puzzles.gd; ShapeBoard/shape_sorting.gd. Shared PointerDrag uses pointer_owner (Node.owner reserved), DragCard/FoodCard alias. Animals/Colors share learn_animals.gd; AnimalCatalog handles activity catalogs.
- Runtime JSON data/game_content and locales data/localization/{en,uk}.json. voice_jobs development-only. Explicit UTF-8 on Windows always (older default cp1251 punctuation corruption was repaired in current docs).
- Helpers prepare_*_content.py preserve other activity prefixes. New tools/prepare_drawing_content.py rebuilds DRAW_ voice entries from authoritative checked-in locales. Voice generation --prefix DRAW_ preserves other clips; full regeneration needs playing apps closed.
- Evidence/logs/saves ignored .local/, tools/models ignored .tools/. Normal artwork .local/windows-appdata/Godot/app_userdata/Little Wonder World/artwork/. Retain .local for pictures/saves.
- Future Android helper output build/android/little-wonder-world-debug.apk, ARM64,0.12.1/code13. No current build produced; private artwork must never be bundled from .local.

## Earlier tablet readiness

ADB authorized; shell reported model25099RP13G/flute, Android16/API36,arm64-v8a,physical1600x2560,/data58G free. Recheck before device work. Earlier USB access is not installation/runtime acceptance. No personal files inspected/settings changed. Offline audio, touch/multitouch/lifecycle, frame pacing, memory and actual drawing responsiveness remain pending. See TARGET_DEVICE.md.

Preserve work in project reports/checkpoint, not global memory without a separate explicit request.

## Coloring delivered / current verification

9. Coloring Book: ten original pages Cat/Dog/Fox/Butterfly/Fish/House/Flower/Car/Dinosaur/Rainbow, stable independently fillable regions, nine colors plus white, bounded64 undo/redo perpage, protected undoable reset, English nouns, allpage draft, semantic editable saves in shared gallery. Source0.11.0/preset11; no current APK exported.

Final Test-Coloring wrapper passed: foundation366, Animals4757, Colors707, Feeding2914, Shapes5094, Puzzles8473, Memory3033, Counting10875, Drawing420, Coloring1822; zero failures. Separate Artwork and Coloring write/read process checks passed. Voice pack228 valid non-silent PCM clips,13,421,964bytes,0.66-2.74s. Fourteen BOOK_ clips preserve prior214. Render138 EN/UK screenshots across3ratios, zero button-boundary issues. Allten pages inspected on contact sheet, selected full-size views reviewed. Updated colored butterfly menu icon checked natively.

Native mouse verified page3 entry, Cat independent red belly/blue head, undo/redo, Save/shared gallery/reopen. Existing Drawing remained alongside it. One saved native Coloring and one earlier Drawing are normal private user data; do not delete them casually. App left open on reopened Cat. Enumerate fresh windows for future review; .local/logs/desktop-coloring.log clean at check.

ColoringDocument/scripts/games/coloring_document.gd loads data/game_content/coloring.json; helper tools/prepare_coloring_content.py authors SVG/polygons/locales/voice jobs. ColoringBook/coloring_canvas implement UI/input. Optional entry.coloring in ArtworkManager indexschema1 is validated and routes Coloring vs Drawing; old PNGs unchanged. Orphan PNG without metadata reopens as plain raster Drawing, not semantic regions. Separate coloring-draft.json via JsonStore stores max10 page states and refuses newer schemas. Saved copies immutable; dirty replacement asks. No invented learning scores. Colors/history retained perpage, one current texture. Stable regionIDs matter for saved metadata compatibility.

Focused tests: tools/Test-Coloring.ps1, tests/coloring_tests.tscn, coloring_probe.tscn (write/read args), coloring_render_review.tscn. Logs .local/logs/coloring-{tests,write,read,render}.log; images .local/qa/coloring/all_pages.png and captures. See COLORING_REPORT.md. No new dependencies/downloads, Git or tablet operations this increment. Desktop evidence does not establish Android FPS/memory/multitouch/lifecycle/offline acceptance.

## Xylophone delivered / latest verification

10. Magic Xylophone: source0.12.0/preset12. Eight large pastel keys C5,D5,E5,F5,G5,A5,B5,C6; eight original mono PCM16bit44.1kHz1.7s tones,1,199,872bytes total. tools/prepare_xylophone.py authors audio/menuSVG/localizedcopy, no downloads. Speech unchanged228clips/13,421,964bytes. No educational scores or persistence needed for free play.

scripts/components/xylophone_keyboard.gd: ID→key owners, same-key fingers independent, key-transition glissando/reentry, excludes gaps/outside, releases canceled/outside pointers, emulated mouse filtered. Held visual+decaypulse, reduced motion disablespulse. scripts/games/magic_xylophone.gd: preloaded8streams,16AudioStreamPlayers on SFX bus, gain0.095; reuse idle/cursor-steal pool, no per-note node allocation. Parent Sound effects volume controls notes; no new settingsschema. Overlay/focus stops voices/clearsowners; exit restores meadow music level. AudioManager instrument_active silences meadow while gameopen.

Final Test-Xylophone.ps1 passed: foundation369,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3033,Counting10875,Drawing420,Coloring1822,Xylophone86; all zero failures. Artwork/Coloring/settings/progress separate process persistence pass. check_instrument.py validates tuning,PCM,envelopes and worst-case16voice peak0.899<1. tests/xylophone_tests.tscn injects actual viewporttouch events for8simultaneous streams,samekeyownership,slides,cancel/outside,dedup,overlay/focus,mute,100rapidstrikes,musicrestore. No physicaltabletclaim.

Render tests/xylophone_render_review.tscn generated24screenshots acrossEN/UK,1280x800,1440x810,1024x768;0issues, actual8keyinput verified at eachsize. Selected full images inspected. Native mouse thirdpagecard,individualCclick and slideacrosskeys reviewed. Old earlier application instance closed via normal Exit; current app leftopen on Xylophone. Enumeratefresh windows; no hardcodedhandle. .local/logs/desktop-xylophone.log clean atcheck. Audio preference not established by screenshots/signaltests.

Evidence .local/logs/xylophone-{full,tests,render,import}.log and .local/qa/xylophone. See XYLOPHONE_REPORT.md. No Git,downloads,tabletcommands,APKexport/install thisincrement. Preserve existing two native gallerypictures. Do not modify globalmemory without separate explicit request.

## Overall desktop review completed - latest checkpoint

User requested general review, tablet still deferred. Source0.12.1 / Android preset13. See RELEASE_REVIEW.md for exact evidence/limits. Fixed real cross-game bug: parent gate Cancel emitted dismissed but AppRoot never connected it, leaving all ten games overlay-paused. New tests/release_tests.tscn reproduced60 failures (10games×2locales×3difficulties); one-line gate.dismissed.connect(close_modal) restores shared cleanup. Repeated fixture now1263checks/0failures, including actual Cancel button,allmenuentries,routeguards,localvoiceavailability,no retained scene-node growth and immediate volume flush on departure. Updated outdated difficulty hint in EN/UK; unchanged spoken audio.

Final tools/Test-Release.ps1 chain passed369foundation,4757Animals,707Colors,2914Feeding,5094Shapes,8473Puzzles,3033Memory,10875Counting,420Drawing,1822Coloring,86Xylophone,1263release=39,813assertions,0failures. All separate-process persistence and228speech/instrument checks pass. check_release_content.py separately passed12JSON,318matchinglocale keys/placeholders,343concreteresourcereferences,0errors; no network/browser classes found by limited static scan. Not airplane-mode/device proof. AllPowerShellhelperASTparsepassed.

Release renderer tests/release_render_review.tscn covershome,3menupages,all10gamesatAdvanced,meadow,parentgate,settingstop/middle/bottom,adultgallery inEN/UK and3ratios;120screenshots/0issues. Selected fullscreens inspected; scrollchildren legitimately clip. Final render rerun includes newdifficultyhint. Logs .local/logs/release-{full,tests,before-fix,render,content}.log; captures.local/qa/release. No APK/device/Git/downloads. Earlier native instance closednormally; latestnormal app launched with log.local/logs/desktop-release.log, not isolatedtestsettings. Existinggallerypreserved.

Originalbrief differences explicitly disclosed: parentUI hasaggregateanswers+animal-sessioncount,notallgame/topicpercentages; persistentstickercollectionabsent (Foxiereactions/roundstars present); activitycardsratherthan5themedworldzones. Ten mechanics implemented doesnotmean everyoriginalproductdetailcomplete. Next continue should address outstandingdesktop productpolish, especially meaningful pergame/topic practiceview, or follow user's specific steering. Tablet onlylater. Voicepronunciation/timbre stillneedsuserlistening. Don'trestartgames/repeatbroadtestswithoutnewchanges. No newtool/dependencyneeded.

## Tablet install and review now authorized - latest

User explicitly requested currentbuild ontablet forreview.0.12.1/code13APKbuilt,verified,installed andlaunched2026-11-14. See TABLET_BUILD_REPORT.md. SHA2563A7AC82C5460D2FAE1A4FF2D38A509DB2C57B19AC397D29A296A8E71BA24CB8B;32,942,842bytes. Signaturev2/v3,ZIPalignment,package/ABI/min24/target36,no permissions,requireddata/exclusionspassed.236audioimportdescriptorsalltargets present. ADB authorizedsinglemodel25099RP13G/fluteAndroid16ARM64;install-rSuccess,versionconfirmed. Launcherresolvedcom.godot.game.GodotAppLauncher->GodotApp,Statusok,mainloopstarted,processalive. No Godotscript/resourceerror orAndroidRuntimefatalstartup observed;vendorwarningspresent,notdiagnosed. Targetpackageabsentbeforeinstall,no uninstall/cleardata. Appleftopenforuserreview. No tabletsettingschanged. Deviceauth exists;discoverfresh devices/PID beforefuturecommands,never assume oldPID. Userfeedback/actualtouch,audio,lifecycle,offline,FPS/memoryremainpending. Prior tablet-deferral paragraphs are historical andsuperseded bythisrequest. No needrepeatdesktoptestswithoutnewchanges. Current normal PC artworknotcopied totablet. No Git/downloads.

## User UX corrections COMPLETE - latest checkpoint, PC ONLY

User explicitly overrode tablet install plan: do not touch tablet; only PC. Source0.13.0/preset14,tablet still0.12.1. No ADB,APKexport/install orGit thisincrement. SeeUX_REPORT.md. Full selected-locale policy supersedes earlier English-learning-always-English: names,prompts,all178UK speech keys nowUkrainian. Tetiana2 uk_UA-ukrainian_tts-medium replacesLada-xlow;modelPC-only76,735,663bytes,revision6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3,CC0cardassets/licenses/ukrainian-tts-medium-MODEL_CARD.txt. All178English clips unchanged;356total23,876,002bytes,0.58–2.84s. Subjectivevoiceapprovalpending. Sample.local/qa/uk-tetiana-preview.wav.

Activities virtual2colScrollContainer,recycledcells≤14even1000futureentries,noUIpagination,mousetouchdrag,inertia,tapcancel/secondfingerhandling,pixeloffset restoreafter2layoutframes. ensure_activity(route) fortests;set_page retainedonlyaslegacyfixtureadapter,nopagerbuttons. Drawing/Coloringicon-onlyactions andlocalizedtooltips,brushicons/dots. IdleGuide rootnoninteractiveoverlay waits10s(aftervoiceends),one3sgesture,pergamestate tap/drag,resetoninteraction/focus/route/modal/activecontact;reducedmotionstatic. Noautoplay/scoring. Native gesturetestconfirmedmousepan withoutlaunch,UKDrawingicons/stroke/finger. Normal PCgallerypreserved.

Final prior-suite chainpassed:foundation371,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3031,Counting10874,Drawing420,Coloring1820,Xylophone86,Release1263. All0failures;crossprocesspersistencepasses. NewUXsuite633/0includesallroutes×locales×difficulty,idlethreshold/oneaction/heldcontact/consumedcanvasrelease,actualmouse/touchswipes,scrollrestore,1000entrypool,icons,UKaudiopaths. Touchswipe andlayoutrestore failureswerefixed/rerun. Lastscrollfixfollowedbyseparatefinalrelease1263/0. Content12JSON/320keys/472refs0errors;audio356pass. AuthoringAST+fullUKprepareridempotencepass. Renderer180captures0issues;selectedscreensinspected;lasticoncenteringnativeverified. Logs.local/logs/ux-{final,tests,render,release-final,native}.log.

Authoring: tools/prepare_full_ukrainian.py enforcescanonicalUKstrings/voicejobs/manifestaftereveryprepare_*content.py helper (runpycallappended);callitafterothernewhelpers too. tools/generate_voice_pack.py --locale uk preservesEN/modelmetadata;--prefix remainsavailable. tools/Test-UX.ps1 chainallregressions+focusedUX. UI SVGicons areoriginalcodevectors. No externalruntime dependencies. Download onlynewUKmodel/config/card onPC.

One isolated Ukrainian PCreviewwindow leftopen onDrawing,tests/ux_native_review.tscn. It usesnewtest-runsdirectory eachlaunch;normal personaldrawings areNOT itsgallery. This fixturelogs mousebuttons forreview;do notconfuseitwithproductionanalytics. Normaloldwindowclosedgracefully. Launchregularapp tools/Run-App.ps1 (retainsnormalsaves,localechoseninparents). Previewlaunch tools/Start-Godot.ps1 -GodotArguments @('--path',(Get-Location).Path,'--scene','tests/ux_native_review.tscn'). EnumeratefreshCUAwindows/activatebeforecapture;foregroundframescanbestalewithoutactivation. UseSkyonlyfornativeUI. No needrepeatbroadtestswithoutnewchanges. Next:userPCfeedbackonthisincrement/voice;tablet onlywhenexplicitlyrequestedagain. Earlierprogress/sticker/worldzonesgaps remainoutofscope.

## Completion celebration COMPLETE - latest checkpoint

PCONLY,userrequestedfireworks+allpopballoons. Source0.14.0/futurepreset15;tablet remains0.12.1,noADB/export/install/Git/downloads. SharedCompletionCelebration/PartyBalloon mounts at _show_complete in7learninggames(Animals/Colors sharecontroller),hidesallvisiblegamecontrols,shortoriginalforegroundfireworks,6largefixedballoons,quietpop/rays,uniquehitcount,cancel/parent/focusguards,onlyallsixrevealsoldresult/replay. Homealwaysavailable;noextrafakeprogress. Duplicatecompletecallbacksguarded. _clear_body restores/removesparty. IdleGuidepointsoneunpopppedballoon;reducedmotionstatic. Freecreative/musicactivitiesremainopenended.

TwoPARTY_INTROspeechclips(Cori/Tetiana,pinnedexistingmodels),358total24,256,750bytes0.58–4.76s,speechsignalchecks pass. Original0.14smonoPCMpopwith0.14amplitudebound. tools/prepare_completion_content.py+AnimalshelperpreservesPARTY_prefix. No newdependency.

Final tools/Test-Celebration.ps1 fullchain41,000assertions/0failures:foundation375,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3031,Counting10875,Drawing420,Coloring1820,Xylophone86,Release1267,UX634,Celebration547. Settings/progress/artwork/coloringcrossprocesspersistencepasses. Content12JSON/324keys/475refs0errors. Focusedparty547covers7routes×2locales×3difficulties,realviewporttouchhits,corners,canceled/repeatedtouch,pause,all6gating,idlehint,restore,scoreandduplicateguards,Homeexit. Render24captures0issues,selectedscreensinspected. Nativefinalepreviewlaunched;resultscreenobserved (usercaninteractwhilewework). Do notclaimwepersonallypoppedallnatively;automatedtouchtestprovesbehavior.

Found/fixedpreviousmenuasyncscrollrestore:get_tree nullifnavigationremovesmenuduringlayoutawait. Membershipguardbeforeandafterbothframes;Colorsreproducingregression andfullchainpassed. Runtimeparty popburststateremovesat0.35s andredrawsclearedcanvasproperly. Parent/focusstopsanimation/input. No remainingtestfailures.

ReportCELEBRATION_REPORT.md. Evidence.local/logs/celebration-{full,tests,render,native}.log;.local/qa/celebration. FinalePreviewwindowwasopenedwithisolatedUKtest-runsdata;olderUXpreviewmayalsoexist. Enumerate/activatefreshCUAwindowsbeforecapture. Normalgallerypreserved. Quicklaunch tools/Start-Godot.ps1 -GodotArguments @('--path',(Get-Location).Path,'--scene','tests/celebration_native_review.tscn');normalapp tools/Run-App.ps1. Currenttaskcomplete;nextuserPCfeedback,nottabletworkunlessexplicitlyrequested. No globalmemoryupdates.

## Android0.14.0 update requested - waiting for USB

User now explicitly authorized installing latest version; prior PC-only restriction superseded for this update. Built/verified0.14.0/code15 APK35,151,396bytes,SHA256BBC5BA639D7080C7EBCE3934C488230269E46C10047B03775DDEC5F79FAC8844. Signature/alignment/package/permissions/requiredassets pass;358speech+8instrument imports+balloonpop targets verified. Log.local/logs/android-014-build.log. ADBdevices empty at initial check;asked user connect/unlock USB. Installation NOT yet performed. On ready: re-enumeratefreshdevice,verify targetpackage,install-r(no uninstall/cleardata),resolve/startactivity,verifyversion andapp-scopedstartup log.


## Android 0.14.0 installed - 2026-11-14

User connected tablet and authorized update. Redmi25099RP13G/flute re-enumerated as authorized. Previous installed0.12.1/code13 updated to0.14.0/code15 with install --no-incremental -r (Success). Initial default incremental/streamed attempt failed with an empty diagnostic; explicit non-incremental retry succeeded. No uninstall,clear-data or device settings changes. Update semantics preserve existing private app data; individual artwork contents were not inspected.

APK35,151,396bytes (33.52MiB),SHA256BBC5BA639D7080C7EBCE3934C488230269E46C10047B03775DDEC5F79FAC8844. Signature,alignment,package/ABI/min24/target36,permissions andrequired resource checks passed.358speech+8instrument import targets andballoon-pop resource packaged. Installed version confirmed by package manager. Launcher GodotAppLauncher opened GodotApp,Statusok,cold start606ms/Wait641ms (activity-launch timing,not input latency). App left open for user review. Startup log .local/logs/tablet-014-launch.log; no full physical-gameplay/performance acceptance implied. Current update includes virtual scrolling,full Ukrainian Tetiana speech,idle finger hints,icon tools andsix-balloon completion.

## Feedback pack COMPLETE - latest checkpoint

User supplied4feedbackitems andthen"continue"whileweworked. Allimplemented/source0.15.0/futurepreset16. PCreviewfirst;noADB/export/install/Git/downloads thisincrement,tabletstill0.14.0. SeeFEEDBACK_PACK_REPORT.md.13workingactivities registered. No needrestart work.

Shared PaintPalette:9quickcolors+artistpaletteicon opensmodal25solid/6gradientpresets. Popup pausesdrawing;selectioncloses/resumes. Drawingdistancegradient quantized25steps/bounded64stampcache;Coloringvalidatedgradient:a:b metadata rendersactualSVGgradient andsaveseditablewithsamehistory/draft/gallery. Oldhexstates/PNGsreadable;noolder-appdowngradeclaim. Shapes/Puzzles begin_drag can_finish_feedbackimmediately whennextunplacedpiecepicked,nolongaudio-lengthlock;stopsoldtimer/killsoldsnaptween/settlesoldpreview before newowner. This removesverifiedsoftwarewait,notalltabletlags.

NewLetters26EN+33UKupper/lowernames,allglyphbuttons;Syllables20UKCV/6ENintroVCunits,2orderedtap-letterchoices,2/3/4options,5targets/common6balloonparty,actualpracticecounts. Wholeunitspokenonassembly. АБВ/ABC explicitlyselectslessonlanguage,UIkeepslocale. Notafullreadingcurriculum. LetterCatalog loadsdata/game_content/letters.json;newcontroller/scenes namesalphabet_garden,syllable_garden,balloon_meadow. Balloonmeadow6reusedgentlefloatingballoons,afterallpopnewset.6s,noScoring/timerpenalty,focus/parentpaused,reduceMotionstatic.

85newlocalclips withsameCori/Tetiana,443total27,789,806bytes0.49–4.76s. ENblendtargetsregeneratedstandalone(no"Build"prefix). foundation.study_localesdeclaresALPH_/BLEND_ lessonlanguageexceptions;fullUKpreparerpreservesUKstudyjobs andENmappings. OrdinaryUKUI/tasksremainfullyUK. tools/prepare_learning_pack.py authorsdata/UI/jobs,thenfullUK. AnimalshelperpreservesALPH_/BLEND_/PARTY_. No newmodels. Audioquality/listeningpending.

FullTest-Feedback.ps1 chainpassed41,742assertions0failures(initialfocused218);finalfocusedexpanded226passed0failures,noleaks. Addedpaletteactualswatch/pauseresume/diskreloadverificationafterfullchain;finalsmallfocus-timernotificationguardrerun226clean. Initial2orphanHBoxCanvasItemsinSyllableoptionsfieldfixedbytypeduninitializedfield. Content13JSON/423keys/570concreterefs0errors. Speech443checksfinalpass.66EN/UKscreenshotsat1280x800,1440x810,1024x768,0boundsissues;selectedfullimagesinspected. Newartistpaletteiconaftercapturelayoutfootprintunchanged. NativeUK/ENalphabettaps,assemblingСО,andfreeballoonpopverified. Finalfullregressionlog.local/logs/feedback-full.log;focused/render/native analogous. HelpersPythonASTpass;Build-Androidfuturecheckincludesletters.json.

PCwindow"Little Wonder World - New Activities" leftopenonBalloonmeadowwith1poppedballoon(5left),automaticallyrenewsafterall6. Isolatedtest-runssettings/progress/artwork,normalgallerypreserved. Oldpreviewwindowsmayalsoexist;enumerate/activatefreshWindowsbeforecapturewithSky. Launchtestpreviewtools/Start-Godot.ps1 -GodotArguments @('--path',(Get-Location).Path,'--scene','tests/feedback_native_review.tscn');normalapp tools/Run-App.ps1. Combinedchecks tools/Test-Feedback.ps1. No globalmemoryupdates. NextuserPCfeedbackorrequestedtabletupdate;do notautoexport/install.

## Active Discover the World/history increment - PC first

User approved bilingual implementation of plan: separateWorldhub,existing12animals,new9bodyparts/8plants,Explore/check5questions,parenthistoryselfcomparison. Source0.16.0/futurepreset17,noADB/export/install/Git/downloads. Implementedworld_hub/world_topic/WorldBodyBoard,WorldCataloglazyJSONregistry. Bodyquizzoomsfaceforfacialparts,wholebodyforlimbs;2/3/4markedchoiceregionsmatchdifficulty. Checksusefixed5itemsetshuffledorderforcomparability. NewAssessmentHistoryautoload,separateversion1history.json100sessions,JsonStorebackup/futureschemarefusal,active/interrupted/completed,perquestionfirstCorrect/assisted/attempts/solved,signaturetopic+revision+locale+level+sorteditems. IdleGuideonactualdisplaycallsworld.on_idle_hint_shown(candidatequeriesdonotcount). Parentsrouteassessment_historyprotectedandlinkedfromsettings;tabledate/topic/langlevel/independent/hints/previousmatching. Oldaggregateprogressuntouched. 68newWORLD_voiceclipsnow511total,existingmodels;helperprepare_world_content.pyvectors/data/voicesnew,AnimalshelperpreservesWORLD_. FirstWorldtest774checks18failuresallfromstrictint-vs-JSONfloatDictcomparison;normalizedexpectedJSONinfixture,rerrunrunning. Needfinishregression,freshprocesshistoryprobe,render/nativePCreview,report. Newart/dataassets/objects/world/*.svg anddata/game_content/world_*.json. No restart.

## Latest checkpoint — World0.16.0, 2026-11-14

Supersedes earlier next-step/version notes: user authorized both Ukrainian and English world expansion. Implemented Animals12/Body9/Plants8, Explore and5-question checks, private100-check history with matching-condition comparisons.792 World assertions and earlier regression suites passed; isolated two-process history probe passed after startup-audio settling fix;84 render captures/0issues. See WORLD_REPORT.md for evidence and limits. Source0.16.0/code17; tablet remains0.14.0. No APK/device/Git actions. Run tests/world_native_review.tscn for isolated Ukrainian preview. Do not restart completed features. Next await PC/content feedback; everyday words/phrases remain a future increment.

Latest deployment: user requested installation;0.16.0/code17 successfully updated authorized Redmi tablet from0.14.0 with install --no-incremental -r. Verified installed version and successful launch; no uninstall/clear-data. See TABLET_BUILD_REPORT.md. Earlier tablet0.14.0 status is historical. Await real-device feedback.

## Flying balloons — PC0.16.1 / future Android code18

User requested slow upward flying balloons in random order/colors with simple animation. Replaced the free game's fixed3x2 batch with six independent recycled flights: random size/color/horizontal position/speed26–44logical pixels/s, optional gentle sway, individual delayed respawn below the clipped field after pop or escape. A short radial burst accompanies pop. Pauses freeze flight and respawn; reduced motion removes sway while retaining essential upward gameplay. Ellipse hit-testing allows touching a balloon through empty corners of overlapping controls. Existing completion party still uses its original behavior.

Verified focused Feedback234 and Celebration547 assertions, zero failures; updated66render captures, zero boundary issues; selected balloon capture inspected. Isolated PC preview tests/balloon_native_review.tscn left open. No tablet operations in this increment: installed tablet remains0.16.0. Next user PC feedback or explicitly requested tablet update.

## Latest checkpoint — Learning/body0.17.0,2026-11-14

User requested locale-only alphabet with two tabs,short English letter speech,correct pictures; detailedbody; replacing static syllables with randomized pictured words. Completed33UK/26ENcards with swipes,isolated names (no The letter),explicit inside-word examples И/Ь; WordCatalog86EN/93UKpictured vocabulary,random5words,shuffled consumable letters;20interactive body parts,brows/fingers/torso,hand/face zoom,cropped body illustrations. Source0.17.0/futurecode19;tablet remainsinstalled0.16.0/code17. Includes priorflyingballoons0.16.1. NoADB/APK/Git/downloads this increment. Full regression chain passed atFeedback483/World928;final focusedFeedback498/World940 passed after vocabulary/crop/hit refinements. Final renders171Feedback/96World,zeroissues;59card sheets inspected.614speechclips35,563,904bytes,technical checks pass,subjective pronunciationpending. Detailed report LEARNING_BODY_REPORT.md. Isolated preview tests/learning_native_review.tscn. Next userPC/listeningfeedback or requestedtabletupdate. Do not redo completed features.

Latest deployment2026-11-14: user requested tablet installation and APK/folder links.0.17.0/code19 successfully updated authorized Redmi from0.16.0/code17 via install --no-incremental -r; installed version/launch confirmed,process remains running. No uninstall/clear-data. APK build/android/little-wonder-world-debug.apk38,615,448bytes. See TABLET_BUILD_REPORT.md. Earlier tablet0.16.0 status is historical. Next await real-device feedback.

## Latest checkpoint — Personalization0.18.0,2026-11-14

Supersedes prior0.17source notes. User approved generatedboy,requested matchinggirl,11pets,total12balloonsat1.5xspeed,andperletteraudioaudit. Completedassets/objects/people/{boy,girl}.png,portraitselector/persistedbody_character,per-sprite20partgeometry/zoom/wordatlas,11persistentcompanionsincludingfoxand10originalanimalSVGs,homehorizontalrow+globalnavigationavatar. Balloons12,speed39–66vs26–44,initialspawnawaitslayout. All59lettersnewcontext-durationextraction,EnglishAyfrontendbugfixed,AIPA/eɪ/,Xvowellengthrefined;noTheletterinplayedclips.614clips34,215,400bytes,letterdurations0.423–0.713s,59signal/phonemechecksnoissues;subjectivelisteningpending,notmanuallylistened/ASRverified. DevelopmentNumPy/ONNX/ORTinstalled.tools/python-audio;augmentedgraphs.local/letter-modelsnotshipped. Exactimageprompts PEOPLE_GENERATION_PROMPTS.md;detailedreport PERSONALIZATION_REPORT.md. FullTest-Friends passed(Feedback498,World940,Friends368plusallpriorchecksandcrossprocesspersist),106renders/0issues. Initialpersistprobeaudioexitwarningfixedandfullchainrepeatedcleanly. Source0.18.0/futureAndroidcode20;tabletinstalled0.17.0/code19,APKbuildpathstillold0.17. NoADB/export/install/Gitactions this increment. Isolatedpreviewtests/friends_native_review.tscn. Next user PC/listeningfeedback or requestedtabletupdate.

Latest deployment2026-11-14:user requested tablet update and APK link.0.18.0/code20 installed successfully over0.17.0/code19 with install --no-incremental -r;installed version/launch/process verified,no uninstall/clear-data. APK build/android/little-wonder-world-debug.apk40,955,145bytes,SHA25685E45B0A6F6D4800179708A98B8D0D5B63A23A58200AACA8FA9FB3E40BE37F9A. Boy/girl packaged textures/geometry explicitly verified. SeeTABLET_BUILD_REPORT.md. Earlier tablet0.17.0/PC-only notes are historical. Await user device feedback.


## Latest checkpoint — Scroll/paint0.19.0,2026-11-14

User requested whole-screen scroll fixes onhome/menu/settings,morepaintcolors,andcompactsideicons/largerpaper. CompletedsharedTouchScroll forhome/settings/virtualcatalog/picker,gestureownership/tapforwarding,inertia/stop/cancel/multitouch/emulationguards,mousewheel/drag,horizontalsliderintentvsverticalpan. Homepetrowbecame2-rowgridinsideoneverticalpage;catalogkeepsboundedpoolandavoidsrebindingperpixel. Palette143solids+6gradients=149swipeablechoices,sharedwithColoring. Drawingonecompacttoprow,68pxsidetools/32pxicons/verticalsizes;actualpaper920x575at1280x800,1132x707.5in1024x768expandedlogicalviewport. Raster1024x640/artworkformatsunchanged. FullTest-ScrollPaintpassedallold suites/persistence,UX834/Feedback498/World940/Friends368/ScrollPaint36;54renders/0issues,selectedimagesinspected. ReportSCROLL_PAINT_REPORT.md;isolatedpreviewtests/scroll_paint_native_review.tscnopen. Source0.19.0/futureAndroidcode21;tabletremainsinstalled0.18.0/code20,APKfolderstill0.18. NoADB/export/install/Git/downloads this increment. Next userPCgesturefeedback or requestedtabletupdate. Do not restart completed work or replaceexistingartwork.


## Latest checkpoint — Pet strip0.19.1,2026-11-14

User corrected home design:pet list must be one bottom horizontal line plus previous/next arrows beside large companion. Completed fixedhomehero+singlePetScrollhorizontal row;arrowcycling11pets,persistedselection,large/headerportraitupdates,andselected-thumbnailreveal(waitlayout,ignorestalerequests). SharedTouchScrollhorizontalaxisadded;settings/catalog/paletteverticalbehaviorretained. Prior0.19homegridnoteis superseded. Source0.19.1/futureAndroidcode22;tabletstill0.18.0/code20,APKfolderold0.18. FocusedUX834/Friends368/ScrollPaint44passed;66renders/0issues. Full0.19chainhistorical,notrerunforsmallcorrection. Previewtests/pet_row_native_review.tscn. NoGit/dependencies/downloads/ADB/export/install. Nextuserreview/requestedtabletupdate.


## Latest checkpoint - Living drawings 0.20.0, 2026-11-14

User authorized one Bini-like guided picture first, gallery after review. Implemented living_drawing (14th registered game), original house JSON/vector board, six parts/ten strokes, tap marker -> camera zoom -> ordered forgiving tracing -> part reveal -> zoom out -> common six-balloon party -> interactive house. Door shows selected pet; windows light, chimney smoke, roof bird. EN/UK UI plus18localclips;632total35,710,534bytes. Pause/resume and pointer ownership; accepted ink survives lifting/offpath, return to green point prevents skipping. Completion totals only, no fake knowledge scores. No gallery yet; partial session in memory. Full Test-LivingHouse chain passed at438housechecks; final focused445/0 after pause/offpath refinements.120renders/0boundsissues, selected interactions visually inspected. Content19JSON/596keys/816refs/0errors. See LIVING_DRAWING_REPORT.md. Isolated PC preview tests/living_house_native_review.tscn. Source0.20.0/futureAndroid23; tablet and old APK still0.18.0/code20. No downloads/Git/ADB/export/install. Next user PC review, then separately authorize picture gallery or tablet update. Preserve prior assets and all completed features.


## Latest checkpoint - Open-ended living yard 0.21.0, 2026-11-14

Supersedes the0.20task/celebration/gallery-later notes. User requested no task ending, thicker tracing/leader, half as many dots, no gray undiscovered shapes, expanded interactive story and Back to a scenario gallery. Delivered one House and yard card in child-accessible living_gallery route; activity opens gallery, Back/Escape returns there. Six ordered house parts unlock four independent sun/cloud/dog/flower markers, arbitrary choice; completed parts remain tappable during READY. Ten elements/fifteen strokes; hidden undrawn shapes, active colored guide only after dot tap. Ink7->9screenpx, priorstrokes6->8, leader radius10->12, spacing18->36. No task/session/score writes or completion overlay. Chimney continuously smokes after drawing and cyclesfivecolors per tap; sun/moon day/night changes sky/ground/stars/windowlights; cloudrain/puddle, dogoriginaltwowoofSFX+4secyardrun, flowerbutterflies; doorselectedpet/window/roofbird retained. Pausefreezesdrawing/camera/effects/bark;reducedmotionkeepsdogstationary. GameManager.living_draft retainscompletedparts/acceptedpartialstroke/night/lights/smokecolor inRAM acrossgallerynavigationonlyuntilappcloses;replayclears. ENUK604keys/642clips37,651,034bytes(.42-5.15s),technicalauditpass/listeningpending. Originalvectors/bark,existingvoiceweights,no downloads. FullTest-LivingHousepassedallprioractivitysuitesandpersistence (foundation655,release2123,UX848,etc),finalhouse777/0.192ENUKthree-resolutionrenders/0boundsissues;selectedinitialmarker/tracing/gallery/nightframesinspected. DetailsLIVING_DRAWING_REPORT.md. Source0.21.0/futurecode24;tabletandAPKstill0.18.0/code20. NoGit/ADB/export/install. IsolatedUKpreview tests/living_house_native_review.tscn launched cleanly,log.local/logs/living-yard-preview.log. Next userPCfeedback;moregalleryscenariosorinstallationonlywhenrequested. Do not redo priorcompletedfeatures.


## Latest checkpoint - Seasonal stories0.22.0,2026-11-14

User requested fasterballoons,fixmousecircletracing,3richSpring/Autumn/Winterstories and4cardsperrow. Delivered4storygallery(House+3seasons),12drawableinteractiveactors eachseason/36new;oneanchoropens11independentmarkers. Semanticguides/originalvectoractors,ENUKinstructions,daynight/weather,flowerpetals/insectbirdflight/frogbunnyhop/fishripples/rainbowglints;autumnleaves/harvest/kite/squirrel/puddle;wintercottage/snowmanwave/pineornaments/penguin/sled/gift/lantern/star/rotatingsnowflake. EachstorykeepsindependentRAMsnapshot(acceptedpartialtrace,completed/night)acrossgalleryswitches;replayonlyselectedstory;noending/score. SharedcontrollerselectsSeasonalDrawingBoard;noimagegen/externalassets/downloads. Categoriesvirtualized4columns,pictureabove23pxlabels,poolbounded28for1000futureitems;gallery4cardsvisibleatall3ratios. Freeballoons12,speed39-66->58.5-99logicalpx/s(+50%),partyunchanged. GuidedTraceformerlyrequiredtiny8percentendpointprecisiononshortedges;nowspatialjittertolerance,shortedgeaccept45percentboundedbytolerance,bothclosedcontourdirections;offpath/diagonalguardsremain. FinalSeasonal1008/0noleaks;separateactualimperfectmousecirclesbothdirectionsall3difficulties12/0;oldhouse777/0;102ENUKthree-resolutioncaptures0issues,selectedcategory/gallery/day/nightimagesinspected. Firstseasonalrunexposedunparentedpreallocatedhouseboardwhenreplacingwithseasonboard;fixedbylazyselectedboardcreationandrerunpassedclean. Fullregressionpassedthroughfoundation/oldactivities/release2251/UX880/celebration547/Feedback498/World940/history;stoppedatFriendsbecauseitassertedthepreviousballoonspeed. UpdatedexpectedrangeandrerantailFriends368/0,letterauditREVIEW[],ScrollPaint44/0,House777/0;logsseasons-fullandseasons-*-final. No needrepeatentirefoundationchainforassertion-onlyupdate. Content22JSON/639ENUKkeys/895refs0errors;706localclips41,841,548bytes,.42-5.15s,technicalaudits(pass),subjectivelisteningpending. tools/Test-Seasons.ps1chainsallfuturechecks;tests/seasonal_render_review.tscncaptures.local/qa/seasons. Source0.22.0/futureAndroid25,tabletandAPKremain0.18.0/code20;noGit/ADB/export/install. tests/seasons_native_review.tscnisolatedUKgallerypreviewopened,logseasons-preview.log. ReportSEASONS_REPORT.md. NextuserPCfeedbackorrequestedtabletupdate. Do notredoexistingfeatures.


## Latest checkpoint - Symbol repetition + Ukrainian high voice0.23.0,2026-11-14

Userrequestedseparatetabforendlessletter/digittracing,spokennameaftercomplete,smallfireworks,nextsymbol,noending;alsostrongUKpronunciationreview(allletters,качка,etc). DeliveredAlphabetthirdTrace/Обвести tab withLetters/Numbers;originalprinteduppercase26EN/33UK,digits0-9,localeonlyalphabet,nootherlanguagechoice. SymbolTracing+SymbolTraceBoard reuseGuidedTrace,oneownedpointer,orderedmultistrokes,liftresume,tappableЇdots;shuffledbagscoverallwithoutimmediaterepeat. Completeexactentry.word_keynameaudio+3smallfireworks,nextafter1.5sANDvoicefinished;parent/focuspausefreezesstateandresumerepeatsinterruptedname. Speaker/replay,noProgressManagerwrites/sessionending/commonparty. data/game_content/symbol_tracing.json authoredbytools/prepare_symbol_tracing.py;notcursive/lowercaseteaching.

UKaudio:replacedall369UKclipsusingRomanStasyshyn/uk_UA-tetiana-high,singlefemaleApache2.0modelat42be6e3f72a7c6042271236b94e48edffd1f0c63,SHA1206d8447b99632badeb63d6132241f76cf551874e5254eb8836db36aed7c85c,upstreamLFSverified. Download114,204,024bytesdev-only,noaddedpackages. Oldmediumtextmodel/339oldENclips preservedrespectivelyinbackup/byte-identicalruntimeEN. NewenglishTRACEhint+zero2clips;newUKhint+zero2included369. Fullpack710clips41,403,194bytes,.42-5.36s. UKdirectONNXRuntimeCPU IPAfrontend;264authoredstressentriescover320ordinarytokens,unknownpolysyllabicwordfailsfuturegeneration. DefaultespeakUKодинwrongstressobserved→explicitodˈɪn;качкаkˈatʃka,33canonicalletternamesdistinctИІЇ/ГҐ/ЄЮЯ plusdurationextractionremovescontext. CorrectedPARTY_INTROзавда́нняinfinalpartialrun. All59individuallettervoicing/intendedIPAauditsREVIEW[];thisisnotnative-listeningapproval. Primarysources/model/dictionarylinks inSYMBOL_TRACING_VOICE_REPORT.md. Licensedmodelcard/Apachetextbundled,voice-toolchainandmanifestupdated;runtimeonlyWAVs. PriorUKbackup.local/voice-backup/pre-uk-high;all369A/Bplayers.local/qa/uk-high/listen.html;individualletterplayers.local/qa/letter-audio/listen.html.

Verification:FullTest-Seasonschainpassedwithnewpack(foundation655,release2259,UX882,etc,House777,Seasonal1008,MouseCircle12,allpersistence). FinalSymbolTracing1435/0afterentryvoicehintaddition;actualviewporttouchall79localizedsymbolentriesat3difficulties,exactnameplayback,voicetimer/pause/resume,oldtabs.117ENUKthree-resolutioncaptures0boundsissues,allglyphpointboundschecked,selectedЇ/8imagesinspected;finalcapturedisablesIdleGuideprocessonlyinfixturetoavoidstaleprogrammatichints. Content23JSON/645keys/900refs0errors. NoAPK/ADB/Git/tabletops. Source0.23.0/futureAndroid26;installedtabletandoldAPKremain0.18.0/code20. tools/Test-SymbolTracing.ps1iscombinedwrapper. IsolatedUKpreviewtests/symbol_tracing_native_review.tscn,windowtitleLittleWonderWorld0.23-LettersandNumbers. NextuserPC/listeningfeedbackorrequestedtabletupdate. Do notredoexistingfeaturesorclaimnativepronunciationaccepted.


## Latest checkpoint - Drawing rails + category separation0.24.0,2026-11-14

UseraskedMagicDrawingtoolbartoo high/usesides,thensteeredthatdigittracingmustNOTbeinAlphabet. Bothdone. CategoryCOUNT_TITLErenamedNumbersandcounting/Цифрийлічба;3peertabsHowmany/Скільки?,Basket/Кошик,Trace digits/Обвестицифри. CountingembedsSymbolTracing(fixed_mode digits,nomodeswitch);AlphabetTraceonlyletters(fixed_mode letters,nonumericbutton). Countingforwardspause/focus,tracingidleactionthroughIdleGuideconditionalpreservesnormalcountingfallback. Guardstaletimerfeedbackfromoverwritingtracing. Existingendlessspeech/smallfireworks/advancepreserved. Countingauthorhelperupdatedtomaintaintitle/tab.

MagicDrawingremovestoptoolbar:verticallycenteredleftbrush/size rail,right2colquickpalettewith149choicepicker+actiongrid;bottomtitle/statusfooter;paperupperinset32/lower16centersfullyvisiblecanvas. SharedPaintPaletteside_layoutoptin(defaultColoringunchanged). Raster1024x640/formatsunchanged. At1280paper931.2x582at151.4,137(vs920x575);4:3paper1010x631.25. ValidationSymbol/categories1447/0,Counting10874/0,Drawing420/0,Coloring1820/0,ScrollPaint44/0,UX882/0. Drawing16capturesENUK4ratios(1280x800,1440x810,1024x768,1152x664)0issues/paperbounds/headergap/sidepalette;symbol117capturesENUK3ratios0issues. Selecteddrawing/numeric8screensvisuallyinspected. Static23JSON/646keys/900refs0errors. No needrepeatunaffectedfullseasonschain;prior0.23fullchainhistorical. ReportLAYOUT_CATEGORIES_REPORT.md. Source0.24.0/futureAndroid27;tabletandAPKstill0.18.0/code20. NoGit/downloads/audiochanges/ADB/export/install. Newpreviewtests/layout_categories_native_review.tscnopensNumberstracingUK;normalHome→MagicDrawingreviewsrails. Earlier0.23notesplacingdigitsinsideAlphabetare superseded. NextuserPCfeedbackorrequestedtabletupdate.


## Latest checkpoint - Back to gallery0.24.1,2026-11-14

UserrequestedtopДодомуbecomeНазадtogalleryratherhome. AppRootheadernowlocalizedBACK+back.svg,BackButtoncalls_shared_backwithmodal/embeddedgallerypriority. GameManager.parent_route/go_backmapsordinarygamestoactivities(preservescroll),living_drawing→living_gallery→activities,world_topic→world→activities,protectedgallery/history→settings→home. Meadowreturnsactivitieswhenopenedfromcatalog/game,homewhenopenedfromhome. Keyboard/Escape/AndroidBacksameflow. RemovedduplicateinternalBackToStories/BackToTopicsarrows;existinglivinghousefixtureusesappheaderBackButton. CatalogBackfixture124checks/0failuresENUK,all13ordinarygamesplusstorydraft/scroll/world/modal/embeddedgallery/protectedsettings/meadowentryorigin. Fresh0.24.1PCpreviewopenedwithoutlogerrors,tests/layout_categories_native_review.tscn;logcatalog-back-preview.log. READMEupdated. Source0.24.1/futureAndroid28;tablet/APKstill0.18.0/code20,noGit/dependencies/voicechanges/ADB/export/install. Earlier0.24layout/category work retained. NextuserPCfeedbackorrequestedtabletupdate.


## Latest checkpoint - Optional word translations0.25.0,2026-11-15

Useraskedparentswitchtotext-onlyUkrainianwordtranslationswhileusingEnglishmode. DeliveredparentLanguage toggleenglish_ukrainian_translation(defaultfalse,savedbool,legacyv1missingkeyvalid),ENUKlabels/hint. WordTranslationCaptionintheexistingheadercenterreplacesspacer,smallrounded2lineEN/UKcard;voiceactualEnglishunchanged. AudioManager.speech_requestedemitsbeforemutecheck,captionworkswhenmuted. Finite264cuekeys:data/game_content/word_translations.json authoredfrombilingualcatalogs+26ENalphabetexamples+explicitseason/housenouns/countrequests. OrangefruitАпельсинseparatefromcolorПомаранчевий;noALPHletternamemistranslation. Word/requestsselected/repeatedshow6sec;newwordreplaces,praisekeepsword;disable/route/UKlocaleorUKoverrideclears;modal/focushidesandfreezestimer. EnabledonlyappEN+actualspeechENinregisteredgames/world_topic. Settingspage/menu/helpervoiceexcluded. Noextraaudio/network/models/deps. FutureAndroidrequiredassetlistupdated.

ValidationTranslation2940/0(parenttoggle/diskreload/legacy/typeguard/all264cues11routes/mute/Englishactualstream/UKoverride/modal/expiry/locale/disable),Foundation699/0,UX882/0.51rendercapturesENUKsettingsandwordcuesat3ratios0issues/headerbounds/navoverlap;selectedDuckandlongcountrequestinspected. RendercuesaresyntheticinjectedforheaderQA,notfullmatchinggameplay. Content24JSON/648keys/901refs0errors. Oldfullmodel/seasonschainnotrerunforpresentation-onlyfeature. ReportWORD_TRANSLATIONS_REPORT.md. tools/prepare_word_translations.pyreproducibledata. Nativepreviewtests/word_translation_native_review.tscn opensEnglishAnimalswithoptionenabledinisolatedfixture;normaluserdefaultoff. Source0.25.0/futureAndroid29,tablet/APKstill0.18.0/code20;noGit/ADB/export/install/downloads/voicechanges. Earlierdrawingrails/categoryrouting/backand369UKTetianaHighclipsretained. NextuserPCfeedbackorrequestedtabletupdate.


## Latest deployment - Tablet0.25.0/code29,2026-11-15

Userrequestedinstallation. BuiltandverifiedcurrentAPK42,565,904bytesSHADE2FDAC42BB2167BD1E27654F899CD44325628D0D9EC10405923E72689DCC40A;signature/alignment/packageARM64/no-permissions/assets+all710audioimporttargetchecks passed. AuthorizedRedmiAndroid16updated0.18.0/code20→0.25.0/code29 via targeted install --no-incremental -r:Success. Nouninstall/clear-data/settingschanges;individualprivatefilesnotinspected. Packageversionconfirmed;launcherStatusok,cold828ms,PID20376stillrunning,leftopenforuserreview. StartupnoGodotSCRIPTERROR/ParseError/AndroidRuntimeFATAL;vendorAudioTrackmissinglowpowerXMLnoted,nofullwarningfreeclaim. docs/TABLET_BUILD_REPORT.md updated. APKbuild/android/little-wonder-world-debug.apk,currentPCfolderlink. Source/export25.0/29;allpriornotesstatingtablet/APK0.18arehistoricalsuperseded. NoGit. Nextrealdevicefeedback;captiontoggledefaultoffinparentLanguage,voice/strokesphysicalacceptancependinguserreview.
# Latest checkpoint - Local design catalog, 2026-11-15

User authorized a catalog across ALL game categories populated from current
project, then redesign/review through it. Delivered design_catalog/ (buildless
HTML/CSS/JS, Python stdlib loopback server), tools/Run-DesignCatalog.ps1. Open
http://127.0.0.1:8790; default port 8790 (8787 earlier sandbox attempt timed out).
No packages/downloads/accounts/hosting/Git/ADB/APK actions. Runtime/tablet/APK
stay 0.25.0/code29. Existing art/audio unchanged; override registry empty.

Inventory:1386records,890physicalmedia,724audio,46proceduralstoryactors,69letter/
digittraces,149paints,15game/worldscreenentries;allcomponentsindexed as source,
10nativeUI samples. NativeGodot178captures in.local/design-catalog/previews,
metadata native.json. Capture fixture fixed inherited600x360minimum cropping
320pxactorpreviews and regenerated;hedgehog visually verified whole in browser.
Webcatalog search/filter/drawer/source/reviewnotes/status/audio/fonts/backgrounds/
three-stateactorpreview/tracepoint+JSONeditor;sharedUiKitcoloredit/uploadPNGSVG.
Drafts stay.local until separate explicit apply; exacttargetedchangesbackedupwith
history/rollback;hashguardsstalecreation/apply/rollback. Art source note mandatory.
Audioonlyaudition/review,notbrowserreplacement;arbitrarycodeandriggingnoteditors.
ProceduralreplacementusesDesignVisuals+data/game_content/design_visual_overrides.json
andassets/design/overrides;retainswholeobjectmotion/hit/trace,notinternallimbrigging.
Normalemptyregistryfallbackpreservesoriginalproceduralrender. Catalogexcluded
Androidexport. Sources/reviews trackednormally;generateddrafts/backupsignored.local.

EightPythonfixturetests pass(apply/rollbackfile/art/color/letter/actortrace,conflicts,
inventory,invalidimage/path/points),JSsyntax/Pythoncompilepass. House777/0and
Seasonal1008/0passed;native178capturecompleted. LiveHTTPcatalogread+token/foreign
Origingates403verified. InitialserverGodotlaunchfailedPowerShell--editorbinding;
fixedtodirectknownlocalGodotbinarywithisolatedAPPDATA,importandpreviewstartclean
log. BrowserQAsearchhedgehog/type/category/detail/traceeditor/statecyclingpassed.
No liveartapplydone;fixturetests only. Native/fullgesture/riggingQA notexhaustive.
Server running on8790 in session97677 at checkpoint. Catalog browser tab marked
deliverable. To restart use .\tools\Run-DesignCatalog.ps1. DocsDESIGN_CATALOG_REPORT.md
anddesign_catalog/README.mdcontainworkflow/limitations. Nextuserreviews current
library and chooses a coherent first visualfamily (e.g. autumnanimals/leaves)
before redesign. Do not silently redraw everything or reinstall tablet.


## Latest checkpoint - Play improvements0.26.0,2026-11-15

User requested plan items2,3,4,6,7 together; defer remaining voice audit and
artwork export/coloring examples/Crocodile. Completed DifficultyStrip in Activities
(persistedthreelevels),localizedSettingsgearretainingparenthold/gate. Shared
MaterialPicker/AppRoot.modal pauses gameplay,4colsTouchScrollvirtualpool<=32for1000
items,groups/selectedcount/wordaudio/bodycrops;Puzzlesexactonepictureoroldrandom3,
Memoryexact2/3/4pairsorrandom,wordbuilderexactpicturedwordorrandom5. Completion
screenscanchooseagain. Puzzle/wordrandomreplayavoidimmediaterepeat.
GuidedTraceboundednearbycurrentsegmentre-entry;story+symbolreleasepositionprocessed
exceptcancelledtouches. Nineactorpathsfrom8authoredsilhouettes(repeatedbird),
allwithinzooms;actorillustrationsunchanged. Balloonfree12/base58.5-99unchanged
plusvisiblecounter;separate60secchallenge4->12boundedpace/respawngrowth,overlay/
focuspause,onlyfinishedtimedrunwritesBalloonRecordsJsonStorelocaltop10perlevel,
scrolltable/errorfeedback,doublepop/hiddenballoon/free-recordguards. Threeoriginal
MelodyPractice8notepatterns,free/learn,listensample/stop,nextkeygoldoutline,label,
wrongnotehint/replay,democannotadvancechildlesson,focuspause,positivecompletion.

Finalfocusedheadless73/0;native122/0+24ENUKcaptures1280x800/1024x768(selected
difficulty/picker/memory/melody/recordsinspected);lasttimeunitlocalizationistext-only.
OldsuitesPuzzles8473/Memory3031/Xylophone86/SymbolTracing1447/House777/Seasonal1008/
Friends368/UX882passed;Catalogfixture8/0. Content25JSON/672keys/902refs/0errors;
voicecontent710/0allpriorhumanselectedclipsretained. Initialmixedindentationand
orphanLabelcountercaught/fixed,finalrunsnoleaks. No need fullunrelatedregression.

Designcatalognow1394records/891media/46procedural/15game-worldscreensplus5mode
entries;nativecapturerender182success,isolatesnewBalloonRecords. Source0.26.0,
futureAndroidcode30;installedtablet/existingAPKremain0.25.0/code29. NoAPK/ADB/
downloads/Gitoperations. See docs/PLAY_IMPROVEMENTS_REPORT.md,tests/
play_improvements_tests.tscn,tools/Test-PlayImprovements.ps1. IsolatedPCreview
scene tests/play_improvements_native_review.tscn startsUKActivities,separatesaves.
Localbacklogupdated .local/plans/TESTER_FEEDBACK_2026-11-15.md (ignored). Nextuser
PCplaytest/requestedtabletbuild;do NOT automatically resume deferredfeatures.


## Latest checkpoint — 0.27.0, 2026-11-15

Completed requested F09 offline Draw a word (EN/UK, child/family private task, categories, three levels, two-word Advanced, random/manual choice), plus steering request to redraw ALL four living stories in the companion style. 46 actor overrides, 40 original SVGs, dog/rabbit reuse, three clouds after tracing cloud, state variants and existing interactions retained. Shared draft slots are whitelisted; DrawWord context resumes with isolated ink; save/full-gallery failures never clear task/ink. Secret mode blocks speech and translation captions.

DrawWord headless1545/0; native1581/0+24captures; Drawing420/Translations2940/House777/Seasonal1008/Release2259 passed. Python art2+catalog8 passed. Content25JSON/702keys/945refs/0errors, voice710/0 with recordings unchanged this increment. Native catalog185captures, inventory1438records/932media/46actors/16screens. Inspected full stories and new layouts. See docs/DRAW_WORD_STORYBOOK_REPORT.md and tools/Test-DrawWord.ps1. Isolated PC preview tests/storybook_native_review.tscn starts completed UK autumn, separate saves.

Source0.27.0/futureAndroid31; installed tablet/existingAPK stay0.25.0/code29. No APK/install/download/Git operations. Local plan .local/plans/TESTER_FEEDBACK_2026-11-15.md remains ignored. Remaining F01 residual pronunciation/listening, F05 export/gallery capacity, F08 coloring example. User acceptance on PC/tablet pending; do not automatically start deferred work or deploy.


## Latest checkpoint — 0.28.0, 2026-11-15

User authorized remaining F01/F05/F08. F05 implemented:200pictures/256MiB/4MiBPNG, old version1index accepted, no eviction; parent-only ExportPNG/nativeFileDialog, isolated file-byte/error/source-safety tests, Android contentURI FileAccess branch awaits device test. ArtworkGallery now virtual TouchScroll cards/cache<=24; native large-gallery and recycled-card open verified. F08:10authored examples from separate ColoringDocument, toggle paletteicon +parentsetting coloring_reference defaultoff/backwardcompatible/persisted, no childcolor/history/score mutation.

F01 implemented a revised but HUMAN-UNREVIEWED pack:388replacements=UK364(331standardTetianaHigh text +33wholecanonicalIPAletters, no extraction), EN24(LJRed/Bread/Five+20bodywords, CoriwholeZ/zed/). All9humanselected/retained clips bytepreserved incl Cat/Кіт/Sheep/Качка/Вівця; ENBear unchanged. tooling repair_voice_pack prepare/--apply and voice_repair_pins; original388WAV+manifest .local/qa/voice-repair-028/before. All710PCM/hash/content checks pass; repaired34letters periodicity pass, not pronunciation proof.20priority oldversions linked in /voice-review; stale listening verdicts expire byhash. Routinepreserve protects397clips. Do not call F01pronunciation accepted or regenerate selected audio.

Final checks: nativeGalleryReference177/0+12ENUKcaptures1280/1024, Drawing596/Coloring1820/DrawWord1545/Release2259/VoiceRouting3556 allpassed. VoiceRouting finalclean after testmixerdrain, no productionaudiochange. Pythonvoice3+review7/catalog8pass. Nativecatalog197captures,1450records/932media/16screens. Content26JSON/707keys/946refs/0errors. NativeWindows save dialog observed through computer-use; storage export tested independently, end-to-end chooser save and Android acceptance not claimed. Report docs/VOICE_GALLERY_COLORING_REPORT.md.

Source0.28.0/futureAndroid32; installed tablet and APK remain0.25.0/code29. No APK/install/download/Git. PCisolatedreview tests/desktop_028_review.tscn startsUKcoloringwithreference, separatesaves. Remaining: userlisten/refine exactspeechcues and tablet acceptance/export onlyafterrequest. Localplan remainsignored.


## Tablet installation — 0.28.0/code32, 2026-11-15

User explicitly requested build/install. tools/Build-Android.ps1 passed export,
signature,16KiB ZIP alignment, ARM64 metadata/no-permissions/development-file
checks. APK43,109,161bytes; SHA256
6ADA97EECED6C1064F8D8CBDC207C9D2A2701941EFF49B19823F82C5D92D86B6.
Packaged710speech clips and10coloring references checked. ADB install -r Success
on the connected Redmi tablet, previous0.25.0/code29 ->0.28.0/code32.
All15existing app data files SHA256-identical after installation/before launch.
Backup: .local/tablet-backups/20261115-180420-before-028/app-files.tar.
App launch returnedStatusok, processalive, no SCRIPT ERROR/FATAL/parse/load errors
in PID-filtered startup log. Screen was locked; visible in-app/tablet touch/export
acceptance is NOT established. User should unlock and open the app to review.
APK: build/android/little-wonder-world-debug.apk. No Git operations.


## Latest checkpoint — 0.29.0, 2026-11-15

User requested flexible letter/story tracing, compact balloon counter/flight space, bad Z repair and semantic speech QA. Steering added automatic Git publication review+commit text, difficulty selection visual persistence and background-free dog/rabbit/other story assets. Implemented all code changes. GuidedTrace bounded arc-neighborhood projection, jitter/lift recovery, duplicate sanitization, input-budget guards, robust direction inference around notches, reversed-path scene-draft restore. Screen tolerances52/44/36px. Balloons compact2rows and lower initial spawn, >=70%gamecontent flight. Difficulty exclusive toggles/checkmark/border in hover/pressed/normal, external setting refresh. Removed authored plate from12animals+generator;47relevant textures alpha-audited.

Owner rejected z_whole_zee and z_context_zee; NEVERAPPLIED. Then explicitly selected human British zed from Commons En-uk-z.ogg, public domain/PD-self. SourceSHA1verified, GodotVorbisdecoded/resampled22050mono/volume-only. Runtime ALPH_EN_25 replaced; other709unchanged. Source/license assets/licenses/Z_PRONUNCIATION_NOTICE.md and tools/voice_sources.json, manifest voice_override, selectedpin protected10. repairpins387; total397protected. Local review records OWNERselection, not agenthearing. Original and previous Z preserved .local/qa/z-repair.

New independent ASR tool pinnedwhisper.cpp1.9.2/base multilingual, officialCPUzip8.2MB+model148MB in ignored .tools/whisper-cpp. SHA256verified and tracked tools/voice-asr-toolchain.json; reusable setup_voice_asr.py. audit_spoken_words.py noexpectedprompt/grammar/translation/contextleak,2x4thread boundedCPU, hash/settingscache, atomicreport. Finalfull710pass:307ASRmatches/344discrepancies/59manualletters. SelectedhumanZrecognizedZ. This is NOT344provenbugs and NOTallvoicesaccepted; UKshortwordrecognition hasfalsepositives. Remaining voicework is humanlisten/targetedrepair against thisqueue, especially tester complaints. NOmassregeneration.

CatalogUI expected/transcript andASRfilter, stalehashprotection, human-approvedexcludedfromneeds-review. Browserverified710queue, Ztranscript, audiostart andfilter; userdeliverabletableftopen. Nativecaptures inspected balloons1024, house dogtransparent, difficultyselection. Source0.29/futureAndroid33; tablet/existingAPK stay0.28/code32. No build/install/Gitwrites thisincrement. IsolatedPC tests/desktop_029_review.tscn startsUKActivitiesnormallevel.

Checks: flexible2635/0+4captures, difficulty/art149/0+6captures47textures; symbols1447/house777/seasons1008/play73/release2259/voicerouting3556pass; Pythonsemantic6/review7/overrides3/art2/catalog8pass;710voicehash/PCM/contentpass;59letterdeclaredmetadata+signalpass; JSON26/keys707/refs946/0. Publicationguard0blockers and normal gitdiff--checkpass. More details docs/FLEXIBLE_INPUT_VOICE_QA_REPORT.md.

New AGENTS.md enforces Gitpublishguard+whitespacecheck+finalcommitmessage eachincrement, noautocommit/stage/push. .gitignore extendedmodels/debugkeys/backups/dumps. tools/check_git_publish.py readonlyscans tracked+untracked/nonignored, trackedignored, commoncredentials andlargefiles. Localplanstillignored .local/plans/TESTER_FEEDBACK_2026-11-15.md. LastGitcommit e84c62c designcatalog; pendingdiff includes earlier0.26–0.28 work too, so commitmessage should cover wholependingincrement if owner commitsall.
