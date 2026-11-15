[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
$LwwRunner = Join-Path $PSScriptRoot 'Start-Godot.ps1'
$LwwOutput = Join-Path $LwwRoot 'build/android'
$LwwLogs = Join-Path $LwwRoot '.local/logs'
$LwwSdkTools = Join-Path $LwwRoot '.tools/android-sdk/build-tools/36.0.0'
$LwwApk = Join-Path $LwwOutput 'little-wonder-world-debug.apk'
New-Item -ItemType Directory -Force -Path $LwwOutput,$LwwLogs | Out-Null

& $LwwRunner -GodotArguments @('--headless','--editor','--path',$LwwRoot,'--quit') *> (Join-Path $LwwLogs 'android-import.log')
& $LwwRunner -GodotArguments @('--headless','--path',$LwwRoot,'--export-debug','Android Local',$LwwApk) *> (Join-Path $LwwLogs 'android-export.log')
foreach ($logName in @('android-import.log','android-export.log')) {
    if (Select-String -LiteralPath (Join-Path $LwwLogs $logName) -Pattern '(^|\s)(ERROR|SCRIPT ERROR):' -Quiet) {
        throw "Godot reported an error; inspect $logName"
    }
}

$LwwPreviousJava = $env:JAVA_HOME
try {
    $env:JAVA_HOME = Join-Path $LwwRoot '.tools/jdk-17.0.21+9'
    & (Join-Path $LwwSdkTools 'apksigner.bat') verify --verbose $LwwApk *> (Join-Path $LwwLogs 'apk-signature.log')
    if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
} finally {
    $env:JAVA_HOME = $LwwPreviousJava
}
& (Join-Path $LwwSdkTools 'zipalign.exe') -c -P 16 -v 4 $LwwApk *> (Join-Path $LwwLogs 'apk-alignment.log')
if ($LASTEXITCODE -ne 0) { throw 'APK ZIP alignment verification failed.' }
& (Join-Path $LwwSdkTools 'aapt.exe') dump badging $LwwApk *> (Join-Path $LwwLogs 'apk-badging.log')
if ($LASTEXITCODE -ne 0) { throw 'APK metadata inspection failed.' }
$LwwBadging = Get-Content -LiteralPath (Join-Path $LwwLogs 'apk-badging.log') -Raw
if ($LwwBadging -notmatch "name='org.littlewonderworld.app'" -or $LwwBadging -notmatch "native-code: 'arm64-v8a'") {
    throw 'Unexpected application package or ABI.'
}
if ($LwwBadging -match 'uses-permission:') { throw 'Unexpected Android permission; review APK metadata.' }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$LwwArchive = [IO.Compression.ZipFile]::OpenRead($LwwApk)
try {
    foreach ($entry in @('assets/data/localization/en.json','assets/data/localization/uk.json','assets/data/game_content/foundation.json','assets/data/game_content/word_translations.json','assets/data/game_content/animals.json','assets/data/game_content/colors.json','assets/data/game_content/foods.json','assets/data/game_content/shapes.json','assets/data/game_content/puzzles.json','assets/data/game_content/memory.json','assets/data/game_content/counting.json','assets/data/game_content/coloring.json','assets/data/game_content/letters.json','assets/data/game_content/symbol_tracing.json','assets/data/game_content/world_topics.json','assets/data/game_content/world_animals.json','assets/data/game_content/world_body.json','assets/data/game_content/body_characters.json','assets/data/game_content/living_house.json','assets/data/game_content/living_spring.json','assets/data/game_content/living_autumn.json','assets/data/game_content/living_winter.json','assets/data/game_content/world_plants.json','assets/assets/licenses/cori-MODEL_CARD.txt','assets/assets/licenses/tetiana-high-MODEL_CARD.md','assets/assets/licenses/tetiana-high-Apache-2.0.txt','assets/assets/audio/voice/manifest.json','assets/assets/licenses/lada-Apache-2.0.txt','assets/assets/licenses/ljspeech-MODEL_CARD.txt','assets/assets/fonts/OFL.txt','assets/assets/PROVENANCE.md')) {
        if ($null -eq $LwwArchive.GetEntry($entry)) { throw "Required APK asset missing: $entry" }
    }
    if ($LwwArchive.Entries.FullName | Where-Object { $_ -match '^assets/(tests|tools|docs|\.tools|\.local|build)/' }) {
        throw 'Development files were included in the APK.'
    }
} finally {
    $LwwArchive.Dispose()
}
Write-Output 'PASS: Android export, signature, ZIP alignment, metadata, permissions and packaged assets.'
Get-Item -LiteralPath $LwwApk | Select-Object FullName,Length
Get-FileHash -LiteralPath $LwwApk -Algorithm SHA256 | Format-List Hash

