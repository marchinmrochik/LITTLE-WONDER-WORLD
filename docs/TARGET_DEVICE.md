# Target Device and Local Distribution

Updated: 2026-11-13. Initial table retains user-reported details. The ADB observations below were measured on the connected tablet.

| Item | Reported value |
| --- | --- |
| Tablet | Redmi Pad 2 Pro |
| Android | 16 |
| Xiaomi software | HyperOS 3; an update was in progress when reported |
| Physical RAM | 6 GB |
| Additional memory setting | 2 GB; do not count as additional physical RAM |
| Free storage | Approximately 20 GB |
| Device connection | USB ADB authorized and shell access verified on 2026-11-13 |
| Distribution | Local APK installation only; no Google Play publication |

## Resource policy

Development tools belong on the Windows PC, not the tablet. Avoid downloading an emulator/system image for Phase 0. APK size, installed size, peak memory and artwork storage must be measured and reported separately. The reported 20 GB is not an application storage budget.

Use ARM64 as the initial export candidate, subject to confirmation of the actual device ABI. Set a provisional product target of at most 500 MB installed content excluding user drawings; this is a design budget, not a measured or guaranteed size. Review actual size during the first slice. Bound gallery storage and provide adult deletion controls rather than allowing unlimited silent growth. Choose final limits after measuring PNG sizes and a representative drawing session.

The physical tablet is required later for Android 16/HyperOS behavior, actual safe areas, multitouch, audio latency, pause/resume and performance. Desktop checks and a successfully produced APK do not prove these properties.

## User-owned setup

The user will configure Git identity, remotes and any hosting later. A local `.git` directory was initialized during Phase 0 before this preference was clarified. No commits, remote configuration, sign-in or pushes have been performed. Do not configure these automatically.

No tablet installation or USB debugging is required now. Once a test APK is available, provide manual installation instructions. USB debugging can be enabled later if needed; never ask the user to disable general device protections permanently.

## Verified USB readiness  -  2026-11-13

ADB lists one authorized device. Read-only shell queries report model 25099RP13G (flute), Android 16, API 36, ABI arm64-v8a, physical screen 1600x2560. The /data filesystem reports 105G total, 48G used and 58G available; this differs from the initial 20 GB report and is not an app budget. No APK installed/launched, no Android settings changed, no personal files inspected. Existing ARM64 export configuration matches the reported ABI. USB installation restrictions, actual rendering, offline audio and runtime behavior remain untested.

2026-11-14: Current0.12.1/code13APK installed andlaunched withuserauthorization. Android16/ARM64 reverified;see TABLET_BUILD_REPORT.md. Earlier no-install/deferredwork paragraphs arehistorical. Fullinput/audio/performance/offlineacceptance remainpending.
