# Overall PC review

2026-11-14. Reviewed source0.12.1 / Android preset13. All ten games have working desktop mechanics; after the fix below, no blocking technical failure was found in the executed checks. This is not complete Android acceptance or a claim that every original product detail is finished.

## Found and fixed

Parent barrier Cancel closed its own panel without telling AppRoot to resume the active game. Every game implementing overlay pause could then remain unresponsive. The new release integration fixture reproduced60 failures across10games×2locales×3difficulties. Connecting ParentGate.dismissed to AppRoot.close_modal restores the existing shared cleanup. The same1263assertions now pass; previous game suites remain green.

Also replaced the outdated difficulty hint saying games would become available: it now explains how choices/puzzle pieces change. No approved graphics/music/speech assets replaced.

## Executed evidence

| Check | Result |
| --- | --- |
| Foundation |369assertions,0failures |
| Animals / Colors / Feeding |4757 /707 /2914,0failures |
| Shapes / Puzzles / Memory |5094 /8473 /3033,0failures |
| Counting / Drawing / Coloring / Xylophone |10875 /420 /1822 /86,0failures |
| Cross-game release integration |1263,0failures |
| Total automated assertions |39,813,0failures; counts are not manual scenarios |
| Process persistence |Settings/progress,Artwork and Coloring write/read passed |
| Speech |228non-silent PCM clips,hash/format/envelope checks pass |
| Instrument |8tuned notes,16voice worst-casepeak0.899<1 |
| Content preflight |12JSON documents,318matching EN/UK keys/placeholders,343concrete resource references,0errors |
| PowerShell helpers |All tools/*.ps1 parsed without syntax errors |
| General renderer |120captures,0button-boundary issues at1280x800,1440x810,1024x768 inEN/UK |

The new integration pass opens every game through its actual menu card at every locale/difficulty, cancels the actual parent button, checks adult route guards,allmanifest local speech paths,no retained scene-node growth over repeated tours and volume persistence when leaving before debounce. All fixtures use separate user://test-runs storage, not the normal private gallery.

General rendering covers Home,all3menu pages,all10games at Advanced,Meadow,parent barrier,settings at3scroll positions andadultgallery. Selected fullscreens inspected, including UK4:3settings/feeding and dense counting/memory layouts. Scrolled child clipping is expected and excluded from boundary errors. Earlier per-game interaction/pixel fixtures remain part of regression; this general renderer is not a substitute for them. Fresh normal application launched after closing the previous instance; desktop-release.log clean at check.

Static runtime scan found no network/browser API classes. Source architecture uses local resources and system TTS remains opt-in/default-off; this is not proof of airplane-mode behavior on Android. No live network settings changed.

## Original brief coverage and remaining differences

All ten requested mechanics/content minimums are implemented:12animals,8colors,12foods,Drawingbrushes/history/gallery,10independent-region Coloringpages,2/4/6piece puzzles,6shapes,2/3/4pair Memory,1–5/1–10Counting withbasket,8note polyphonic Xylophone. Detailed game reports retain focused evidence. EN/UK,parent barrier,three difficulties,separate volume controls,reduced motion,local practice and private artwork are present.

| Remaining item | Current behavior and consequence |
| --- | --- |
| Detailed practice view |Counts/topics are stored locally, but parent UI shows aggregate answers and animal sessions; per-game/topic percentages are not displayed. A visible progress breakdown remains product work. Never label a topic mastered from these counters. |
| Persistent sticker collection |Not implemented. Existing rewards are short-round stars and Foxie reactions. The brief's sticker example is not delivered as a collection. |
| Five themed world zones |Navigation uses three pages of large activity cards plus meadow instead of five illustrated zone destinations. Functional access exists; this is a presentation difference. |
| Final sound/art acceptance |User likes base graphics/music; softened Cori/Lada and new instrument still need listening/pronunciation/timbre approval. Signal checks do not replace that judgment. |
| Android/device acceptance |Not performed in this review. Physical multitouch/drawing latency,FPS,RSS,storage/lifecycle,resume,airplane mode andspeaker output remain pending. |

## Run and continue

Launch: .\tools\Run-App.ps1. Combined checks: .\tools\Test-Release.ps1. Source checks: python tools/check_release_content.py. Renderer: tools/Start-Godot.ps1 with scene tests/release_render_review.tscn. Logs .local/logs/release-*; captures .local/qa/release (ignored/private).

No new downloads/dependencies,Git commands,APK export/install or tablet commands. Normal saved Drawing and Coloring were preserved. User requested tablet later; next work should address desktop product differences,then prepare verified Android packaging and coordinate tablet acceptance. Current historical0.1.0APK does not represent this source.
