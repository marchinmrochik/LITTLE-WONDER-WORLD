# Phase 1 — Foundation Delivery

Date: 2026-11-13. Historical Phase 1 checkpoint, complete within its agreed foundation scope. Current Animals desktop work is documented in ANIMALS_REPORT.md; statements below describe the earlier 0.1.0 build.

## Delivered behavior

- Working Godot application with an original vector meadow, Foxie, a home screen and real navigation.
- Companion meadow: hello, sparkle and rest reactions, original local effects and quiet looping music. This is a foundation interaction, not one of the ten planned games.
- Parent access through a two-second hold and an addition challenge; cancellation/back navigation; destructive progress reset requires a second confirmation.
- Live English/Ukrainian UI, English/Easy first-run defaults, validated Ukrainian glyph support and persisted language/difficulty.
- Independent music/voice/effects volumes, music enable/disable, reduced motion and an explicitly temporary opt-in system voice adapter.
- Validated/versioned settings and progress, backup recovery, preserved invalid originals, protected newer save schemas and parent-visible write failures.
- Companion visit counts and a prepared per-game/topic practice API. No educational mastery or completed tasks are invented.
- Parent progress/privacy pages and an honest empty drawing gallery state; no nonfunctional drawing-management buttons or empty future activity cards.
- Desktop focus/pause hooks for saves, pending slider changes and audio; landscape/immersive Android export and safe-area layout code.

## Important files

`project.godot`, `export_presets.cfg`; scenes under `scenes/core`, `scenes/home`, `scenes/companion`, `scenes/settings`; services under `scripts/core`; shared components under `scripts/components`; scene logic under `scripts/home`, `scripts/companion`, `scripts/settings`; catalogs/manifests under `data`; original vectors/audio and licensed font under `assets`; checks under `tests`; Run-App, Test-Foundation and Build-Android helpers under `tools`.

Documentation now describes actual implementation. The original brief remains unchanged. No Git identity, remote, commit or push was configured/performed.

## Verification actually executed

| Check | Result |
| --- | --- |
| Headless editor import | Passed; final log contains no script/resource errors |
| Foundation suite | 118 assertions, zero failures; includes translation-per-key and glyph checks, not 118 distinct gameplay scenarios |
| Settings/progress across separate processes | Passed: UK, Advanced, music preference, companion count and answer data persisted |
| Recovery and validation | Passed: corrupt primary, valid backup, invalid counts, invalid settings, retained damaged original and newer-schema write protection |
| Parent access/navigation | Passed: short hold, interrupted hold, completed hold, incorrect/correct challenge, locked route and back dismissal |
| Locale/navigation race | Reproduced during render review, fixed, regression check passed |
| Audio state | Passed: local effect playback start, music stop/restart, volume mute/unmute and focus suspend/resume |
| Desktop rendered layout | 18 captures: Home, Meadow and top of parent settings × EN/UK × 1280×800, 1440×810, 1024×768; reviewed |
| Native desktop UI | Home → meadow, rest reaction, back/home, exit confirmation; parent challenge, live UK switch, music slider, parent scrolling and empty progress/gallery areas exercised |
| Android export | Passed using Godot prebuilt template; no Gradle/NDK/CMake needed |
| APK signature | Verified v2/v3 signatures |
| APK ZIP alignment | Passed 16 KB-aware zipalign check; this is not ELF segment or device execution validation |
| APK permissions | No uses-permission entries found |
| APK packaging | EN/UK JSON, foundation JSON, font license and provenance present; tests/tools/docs/local development folders absent |
| Real tablet | Not performed, as agreed |

The first visual pass found a variable-font weight issue; numeric OpenType tag selection corrected it. Early-exit audio cleanup was also corrected before final checks. Final checked logs contain no resource-leak errors.

## Current APK

- File: `build/android/little-wonder-world-phase1-debug.apk`
- Version: 0.1.0, code 1
- Package: `org.littlewonderworld.app`
- ABI: ARM64 only
- Minimum/target SDK in artifact: 24 / 36. This does not claim tested support for older Android versions.
- Size: 28,781,926 bytes, approximately 27.45 MiB. Installed size is not measured.
- SHA-256: `70088ebbe5cde2711ae4206efeb9f995a31847bd8fd9a6357f466b90f912a0a5`

This is the real Phase 1 application APK, distinct from Phase 0's disposable toolchain probe. It has not been installed or launched on the Redmi.

## Reproduce

From the workspace PowerShell terminal:

```powershell
.\tools\Run-App.ps1
.\tools\Test-Foundation.ps1
.\tools\Build-Android.ps1
```

Rendered review can be regenerated on the Windows graphical session with `tools/Start-Godot.ps1 --path . --scene tests/render_review.tscn`. Captures are saved under `.local/qa/phase1/`. Tests use separate fixture files under user://test-runs. Logs are under `.local/logs/`; they are excluded from Git and APK packaging.

## Limits and next increment

No educational mini-game, drawing engine, coloring regions, puzzle, sorting drag or multitouch instrument is implemented yet. The five educational zones are not exposed until content is playable. Difficulty is stored for later games, not applied to an invented placeholder exercise. Gallery contains only its current empty state.

The current vector system is a consistent foundation, not approved final commercial artwork. Foxie currently has open/resting art and simple reactions; the full expression set is pending. Recorded EN/UK speech is absent. System speech is opt-in, depends on installed voices and is not audibly/offline-verified; the UK voice was not available in the desktop review. Music/effects are original foundation assets, not final audio polish.

Real Android installation, safe areas, touch, system gestures, airplane-mode behavior, pause/resume, memory and frame pacing are pending. No Android performance or all-ten-games readiness claim is made.

Next: review this foundation, then Phase 2 visual direction, Foxie refinements, Animals illustrations and EN/UK voice samples. Phase 3 implements a complete Learn Animals slice before adding the remaining games.

