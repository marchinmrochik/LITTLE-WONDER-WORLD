# Flexible tracing, compact balloons and speech QA — 0.29.0

Source0.29.0 / future Android code33. Installed tablet and existing APK remain
0.28.0/code32. No new APK/install, staging, commit or push in this increment.

## Input and presentation fixes

GuidedTrace now projects input onto a bounded neighborhood of the current path,
including neighboring segments around a corner. Progress remains monotonic and
bounded by actual movement; large diagonal shortcuts and stationary touches
cannot complete a contour. Small backtracking/jitter is tolerated, and lifting
the finger can resume near the current ink. Consecutive duplicate vertices are
removed. Screen-space tolerance is52/44/36 logical pixels by difficulty.

Closed-path direction is chosen against a neighborhood, rather than the first
tiny edge. Regression tests caught a wrong-direction choice at the winter
lantern's decorative notch; that case now passes. Reversed-path state also
survives return to the story gallery within an app session.

Balloons use a two-row compact header with a small count/time label on the
right. Flight space occupies at least70% of game content in the tested layouts.
Initial balloons start in the lower half, visibly inside the flight area, with
time to rise. Existing speed,12-balloon free mode and timed challenge remain.

DifficultyStrip uses a mutually exclusive toggle group, checkmark and border.
Selection remains apparent in normal/hover/pressed states and after returning
from a game; repeated tapping cannot deselect it. It follows external setting
changes. All12 animal SVGs and their generator had a decorative green background
plate removed, retaining the characters and translucent ground shadows.47
relevant unique story/animal textures were checked for transparent surroundings.

## Z and speech acceptance

The owner rejected both new synthetic Z candidates. Neither was applied. The
owner then selected the British human **zed**, Commons File:En-uk-z.ogg, public
domain / PD-self. The source's SHA1 was verified; the recording was decoded with
Godot, converted to mono22050Hz PCM and volume/edge processing only. No voice,
pitch or speed substitution. Source, assumed author and processing are retained
in `assets/licenses/Z_PRONUNCIATION_NOTICE.md` and `tools/voice_sources.json`.

This selected Z is protected against regeneration, bringing selected overrides
to10. The other709 recordings are unchanged by this increment. The local review
records the owner's selection rather than claiming the agent heard/approved it.

## Independent semantic triage

`tools/audit_spoken_words.py` runs pinned whisper.cpp/base multilingual locally,
using explicit EN/UK language, no expected-text prompt, no grammar or translation,
no cross-file text context, fixed decoding and two bounded4-thread CPU workers.
Audio is resampled to mono16000Hz with small silence margins. Cache identity
includes the input WAV hash, recognizer/model hashes and decoding settings.
Reports are replaced atomically and never set a human listening verdict.

Both the pre-Z and final-current pack were processed. The final710-file report:
307 normalized exact ASR matches,344 discrepancies,59 letters requiring human
review. The selected human Z is independently recognized as `Z.`. These are
**not344 proven bugs**: short words, letters and Ukrainian recognition produce
false positives. A match also does not prove naturalness, stress or child
intelligibility. The pack is NOT fully pronunciation-approved.

The local `/voice-review` catalog displays expected and recognized text, filters
issues, and invalidates stale recognition/decisions by recording/manifest hashes.
Human-approved clips leave the needs-review filter; ASR cannot approve or reject
a person's accepted recording. Real browser checks verified the complete710
queue, Z transcript, playback startup and issue filtering. Native game captures
are separate evidence from browser verification.

Next speech work should follow this loop, without replacing the entire pack:

1. Reproduce a flagged or tester-reported word alongside its picture/text.
2. Listen to the exact current WAV and record what is actually heard.
3. Prepare a replacement with source/model provenance and compare old/new.
4. Apply a human-selected clip, pin its hash, rerun routing/content/ASR checks.
5. Keep unresolved or ASR-only discrepancies open; never auto-mark them fixed.

Priority remains the tester's English words and Ukrainian vocabulary/letters.
Perfect pronunciation requires listening acceptance; an automated test cannot
provide that guarantee. A recorded native-speaker vocabulary pack is a practical
alternative for recurring synthesis failures, as demonstrated by the selected Z.

## Repeatable tools and publication

```powershell
python tools/setup_voice_asr.py --verify-only
python tools/check_voice_pack.py
python tools/audit_voice_content.py
python tools/audit_spoken_words.py
python tools/audit_letter_audio.py
python tools/check_git_publish.py
git diff --check
```

On a fresh PC run `python tools/setup_voice_asr.py` to fetch the pinned official
Windows CPU release and multilingual base model (about156MB combined). SHA256
values/URLs are committed in `tools/voice-asr-toolchain.json`. Tools/weights stay
in ignored `.tools/`; reports, decoded audio, comparisons and child-data backups
stay in `.local/`. No recognizer dependency or network access is added to Android.

`.gitignore` additionally covers ASR/model formats, partial downloads, device
debug keys, crash dumps and accidental backups. `check_git_publish.py` examines
tracked and non-ignored untracked files, catches already tracked ignored paths,
private/build/model files, oversized files and common credential signatures.
It never prints credential contents. This is a read-only heuristic, not a
guarantee that arbitrary future files contain no sensitive information.

`AGENTS.md` now requires relevant tests, the publication guard, whitespace check
and a ready-to-copy commit message after each increment. No automatic Git writes.

## Validation

- Flexible trace:2,635 checks /0failures,4 EN/UK balloon captures at1280×800 and
  1024×768; noisy/lifted input covers every letter, digit and story contour.
- Difficulty/art:149 checks /0failures,6 native captures;47 unique textures.
- Existing SymbolTracing1,447 / House777 / Seasonal1,008 / PlayImprovements73 /
  Release2,259 / VoiceRouting3,556 checks passed.
- Python semantic/publication6, listening review7, overrides3, story-art2 and
  catalog8 tests passed; JS syntax checks passed.
- Voice format/hash/content:710 clips, zero errors. All59 letter signal/declared
  phoneme checks passed; declared phonemes are provenance, not recognition.
- Content:26JSON /707ENUK keys /946resource references, zero errors.
- Read-only publication guard:zero blockers; whitespace check passed. Local
  plans, APK, tools/models, backups and ASR reports are excluded from publication.

Touch feel and final pronunciation acceptance still need the owner's review.
Use isolated `tests/desktop_029_review.tscn` on PC; tablet update is a separate
explicit request. Native catalog previews were regenerated from current source.
