# Architecture

Status: source0.12.0, all ten games implemented on desktop,2026-11-14. Latest evidence/limitations: XYLOPHONE_REPORT.md; Android acceptance pending.

## Runtime and navigation

Godot 4.7.2 Standard, typed GDScript, Compatibility renderer. project.godot starts scenes/core/app_root.tscn. AppRoot owns the persistent meadow background, safe margins/header, scene slot, modal overlay and optional entry transition. Core routes are Home, Activities, Foxie's meadow and parent settings. Learn Animals is registered as an English-section game by GameManager.

GameManager resolves registered scenes, protects the parent route and cancels old speech/rest state on navigation. Child routes clear adult access. The activity menu exposes ten working activities across three pages plus companion interactions. Locale refresh reads the current route at deferred execution time to avoid restoring a stale screen after rapid navigation. AppRoot handles UIManager responsibilities without another autoload or event-bus framework.

## Services

Autoload order: SettingsManager, LocalizationManager, ProgressManager, ContentManager, AudioManager, GameManager.

- SettingsManager validates version-1 settings, applies English/Easy defaults regardless of system locale and persists explicit changes. Locale/difficulty, three volumes, music, reduced motion and optional system fallback are stored.
- LocalizationManager registers EN/UK JSON catalogs with TranslationServer. Learning audio explicitly requests English independently of the UI locale.
- ProgressManager stores companion visits, game/topic attempts/correct counts and optional completed-task/session counters. An Animals answer/task is saved in one transaction. Additive counters remain compatible with old version-1 records and are validated when present. Reset does not touch settings or unrelated artwork files. No mastery is inferred.
- ContentManager loads the foundation audio manifest and separate Animals catalog. AnimalCatalog validates required fields, unique IDs and safe illustration/word/prompt paths during verification. Adding content does not require rewriting the selection model.
- AudioManager owns Music, Voice and SFX buses, one local voice player and six effects players. Local clips precede optional system TTS. Local speech ducks music by 8 dB, restores it after completion, and stops old speech when repeating/navigating. Missing system voices are checked; fallback is off by default. Engines/models are not application runtime dependencies.

## Animals model and view

AnimalRound is a pure ID-based model. A shuffled five-target deck prevents repeats within a session; Easy/Normal/Advanced create 2/3/4 unique choices including the target. It rejects unknown/duplicate submissions and advancement of unsolved tasks. Optional RNG seeding supports deterministic checks without fixing live sessions.

The Control scene owns presentation, local speech, feedback timing and progress calls. Its states are Explore, Question, Feedback and Complete. Exploration pages display four items. Find mode locks input while presenting feedback, retains wrong-answer targets, records correct task completion once and records a session once on completion. Replay resets the model. Parent overlays and focus loss pause feedback; navigation frees timers and cancels voice. A five-star completion illustration is not a persistent sticker collection.

## UI and layout

UiKit provides the theme, cards, rows/columns and child buttons. Fixed-size icons reserve intrinsic width so text-only minimum sizes cannot hide them. FoxieView has seven poses and optional idle/reaction motion. ParentHoldButton resets incomplete holds on release/exit/focus loss; ParentGate uses randomized two-digit addition. This is a parental barrier, not authentication or proof of age.

The 1280Г - 800 design uses canvas_items / expand. Root containers preserve proportions and adapt logical width/height. Parent settings scroll; child layouts are checked at 1280Г - 800, 1440Г - 810 and 1024Г - 768. Android safe-area conversion and immersive landscape are configured but not device-verified.

Standard Controls use mouse-from-touch emulation; touch-from-mouse is disabled. One viewport-injected ScreenTouch selection is checked, and native mouse flow is exercised. These checks do not validate physical Android input, system gestures or future multitouch instruments.

## Content, storage and lifecycle

Catalogs, audio references, educational content and asset provenance are separate from game algorithms. English words remain English in UK UI. Finite WAV files are bundled; synthesis tools/models remain under ignored .tools/. Export filters retain runtime JSON/license material and exclude test/tool/local directories and generation jobs.

Settings/progress use private user:// JSON. JsonStore writes and flushes a temporary document, preserves a validated previous primary as .bak and replaces by rename. Invalid originals are retained as .invalid before user-initiated replacement. Newer primary schemas block writes. Documents are bounded to 512 KiB. This reduces corruption risk without guaranteeing every power-loss scenario. Parent UI reports write failures. Slider previews commit after debounce, at drag end, on navigation/focus loss.

Windows launchers temporarily redirect APPDATA to .local/windows-appdata; editor data is self-contained. Android will use private application storage. Uninstall can remove local data. Focus/pause flushes pending settings, saves local state and suspends audio; resume honors preferences. Actual mobile lifecycle remains pending.

No networking layer, account, child identifier, analytics or advertising SDK is implemented. Optional system speech can depend on OS service/network behavior; bundled speech does not require it. No current Android permission/runtime claim is inferred from the historical Phase 1 APK.

## Future activities and verification

Future games will own their state machines and use shared services. Drawing needs interpolated logical strokes, bounded undo memory and editable saves. Coloring needs independently authored regions. Puzzles/sorting need pointer-owned drags, forgiving snap and explicit completion. Xylophone needs independent pointer IDs/polyphony. None is represented as complete by Animals tests.

Current verification combines headless import, model/integration checks, separate-process persistence, PCM/resource validation, rendered boundary checks and native desktop interaction. Real-tablet voice quality, latency, memory, frame pacing, safe areas and offline/lifecycle behavior require Android QA later.


## Colors increment

Animals and Colors share learn_animals.gd, configured by exported game_id/text_prefix in their scenes. Catalog access, prompts, task/session persistence and localized helper keys are parameterized; rendering/feedback/lifecycle logic is not copied. AnimalRound and catalog loading/validation serve both activities. Colors uses eight identical ball silhouettes with different base colors, so object identity cannot reveal the answer.

## Feeding increment

FeedingRound specializes the generic ID round model for 3/4/5 choices. FoodCard only initiates a pointer-owned drag or word selection; feed_animals.gd owns capture/release/movement, target hit testing, feedback and session state. Only an active owner can release; unrelated fingers and repeated releases cannot submit. Cancel/focus/overlay/exit restores card opacity and removes the preview, without saving attempts. Food requests use the same catalog resource validator, local audio and progress services. Eating visuals/tweens and feedback are cleaned on restart/exit and paused by overlays/focus.

## Shapes increment

DragCard is now a shared input surface; FoodCard retains its food_id compatibility alias, preserving Feeding behavior. PointerDrag is a reusable single-pointer event owner (move/release/cancel/Escape) used by Shape Sorting. ShapeBoard owns layout generation, coverage, identity matching, placements and completion independently of coordinates. The view resolves nearest unfilled targets within a bounded tolerance, then submits IDs to the model. Placed sources stay disabled and slots show colored pieces. Snap/return tweens pause with focus/overlay and are cleaned on restart/exit. Integration tests exercise viewport mouse and synthetic touch paths; physical tablet behavior remains pending.

## Puzzles increment

PuzzleRound owns picture selection, integer piece/slot identity, 2x1/2x2/3x2 crop geometry, shuffled trays and full-picture/session completion. The view builds AtlasTexture regions over the existing original animal SVG texture; it does not scale the full animal into every tile or generate copied image files. PointerDrag and DragCard are shared with Shapes. The view resolves unfilled targets within 10 logical pixels, handles snap/return, optional translucent template, explicit next-picture review and restart. Timers/tweens pause and cancel as in the existing drag activities. Tests verify crop tiling and actual crop pixels against the original image. Six menu entries now fit a 3-column/two-row grid. More entries will need reviewed paging rather than an overflowing third row.

## Memory increment

MemoryRound owns a shuffled double-copy deck, selected indices, matched indices and locked pair resolution. MemoryCard animates only inner artwork so the button hit box stays fixed. The view gates CHOOSING/REVEALING/HOLDING/HIDING/COMPLETE, counts only completed second reveals and resolves each pair once. Hide callbacks track their two pending indices. A generation token rejects callbacks after restart or navigation; node-owned timers/tweens pause on focus/overlay and are stopped on exit. No active deck is persisted: stored data is actual practice counters, not hidden-card positions. Paginated activity cards retain a process-local GameManager.activities_page; previous tests now reach puzzles through actual page-two controls.

## Counting increment

CountingRound owns range/choice generation,five unique quantities,theme cycling and live basket membership. Basket membership is a set-like array of unique source instance IDs,not a raw increment counter. Only exact membership count plus explicit confirmation can complete a task;duplicates,invalid IDs and solved-round mutations are rejected. The view renders exact choice objects,unique source cards and one return control per stored item. PointerDrag/DragCard and existing audio/progress services are reused. Dropping alone does not record a practice attempt. Mode switches/overlays/focus/exit cancel pending drags;feedback state prevents duplicate number/check scoring. Themes and spoken instruction keys live in counting.json/locales rather than per-screen artwork copies.

## Drawing increment

PaintDocument uses an opaque RGBA8 1024x640 raster. Native Image.blend_rect applies cached brush stamps along interpolated clipped segments; no per-point full-image history is stored. One active pre-stroke image supports cancellation, then only changed bounding-box before/after patches are retained. History caps: 24 transactions and 32 MiB pixel payload, with shared undo/redo budget; brush cache caps at 64 stamps. PaintCanvas fits the page inside its Control and maps viewport mouse/touch coordinates back to raster space. Texture uploads occur at most once per frame. Only the owning pointer can finish a stroke; focus/overlay/navigation commits current visible work and flushes the debounced draft.

ArtworkManager owns a versioned metadata index and PNG storage under user://artwork. Gallery caps at 24 entries / 64 MiB including orphan/staged gallery PNGs; each PNG is capped at 4 MiB and its IHDR dimensions are checked before decode. Gallery Save publishes a fresh immutable copy; index failures roll back that new PNG. Recoverable unindexed files are surfaced on reload. A fixed draft plus validated backup/staging supports interrupted work; this does not guarantee every power-loss scenario. Newer index schemas block writes. Child gallery opens images without deletion; guarded parent gallery supports confirmed deletion. Reopened pictures are editable raster bases with fresh session history, not persisted vector strokes. Shared private artwork storage is separate from learning progress and is not removed by Reset progress.

Coloring: ColoringDocument loads ten stable-ID polygon pages from data/game_content/coloring.json, masks ink/eyes and updates one region. SVG rendering produces 1024x640 RGBA. History is bounded to64 transactions/page; ten page documents retain colors, only current raster is displayed. ArtworkManager optional validated coloring metadata preserves old schema1 PNG entries and routes each kind to its editor. Separate coloring-draft.json stores all page colors through JsonStore. Missing semantic metadata falls back to raster Drawing, including orphan PNG recovery.

Magic Xylophone: XylophoneKeyboard hit-tests eight fitted key rectangles, keeps pointerID→key ownership (including multiple fingers on one key), retriggers only on new press/key transitions, filters touch-emulated mouse. MagicXylophone preloads eight WAVs and owns16 AudioStreamPlayers on the existing SFX bus; no player/allocation per strike. Gain0.095 and validated source peaks bound16 coincident peaks to0.899. Focus/overlay stops all notes and clears pointers; exit stops players and restores meadow music level. AudioManager instrument_active silences only background music during play. No score/persistence is fabricated for free music.

UX0.13.0: Activities is a ScrollContainer with absolute row layout,recycled cells and bounded viewport overscan; retained pixeloffset restores after layout,explicit mouse/touch gesture cancellation andtouch inertia. IdleGuide is a noninteractive root overlay with one timed state-specific tap/drag cue and no synthetic gameplay. LocalizationManager.object_name andlocale-selected AudioManager.say now localize vocabulary/prompts too. This supersedes earlier always-English learning semantics. SeeUX_REPORT.md;tests/ux_tests.tscn.

Completion0.14.0: CompletionCelebration hides/restores direct visible game controls,owns six PartyBalloon touch targets andfinite burst state,then reveals the prior summary after all six unique pops. Existing learning-session bookkeeping remains in controllers. _clear_body removes the overlay;duplicate completion guard prevents restarting it. IdleGuide selects one remaining balloon. Deferred Activities scroll restore now checks tree membership after each layout await. SeeCELEBRATION_REPORT.md.

Feedback0.15.0 adds PaintPalette sharedmodal,validated perregion gradient descriptors andbounded brush ramps. Shapes/Puzzles begin_drag settles pending feedback before accepting the nextpiece. LetterCatalog reads letters.json;three newgamecontrollers register asletters,syllables,balloons. Explicit study_locales protects lesson speech language across full-UK authoring. Free balloons retain6nodes;Syllables saves realattempts/tasks/sessions. SeeFEEDBACK_PACK_REPORT.md.

World0.16: WorldCatalog lazily reads three topic catalogs. WorldTopic handles exploration/check states; WorldBodyBoard maps fitted body/face geometry to selectable parts. AssessmentHistory autoload stores bounded, versioned private check sessions separately from ProgressManager. Routes world/world_topic are child-facing; assessment_history preserves the existing adult guard. Comparison signature includes topic revision, locale, difficulty and fixed question IDs.

Learning0.17:AlphabetGarden binds alphabet to app locale,with grid/card tabs and owned horizontal swipe. LetterCatalog entries bind explicit word/image/highlight indices. WordCatalog merges and deduplicates pictured source catalogs lazily;SyllableGarden route now builds full words using a stable per-word shuffled tile multiset and used-index ownership. Internal syllables progress namespace is retained;new itemIDs start word:. WorldBodyBoard has face/left-hand zoom and ordered fine-before-coarse touch regions;Body topic revision2 prevents old/new history comparison. Original body art and clipped semantic crops are regenerated by prepare_body_details.py.

Personalization0.18:BodyCharacterCatalog reads separate sprite geometry from body_characters.json;WorldCatalog applies it to copied body entries;WorldBodyBoard draws the selected PNG and region views directly in source pixels. WordCatalog cache includes body_character and uses AtlasTexture regions. Settings optional companion/body_character fields retain legacy schema1 reads. CompanionCatalog enumerates11IDs;FoxieView chooses original animal art for non-fox selections;AppRoot renders a compact navigation companion. Letter development synthesis uses letter_aligned.py and an augmented duration output/mask,with audio_metrics.py validation before publishing the complete selected batch. No inference libraries are runtime dependencies.

Scroll0.19:TouchScroll owns pointer gestures before descendants,forwards only deliberate stationary clicks,and separates horizontal slider drags from vertical pans. It suppresses emulated duplicates,canceled/multi-contact taps and modal-background input;fractional inertial integration clamps to scrollbar range. Activities keeps its existing virtual pool but caches binding signatures to avoid icon/name rebinding per pixel. Home is a single vertical page with pet grid. PaintPalette generates143unique solids+6gradients in the same touch scroll component. MagicDrawing combines top rows and uses compact side tools without changing raster document geometry.

Home0.19.1:TouchScroll supports horizontal axis for the single bottom pet strip. Home previous/next arrows wrap CompanionCatalog IDs and reuse choose_pet. Deferred reveal only applies the current selection after layout;other scroll surfaces remain vertical.


## Guided living drawing

LivingDrawing controls READY/ZOOMING/TRACE/REVEAL/RETURNING/PLAY. GuidedTrace is a pure ordered polyline model with accepted progress and off-path recovery. LivingHouseBoard renders original vector geometry, transforms touch coordinates through the camera and owns one active pointer. data/game_content/living_house.json defines six parts/ten strokes. The activity reuses IdleGuide, CompletionCelebration, local speech and aggregate progress; no assessment answers are generated. One picture only; no gallery persistence.


## Open-ended living yard 0.21

The activities entry now routes through living_gallery (child-accessible, separate from protected artwork gallery). living_drawing has six ordered house parts then four independent available_parts markers. READY and PLAY both accept completed-object interactions. Ten original board actors share transformed hit testing; scene age/effects and SFX bark pause together. Smoke is continuous after chimney completion; its color is independent of temporary effects. Sun changes board sky/ground/stars and window lights. No ProgressManager result or CompletionCelebration calls remain in this activity. GameManager.living_draft retains accepted tracing and scene state only within the current process; restart clears it. Details in LIVING_DRAWING_REPORT.md.


## Seasonal stories0.22

LivingDrawing chooses LivingHouseBoard or SeasonalDrawingBoard using GameManager.living_story. Three additional JSON catalogs each define12actors and1anchor;available_parts opens the remaining11markers after its completion. Eachactor has a semantic trace/path,zoom,box,localizedprompt. SeasonalDrawingBoard renders original actor-specific vector art and effects;inherits shared camera/input/ink/pause. GameManager.living_drafts stores independent RAM-only snapshots perstory. Activities keeps virtualized4column picture-above-label cards;storygallery has4cards. GuidedTrace accepts short-segment turns and backward jitter within spatial tolerance and chooses either closed-contour direction.


## SymbolTracing / Ukrainian speech0.23

AlphabetGarden adds a third Trace tab, embedding SymbolTracing and SymbolTraceBoard. data/game_content/symbol_tracing.json defines printeduppercase26EN/33UK and ten digits as original centerline paths. GuidedTrace is reused;locale controls alphabet,small Ї accents accept taps. Shuffledbags drive endless repetition,with quiet local fireworks and exact existing symbol-name audio;advance waits for voice completion,paused timers cannot advance,and interruptionreplays the name. No game registration or assessment/progress score changes. Ukrainian synthesis now uses development-only pinned TetianaHigh ONNX with explicit IPA/finite lexical stress;letters use canonical IPA and model-duration alignment. Runtime still uses finite WAVs.


## Category ownership and drawing rails0.24

Alphabetownsletter-onlySymbolTracing;Countingownsitsdigit-onlyTraceDigitsTab beside existingchoice/basket tabs. fixed_modepreventssemanticcross-switching;parentpause/focusdelegatesandCountingprovidestracing_idle_actiononlywhenactive,retainingIdleGuideoldcountingfallback. Staletimerfeedbackguardpreservestracing. PaintPalette.side_layoutopt-increates2colgridforDrawingrightsidebar;Coloringdefaultsremainhorizontal. Drawingtitle/statusfooterandcenteredleft/righttoolrailsfreeupuppercanvasarea;PaintCanvasdocument/coordinate/rasterformatunchanged.


0.24.1: AppRootheaderBackButton shares _back with keyboard/systemBack. Modal/embedded-view handlers run first,thenGameManager.parent_route/go_back chooses logical containing gallery. Activities retains its existing scroll offset. Meadow remembers whether entered from home or catalog/game. Duplicate scene-local story/topic back arrows removed.


0.25optionalWordTranslationCaption:SettingsManageroptionalboolenglish_ukrainian_translationdefaultsfalseandacceptslegacyv1missingfield. ParentLanguagecontrolsflag. AudioManager.speech_requested(key,locale)emitsbeforemutecheck,presentationcomponentresolvesfinite264word/requestkeysintoEnglish/UKtextanddisplaysintheheadercenter. Actualaudioselectionunchanged. Captionguardsapp+utteranceENandactivityroute,6sectimer,modal/focuspause,clearonsetting/locale/route. JSONgeneratedfromauthoredcatalogswithcontext-specificalphabetextras. Runtimeoffline,noaudio/modelchanges.
# Local design authoring tool (2026-11-15)

`design_catalog/` is a separate, loopback-only Python/HTML developer tool. It
indexes actual project assets/content/component sources, uses Godot fixtures for
native captures, and stages scoped image/path/color changes with local backups.
`DesignVisuals` is the small runtime bridge for optional story texture overrides;
the empty override registry falls back to existing procedural art. Catalog web
code is excluded from Android exports. See `design_catalog/README.md`.
