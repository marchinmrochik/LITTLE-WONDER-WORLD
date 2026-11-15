# Android build and local installation

Current0.12.1/code13 built and installed on the authorized Redmi tablet2026-11-14. User explicitly moved review onto the tablet. See TABLET_BUILD_REPORT.md for measured evidence; prior PC review remains RELEASE_REVIEW.md.

APK: build/android/little-wonder-world-debug.apk,32,942,842bytes (31.42MiB). Package org.littlewonderworld.app,arm64-v8a only,minSDK24,targetSDK36. Signaturev2/v3,16KB-aware ZIP alignment,metadata,absence of requested permissions andrequireddata/licenses passed. No developer files bundled. All236speech/instrument import descriptors point to packaged Godot resources.

Build: .\tools\Build-Android.ps1. Uses portable Godot4.7.2,matchingtemplates,JDK17 andAndroidSDK under.tools. Models/synthesis engines remain PC-only.

ADB installation used -s with the single verified tablet,install -r returnedSuccess. No previous targetpackage was listed before installation. Resolved launcher com.godot.game.GodotAppLauncher successfully opened com.godot.game.GodotApp; process remainedrunning andGodot mainloopstarted. Installedpackage reports0.12.1/code13. No Godot script/resource error or AndroidRuntime fatal exception was found in the captured startup log. HyperOS/native vendor warnings were present; this is not a perfectly warning-free system log.

APK size is not installed storage or peakmemory. User review ofgames,touch,multitouch,drawing,audio,lifecycle andoffline behavior remains pending. No such acceptance inferred from successfullaunch. No device settings changed or existingprivate appdata removed. For installation withoutUSB,copy theAPK andopenit with thetabletinstaller; permissions/security prompts belong to theuser.

## Signing and updates

The debug signing key remains under .tools/godot/editor_data/keystores/debug.keystore and outside Git. Keep the signing identity/package stable and increase versionCode for updates. Do not uninstall casually to resolve signing conflicts: private settings/progress/drawings can be removed. Select/back up a long-term local signing identity before regular family use. Google Play publication is out of scope.

Drawing/gallery files are private user:// runtime data and must never be packaged from PC .local/. Physical Android drawing latency, memory, safe areas, touch cancellation and save/gallery behavior remain unverified until device QA.


## Android 0.14.0 installed - 2026-11-14

User connected tablet and authorized update. Redmi25099RP13G/flute re-enumerated as authorized. Previous installed0.12.1/code13 updated to0.14.0/code15 with install --no-incremental -r (Success). Initial default incremental/streamed attempt failed with an empty diagnostic; explicit non-incremental retry succeeded. No uninstall,clear-data or device settings changes. Update semantics preserve existing private app data; individual artwork contents were not inspected.

APK35,151,396bytes (33.52MiB),SHA256BBC5BA639D7080C7EBCE3934C488230269E46C10047B03775DDEC5F79FAC8844. Signature,alignment,package/ABI/min24/target36,permissions andrequired resource checks passed.358speech+8instrument import targets andballoon-pop resource packaged. Installed version confirmed by package manager. Launcher GodotAppLauncher opened GodotApp,Statusok,cold start606ms/Wait641ms (activity-launch timing,not input latency). App left open for user review. Startup log .local/logs/tablet-014-launch.log; no full physical-gameplay/performance acceptance implied. Current update includes virtual scrolling,full Ukrainian Tetiana speech,idle finger hints,icon tools andsix-balloon completion.

Source0.15.0/futurepreset16 is PC-reviewed only in this increment. Latest installed tablet version remains0.14.0/code15. Future Build-Android helper now requires letters.json;no0.15APK exported/installed yet. SeeFEEDBACK_PACK_REPORT.md.
