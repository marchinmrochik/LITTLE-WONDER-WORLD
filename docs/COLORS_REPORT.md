# Colors and softer speech — desktop 0.4.0

Delivered 2026-11-13. Two of ten educational games now have playable desktop increments; the companion meadow is additional.

## Behavior

Learn Colors includes Red, Blue, Yellow, Green, Orange, Purple, Pink and Brown. Eight original ball illustrations use identical geometry so object identity cannot substitute for color recognition. Two exploration pages support word selection/repeat. Find mode speaks English under either interface language; helper reactions follow EN/UK. Difficulty selects 2/3/4 options. Five unique targets, gentle retry, guarded feedback, completion, replay and independent local practice/task/session persistence reuse the Animals controller and round model. No full game controller was copied.

## Speech

English changed from LJSpeech to female UK English Cori high, pinned to upstream v1.0.0 revision 375a0fe641dea077c2a47b4e9a056d6da521eed3. Model SHA256 matched official LFS metadata. The card identifies public-domain LibriVox training material and is retained with notices. Ukrainian retains Lada x_low. Both use slower length_scale 1.12, gentler synthesis noise settings, 4,500 Hz treble smoothing and peak 0.46 instead of 0.62. These are technical changes toward a gentler voice; subjective pleasantness and pronunciation are not claimed approved.

All 78 clips were regenerated in ignored staging before runtime replacement. Original pack retained under .local/voice-backup/pre-soft-voice/. Models and engine stay on PC. Bundled voice WAV total: 3,544,046 bytes; duration 0.66–2.74 seconds. Existing music and foundation art are retained.

## Verified

- Foundation: 183 assertions, zero failures; independent-process persistence passed.
- Animals regression: 4,757 assertions, zero failures (includes 90 seeded model sessions).
- Colors: 707 assertions, zero failures (includes 30 seeded model sessions, two-locale real-view flows, resource validation, duplicate rejection, retry/repeat, completion idempotence, replay and saved counters).
- All 78 voice files passed hashes, PCM/signal/fade/duration validation.
- Colors rendering: 42 captures across EN/UK and 1280x800, 1440x810, 1024x768; zero visible-button boundary failures. Selected activity menu, exploration and advanced-choice captures visually inspected.
- Native desktop mouse exercised menu entry, selected-word update, find, incorrect feedback/retry and correct-answer advance. Completion/replay also covered programmatically. App left open for user listening/play.

Run .\tools\Run-App.ps1 to play; .\tools\Test-Colors.ps1 for the combined checks. Rendering fixture: tests/color_render_review.tscn. Evidence under ignored .local/logs/ and .local/qa/colors/.

## Tablet readiness

User approved USB debugging. ADB reports one authorized device and shell queries succeeded: model 25099RP13G/flute, Android 16/API 36, arm64-v8a, physical display 1600x2560, /data available 58G. This confirms USB developer access and matches the export ABI; it does not prove installation or runtime compatibility. No APK installed or launched, personal files not inspected, device settings not modified. Current 0.4.0 APK has not been exported; historical Phase 1 APK is not the current build. Final mobile QA remains separate.

## Next

Feed the Animals is the next development increment. Voice preference/listening remains open. No Git configuration, commit or push performed.
