# Little Wonder World — Discovery Report

Date: 2026-11-13. Initial planning audit. Current implementation is recorded in `ANIMALS_REPORT.md`; `PHASE1_REPORT.md` and `ENVIRONMENT.md` are historical checkpoints. Device constraints are in `TARGET_DEVICE.md`. Statements below about the initial absence of source/tools are historical.

## Scope and audit

At the time of the initial audit, the user's request took precedence over the attached master prompt: review, report and plan first, implementation later. No application code, downloads, installations, Git initialization or APK builds had been performed at that point. This historical baseline is retained below; see `ENVIRONMENT.md` for subsequent setup work.

The workspace was empty, including hidden entries. There is no existing Godot project, Git repository, dependency configuration, artwork or audio to reuse. Git is available at `C:/Program Files/Git/cmd/git.exe`. Godot, Java, adb and sdkmanager were not found through command discovery. The standard Android SDK, Android Studio, Java and Godot export-template locations checked were absent. ANDROID_HOME, ANDROID_SDK_ROOT and JAVA_HOME were unset. This is a targeted audit, not proof that no portable installation exists elsewhere on disk.

## Product assessment

The brief provides a coherent offline, child-first product for ages 3–5: ten games, five activity zones, Foxie, English learning, English/Ukrainian UI, parent settings and local creative work. English and Easy must be first-run defaults regardless of device locale. No Russian UI, accounts, ads, analytics, purchases or backend are planned.

This is a full small game product, with substantial art, audio, interaction and QA work. The highest uncertainty is finished content quality rather than the number of screens. Success requires a complete Learn Animals slice before scaling to the other games. Do not expose empty activities.

## Decisions for the first build

- Use Godot 4.7.2 Standard with typed GDScript and the Compatibility renderer.
- Landscape, 1280×800 design canvas; preserve proportions and adapt safe content to 16:10, 16:9 and 4:3.
- Install locally by debug APK first. Store publication and store accounts are outside this delivery.
- Keep progress and images in private app storage. No storage permission is needed for this design. Uninstallation can remove these files; external backup/export is a separate future decision.
- Difficulty is parent-selected. No automatic promotion or child identity profile.
- Report accuracy as observed attempts, not a validated measure of learning. Do not infer mastery from a single correct response; initially describe topic practice rather than educational diagnosis.
- EN learning words remain English under Ukrainian UI. UI prompts and helper speech follow the selected UI language; learning prompts retain their English target and can have a Ukrainian hint.
- Use short repeatable rounds. Free drawing and music have no mandatory completion score.
- Start with a debug APK as soon as the shell works; do not postpone device export until ten games are finished.

## Tool and resource acquisition plan

At the initial planning audit nothing had been downloaded. The following was the acquisition plan; tools have since been prepared in Phase 0 as recorded in `ENVIRONMENT.md`, while product assets/audio remain pending:

1. Obtain official Godot 4.7.2 Standard Windows binaries and exactly matching export templates. Verify the downloaded executable version before use.
2. Obtain OpenJDK 17 and Android SDK command-line tools, platform-tools, Platform 35 and Build-Tools 35.0.1 according to the pinned Godot documentation. Android Studio is optional. Install NDK/CMake only as required by the chosen export path; the official full setup also lists NDK 28.1.13356709 and CMake 3.10.2.4988404.
3. Obtain a licensed font with Ukrainian glyphs and retain its license. Choose the actual font during the visual slice.
4. Create original, consistent artwork using available image generation where suitable and editable vectors for UI/region-based coloring. Image generation capability is available in this session but has not been exercised; coherent production assets and rights must be reviewed before inclusion.
5. Prepare local EN/UK speech. No dedicated voice-generation tool or approved voice library has been established. Choose recordings, a licensed TTS provider or user-supplied files after a voice sample review. Never spend money or transmit child information for this.
6. Create or acquire licensed SFX, eight pitched instrument samples and music; document origin and license per asset. Do not assume all downloaded sound packs permit redistribution.

Download sizes and disk requirements will be checked against actual packages before installation. Avoid prescribing an unverified total. Do not add Node, Python, .NET, paid SDKs or native Android plugins unless a concrete task requires them.

## User participation

Useful before device QA: tablet model, Android version and available storage. These are not blockers for creating the desktop foundation. Minimum supported Android version and ABI coverage remain provisional until the device and actual export support are checked.

For on-device development the adult will need a data-capable USB cable, enable developer options/USB debugging and approve the computer on the tablet; alternatively install a supplied APK manually with installation permission for the chosen installer. No Google Play developer account is needed for the initial local APK.

At the first visual review, approve Foxie's appearance and the home/Animals style. At the audio review, approve EN accent and EN/UK voice samples. Optional supplied references are welcome, not required. No child name, birthday, photograph, account or other personal data is needed.

## Principal risks and mitigations

| Risk | Mitigation / evidence required |
| --- | --- |
| Inconsistent illustrations and Foxie states | Art guide, initial approved asset set, asset provenance manifest; separate art status from code status |
| Missing or poor Ukrainian/English voice | Voice manifest, real sample review, bundled files; TTS only an explicit temporary fallback |
| TTS needs internet or lacks a language | Inspect installed voices and test airplane mode; never label fallback as guaranteed offline |
| Drag/drop breaks under scaling or interrupted touch | Shared coordinate conversion, pointer ownership, cancel handling, real tablet tests |
| Drawing memory grows without bound | Bounded undo memory, sampled strokes and raster checkpoints; test long sessions |
| Coloring leaks between regions | Authored region masks/polygons separate from outline artwork; edge and undo tests |
| Delayed or interrupted sound | Preload current activity speech/samples, interrupt old instructions on navigation, polyphony for music |
| Save corruption or lost work | Versioned data, atomic temporary-write/replace strategy, backup and recovery tests |
| Desktop works but Android fails | Early export and device smoke test; lifecycle, multitouch, safe-area and offline checks |
| Scope expands before first playable | Gate progression on a complete Animals slice; keep ten-game target explicit |

## Readiness and sources

Technical: not implemented. Art: not created. Audio: not prepared. Android export and device verification: not performed. No performance measurements or completion dates are claimed. Estimate remaining work after the first complete slice provides actual implementation and content-production evidence.

Verified official references:
- https://godotengine.org/download/archive/4.7.2-stable/
- https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

Follow-up authorization subsequently covered Phases 0 and 1. Device connection is deferred. Distribution is local APK only. Git identity, remotes and hosting are user-owned and deferred. See `IMPLEMENTATION_PLAN.md` for the current completed phase and next review gate.
