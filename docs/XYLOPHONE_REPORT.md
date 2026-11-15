# Magic Xylophone desktop increment

Delivered2026-11-14: source0.12.0 / Android preset12. All ten games implemented on PC. Tablet/export acceptance deferred as requested.

## Delivered behavior

Eight rainbow keys C5-C6 with original softly struck modal-bar sounds, immediate preloaded playback, held/pulse feedback, reduced-motion support, single-key and sliding free play. Independent pointer ownership supports simultaneous fingers, including two fingers on one key; emulated mouse events cannot double a touch. Sixteen fixed voices retain overlapping tails and bound rapid strikes without growing nodes. Existing parent Sound effects volume controls the instrument. Background music is silent on the instrument screen and restores on exit. Overlay/focus loss stops notes and clears pointers. No scores, lessons or save format added.

Eight original WAVs: mono PCM16bit44.1kHz,1.7s each,1,199,872bytes total. Generated locally from decaying modal partials with smooth envelope, no downloaded samples or dependencies. Original icon and EN/UK instructions. Existing228speech clips,base music and personal artwork preserved.

## Evidence

Full tools/Test-Xylophone.ps1 passed: foundation369,Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3033,Counting10875,Drawing420,Coloring1822,Xylophone86; zero failures. Settings/progress,Artwork and Coloring separate-process persistence pass. Assertion counts are not manual scenario counts.

Instrument checks: eight correct fundamental frequencies distinguished from neighboring semitones, valid PCM format,zero/faded boundaries,non-silent signal,16coincidentpeak bound0.899<1 with gain0.095. Runtime tests verify eight simultaneous viewport touch events map to eight correct streams, independent releases/cancel/same-key ownership, slide/reentry,mouse-emulation filter,mute,focus/overlay stop,100rapidstrikes and music restoration. Desktop audio player state and signal evidence do not measure hardware latency.

24 EN/UK screenshots at1280x800,1440x810,1024x768:0bounds/input issues; selected full images inspected. Native mouse navigation,individualclick and glissando reviewed. Current app leftopen on Xylophone; log clean. Subjective timbre/volume approval is pending user listening, as is physical tablet multitouch.

## Implementation and next step

scripts/components/xylophone_keyboard.gd; scripts/games/magic_xylophone.gd; scenes/games/magic_xylophone.tscn. Menu and registeredroute added. AudioManager instrument_active manages music silence. Authoring tools/prepare_xylophone.py; tools/check_instrument.py; tests/xylophone_{tests,render_review}.tscn. Evidence under ignored .local/logs/xylophone-* and .local/qa/xylophone.

Next: final desktop release/content/audio review, then prepare verified Android build and coordinate device acceptance when available. No APK produced/installed,tablet commands,Git actions or new downloads thisincrement. Current desktop work is complete; Android FPS,memory,touch,lifecycle,offline and speaker behavior remain unverified.
