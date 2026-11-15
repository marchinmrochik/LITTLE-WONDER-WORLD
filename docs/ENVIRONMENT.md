# Phase 0 — Environment Preparation Report

Date: 2026-11-13. Status: Phase 0 complete. This is the historical environment setup report, before application development. Phase 1 has subsequently been completed; current application results are in `PHASE1_REPORT.md`.

## Installed and verified on this Windows PC

| Component | Actual version | Local location |
| --- | --- | --- |
| Godot Standard, Windows x64 | 4.7.2.stable.official.ed1daf0bf | `.tools/godot/` |
| Godot Android debug/release templates | 4.7.2.stable | `.tools/godot/editor_data/export_templates/4.7.2.stable/` |
| Eclipse Temurin OpenJDK | 17.0.21+9, x64 HotSpot | `.tools/jdk-17.0.21+9/` |
| Android Command-line Tools | 22.0 | `.tools/android-sdk/cmdline-tools/latest/` |
| Android Platform-Tools | 37.0.1; adb 1.0.41 / 37.0.1-15733141 | `.tools/android-sdk/platform-tools/` |
| Android SDK Build-Tools | 36.0.0; also 35.0.1 | `.tools/android-sdk/build-tools/` |
| Android SDK Platforms | API 36 revision 2; also API 35 revision 2 | `.tools/android-sdk/platforms/` |

The Godot editor, full export-template archive, JDK and Android command-line archive were checked against official SHA-256 values before use. Values and source endpoints are recorded in `tools/toolchain-lock.json`. SDK packages were obtained through Google's SDK package manager. Standard SDK licenses were accepted during installation.

Godot's documented base SDK setup listed API 35 / Build-Tools 35.0.1. The actual pinned export template was found to compile/target API 36. Matching API 36 / Build-Tools 36.0.0 packages were therefore added and the final export uses them without the earlier tool-version fallback message.

Only Android debug/release templates were extracted. The complete verified template archive remains available locally. Android Studio, emulator/system images, NDK, CMake, .NET and native Android plugins were not installed. They were not required for the successful prebuilt-template APK export.

## Isolation and local state

- Portable installations and retained downloads occupy approximately **2.93 GiB on the PC** at the end of setup; this is not tablet storage consumption. Logs and builds are separate.
- No tablet files, settings or installed applications were changed.
- No permanent system/user PATH or Windows environment-variable changes were made.
- Godot uses `_sc_` self-contained editor mode; SDK/JDK paths are configured in that local editor profile.
- `tools/Start-Godot.ps1` temporarily redirects APPDATA for Godot desktop test saves to `.local/windows-appdata`, restoring the original value on exit. Godot's self-contained editor mode alone does not relocate `user://` on Windows.
- Android preferences and future Gradle cache are configured locally by `Enter-DevEnvironment.ps1`. adb itself uses Windows' standard profile location and required creation of `%USERPROFILE%/.android`; no device connection/server startup was requested.
- A local debug signing key was generated in `.tools/godot/editor_data/keystores/debug.keystore`. It is excluded from Git. Preserve the key for later local debug updates signed with this identity. A dedicated long-term signing choice can be made before regular family use; no store credentials are needed.

## Executed verification

`tools/Test-Toolchain.ps1 -ExportAndroid` completed successfully after setup corrections:

1. Godot version, Java version and adb version commands ran successfully.
2. A minimal throwaway project was generated under `.local/toolchain-probe/`.
3. Headless editor import completed successfully.
4. Headless runtime loaded the minimal scene and exited successfully.
5. Android export completed successfully using the prebuilt APK template, Compatibility renderer and ETC2/ASTC import enabled.
6. `apksigner verify --verbose` verified APK signatures using v2 and v3 schemes.
7. Separate `aapt dump badging` inspection confirmed package/SDK/ABI metadata; no `uses-permission` entries were present.
8. Separate `zipalign -c -P 16 -v 4` completed successfully, verifying APK ZIP alignment including 16 KB page alignment for uncompressed native libraries. This is not a device execution test or an independent ELF segment validation.
9. Final Godot editor, runtime and export logs contained no `ERROR:` or `SCRIPT ERROR:` entries.

Initial checks caught inaccessible desktop test-save paths, the required Android texture-import setting, and a missing service-project icon. These were corrected before the final successful checks. A target-SDK override was removed because prebuilt-template exports do not permit that Gradle-only setting.

Command-line Tools 22.0 prints a deprecation notice for `sdkmanager` in favor of the newer Android CLI. Package installation succeeded; this notice does not block the current toolchain. No tool migration is necessary for this phase.

## Export artifact

| Property | Verified result |
| --- | --- |
| File | `build/toolchain-probe/toolchain-probe-debug.apk` |
| Purpose | Disposable environment proof; not the Little Wonder World application |
| Size | 28,234,389 bytes (approximately 26.93 MiB) |
| Package | `org.littlewonderworld.toolchainprobe` |
| Version | `0.0.0-probe`, code 1 |
| ABI | `arm64-v8a` only |
| Minimum SDK in probe | 24; this does not commit the product to supporting all Android 7+ devices |
| Target / compile SDK | 36 / 36 |
| SHA-256 | `8f31159340c2274c6db2f4b616fd2cdccf93a66c91ad58b48d9fe51a4df7e1a5` |

The APK need not be installed by the user. The first useful tablet build will come from an application phase. Probe size is not a forecast of the ten-game application's final download/installed size.

## Reproduction and evidence locations

From PowerShell in the workspace:

```powershell
.\tools\Test-Toolchain.ps1 -ExportAndroid
```

This regenerates the local service project and exports/verifies its APK. Additional artifact inspection used:

```powershell
.\.tools\android-sdk\build-tools\36.0.0\aapt.exe dump badging .\build\toolchain-probe\toolchain-probe-debug.apk
.\.tools\android-sdk\build-tools\36.0.0\zipalign.exe -c -P 16 -v 4 .\build\toolchain-probe\toolchain-probe-debug.apk
```

Local evidence logs: `.local/logs/toolchain-verification.log`, `godot-editor-probe.log`, `godot-runtime-probe.log`, `godot-android-export-probe.log`, `probe-apk-badging.log`, `probe-apk-alignment.log` and the SDK installation logs. Generated artifacts and logs are intentionally excluded from source control.

## Deferred and user-owned work at the Phase 0 checkpoint

- No root `project.godot`, product scene, game implementation, artwork or voice content exists yet.
- Real Android launch, Redmi/HyperOS compatibility, touch, multitouch, offline behavior, lifecycle, memory and frame rate remain unverified. The tablet was unavailable by agreement.
- Device name, Android 16 / HyperOS 3, RAM and free storage are user-reported; see `TARGET_DEVICE.md`.
- Local `.git` was initialized before the user clarified Git deferral. No identity setup, commits, remotes, account connections or pushes were performed. Further Git configuration belongs to the user.
- No manual installation is currently required from the user. Phase 1 is the next development step after a separate instruction.

## Official references

- https://godotengine.org/download/archive/4.7.2-stable/
- https://api.github.com/repos/godotengine/godot-builds/releases/tags/4.7.2-stable
- https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
- https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformandroid.html
- https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
- https://developer.android.com/studio#command-tools
- https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse
