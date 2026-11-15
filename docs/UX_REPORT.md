# Child navigation, full Ukrainian and idle help

2026-11-14. Desktop source0.13.0 / future Android preset14. The user's latest correction is authoritative: review only on PC, do not touch the tablet. No ADB, APK export/install or tablet changes were performed for this increment. The installed tablet APK remains0.12.1.

## Delivered changes

The activity picker is now a vertically scrollable two-column virtual grid. Only viewport rows plus overscan are mounted; cells are recycled. There are no pagination arrows or page indicators. Mouse drag, wheel and touch pan are supported; touch release adds decaying inertia. Dragging suppresses card activation, canceled/multiple contacts do not become accidental launches, and returning restores the scroll position after container layout completes. The companion destination remains a single persistent footer.

Ukrainian now applies to object names, prompts and speech, including animal/color/food/shape vocabulary, puzzle/memory names, counting instructions/numbers and coloring pages. This deliberately supersedes the earlier English-learning-words-always-English policy. English mode remains English. Existing progress IDs and creative saves did not change.320 matching locale keys; Ukrainian UI text no longer contains unintended English phrases.

All178 Ukrainian speech keys have separate local recordings, rather than references to English audio. Replaced Lada x-low with Piper ukrainian_tts medium, Tetiana speaker2,22050Hz. The downloaded model is76,735,663bytes on the PC only. Pinned repository revision6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3; model hash and speaker are recorded in the voice manifest. The model card lists three speakers,medium quality andCC0 dataset: https://huggingface.co/rhasspy/piper-voices/blob/main/uk/uk_UA/ukrainian_tts/medium/MODEL_CARD . Speaker IDs are in the matching model config. Higher model quality is not proof of preferred timbre or correct pronunciation; user listening is still required. Existing178 English clips remain unchanged. Total356 speech clips,23,876,002bytes,0.58–2.84seconds;gentle processing retained. No runtime synthesis engine/model is shipped.

Drawing and Coloring top actions now use original undo,redo,save,gallery andclear icons. Drawing brushes use pencil,softbrush,rainbow anderaser icons; width selection uses three dot sizes. Localized tooltips preserve adult-readable meanings,while reading is unnecessary for primary tool recognition. Existing protected clear/reset and undo behavior remains.

IdleGuide waits ten seconds after interaction (and after speech ends),then displays one three-second finger gesture. Home points to Play; catalog points to one visible game. Games suggest a state-specific tap or one valid drag: food toFoxie,unplaced shape/puzzle piece to matching slot,one Memory card,number choice or a basket object/check/return as appropriate. Drawing suggests a stroke; Coloring suggests one uncolored region; Xylophone one key. No automatic input,score or puzzle completion is generated. It resets on new input,route/focus change and hides under parent dialogs or active contacts. Reduced motion retains a static gesture cue. Busy feedback states do not get conflicting instructions.

## Verification

The complete prior game chain passed after locale/menu expectations were updated to the user's new policy: foundation371,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3031,Counting10874,Drawing420,Coloring1820,Xylophone86 andrelease1263 assertions,all zero failures. Counting's assertion count can vary by one with a random initial target. Process persistence checks passed. Speech/instrument signal checks passed. Content preflight:12JSON documents,320matching locale keys and472concrete resource references,zero errors.

The new UX suite ultimately passed633 assertions: all12relevant routes×2locales×3difficulties,10second threshold,one on-screen action,input/modal/held-contact suppression,consumed canvas-release recovery,actual mouse and touch swipes without accidental launch,scroll restore,1000future catalog entries with at most14mounted cells,icon-only drawing controls and178 distinct UK speech paths. An initial touch-swipe failure and a scroll-restoration layout-timing failure were fixed and rerun,not hidden.

Renderer produced180 EN/UK captures at1280x800,1440x810,1024x768,zero bounds issues,including idle cues for all games. Selected fullscreens were inspected. Subsequent icon centering was checked in the native window. Native Ukrainian review verified mouse pan without entering a game,opening Drawing,centered icons,a continuous stroke and an idle finger cue. Review uses isolated settings/progress/artwork; normal gallery pictures were preserved. The native review window is left open in Ukrainian on Drawing. Final release integration was rerun after the scroll-layout fix; its result is in ux-release-final.log.

Evidence: .local/logs/ux-{final,tests,render,release-final,native}.log and.local/qa/release. Voice sample:.local/qa/uk-tetiana-preview.wav. Combined command:.\tools\Test-UX.ps1. Normal launch:.\tools\Run-App.ps1.

## Limits and continuation

No device behavior or performance acceptance inferred from PC gestures. Subjective Ukrainian voice/pronunciation needs feedback. Preview saves are separate from ordinary local saves. Detailed practice breakdown,sticker collection andthemed world zones from the earlier review remain outside these requested fixes. Next continue from user feedback on this PC increment; do not rebuild/install on the tablet unless requested again.
