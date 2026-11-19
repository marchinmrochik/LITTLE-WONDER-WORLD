# Development

## Run from source

Use Godot **4.7.2 Standard** with the Compatibility renderer. Import `project.godot` in the editor and press **F5**. From a terminal with Godot on PATH:

```sh
godot --headless --editor --path . --import
godot --path .
```

On Windows, the project wrapper expects `.tools/godot/Godot_v4.7.2-stable_win64_console.exe` and redirects desktop user data under `.local/windows-appdata/`.

```powershell
.\tools\Start-Godot.ps1 -GodotArguments @('--path', (Get-Location).Path)
```

Gameplay uses bundled WAV files. The speech synthesis and recognition toolchains are only needed to regenerate or audit recordings.

## Test

From the repository root, run the Python checks with Python 3.10 or newer:

```sh
python -m unittest discover -s tests -p "test_*.py"
python tools/check_release_content.py
python tools/audit_voice_content.py
python tools/check_voice_pack.py
```

After Godot imports the assets, run the Windows release suite with `.\tools\Test-Release.ps1`. Individual `tools/Test-*.ps1` scripts exercise their corresponding activities. The release scene also runs directly:

```sh
godot --headless --path . --scene tests/release_tests.tscn
```

Automated audio checks cover coverage, routing, file integrity and signal bounds. Listen to any changed recording before accepting it. For UI changes, verify desktop layouts and touch behavior on Android where applicable.

## Build for Android locally

Install matching Godot export templates, JDK 17 and the Android SDK. The PowerShell helper expects the portable layout described by [the toolchain lock](../tools/toolchain-lock.json), including Android API 36 and Build Tools 36.0.0. Configure SDK and Java paths in Godot's Android export settings.

Run `.\tools\Build-Android.ps1` to export and verify the debug APK. The output is `build/android/little-wonder-world-debug.apk` and verification logs are under `.local/logs/`. The export preset and its Android version code are in [export_presets.cfg](../export_presets.cfg). Keep the signing identity and package ID stable for updates that preserve on-device data.

## Source and local files

Commit runtime assets, content, licenses, Godot import descriptors and script UIDs. `.local/` holds private notes, catalog reviews, desktop saves, test output and audio comparisons. `.tools/` holds local dependencies. `build/` holds generated builds. Keep signing keys outside Git.

Before committing, review tracked changes and untracked files, then run `python tools/check_git_publish.py` and `git diff --check`.

See the [design catalog guide](../design_catalog/README.md) for the local asset review and preview workflow.
