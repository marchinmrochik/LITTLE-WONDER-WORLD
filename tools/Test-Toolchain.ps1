[CmdletBinding()]
param([switch]$ExportAndroid)

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
$LwwProbe = Join-Path $LwwRoot '.local/toolchain-probe'
$LwwLogs = Join-Path $LwwRoot '.local/logs'
$LwwBuild = Join-Path $LwwRoot 'build/toolchain-probe'
$LwwSdk = Join-Path $LwwRoot '.tools/android-sdk'
$LwwJava = Join-Path $LwwRoot '.tools/jdk-17.0.21+9/bin/java.exe'
$LwwTemplates = Join-Path $LwwRoot '.tools/godot/editor_data/export_templates/4.7.2.stable'
$LwwGodotRunner = Join-Path $PSScriptRoot 'Start-Godot.ps1'

New-Item -ItemType Directory -Force -Path $LwwProbe,$LwwLogs,$LwwBuild | Out-Null

foreach ($requiredFile in @(
    $LwwJava,
    (Join-Path $LwwSdk 'platform-tools/adb.exe'),
    (Join-Path $LwwSdk 'build-tools/36.0.0/apksigner.bat'),
    (Join-Path $LwwSdk 'platforms/android-36/android.jar'),
    (Join-Path $LwwTemplates 'android_debug.apk'),
    (Join-Path $LwwTemplates 'android_release.apk')
)) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        throw "Required toolchain file is missing: $requiredFile"
    }
}

& $LwwGodotRunner --headless --version
& $LwwJava -version
if ($LASTEXITCODE -ne 0) { throw 'Java version probe failed.' }
& (Join-Path $LwwSdk 'platform-tools/adb.exe') version
if ($LASTEXITCODE -ne 0) { throw 'adb version probe failed.' }

@'
config_version=5

[application]
config/name="Toolchain Probe"
run/main_scene="res://main.tscn"
config/icon="res://probe-icon.svg"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
'@ | Set-Content -LiteralPath (Join-Path $LwwProbe 'project.godot') -Encoding utf8

@'
[gd_scene format=3]

[node name="ToolchainProbe" type="Node"]
'@ | Set-Content -LiteralPath (Join-Path $LwwProbe 'main.tscn') -Encoding utf8

@'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <rect width="256" height="256" rx="48" fill="#24334b"/>
  <path d="M64 76h128v24h-52v92h-24v-92H64z" fill="#fff8ec"/>
</svg>
'@ | Set-Content -LiteralPath (Join-Path $LwwProbe 'probe-icon.svg') -Encoding utf8

$LwwEditorLog = Join-Path $LwwLogs 'godot-editor-probe.log'
$LwwRuntimeLog = Join-Path $LwwLogs 'godot-runtime-probe.log'
& $LwwGodotRunner --headless --editor --path $LwwProbe --quit *> $LwwEditorLog
& $LwwGodotRunner --headless --path $LwwProbe --quit *> $LwwRuntimeLog
foreach ($probeLog in @($LwwEditorLog,$LwwRuntimeLog)) {
    if (Select-String -LiteralPath $probeLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):' -Quiet) {
        throw "Godot reported an error; inspect $probeLog"
    }
}
Write-Output 'PASS: headless editor import and runtime scene load.'

if ($ExportAndroid) {
    @'
[preset.0]
name="Android Probe"
platform="Android"
runnable=true
advanced_options=false
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""

[preset.0.options]
gradle_build/use_gradle_build=false
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="0.0.0-probe"
package/unique_name="org.littlewonderworld.toolchainprobe"
package/name="Toolchain Probe"
package/signed=true
permissions/internet=false
'@ | Set-Content -LiteralPath (Join-Path $LwwProbe 'export_presets.cfg') -Encoding utf8

    $LwwExportLog = Join-Path $LwwLogs 'godot-android-export-probe.log'
    $LwwApk = Join-Path $LwwBuild 'toolchain-probe-debug.apk'
    & $LwwGodotRunner --headless --path $LwwProbe --export-debug 'Android Probe' $LwwApk *> $LwwExportLog
    if (Select-String -LiteralPath $LwwExportLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):' -Quiet) {
        throw "Godot export reported an error; inspect $LwwExportLog"
    }
    if (-not (Test-Path -LiteralPath $LwwApk)) { throw 'Probe APK was not produced.' }

    $LwwOriginalJava = $env:JAVA_HOME
    try {
        $env:JAVA_HOME = Split-Path -Parent (Split-Path -Parent $LwwJava)
        & (Join-Path $LwwSdk 'build-tools/36.0.0/apksigner.bat') verify --verbose $LwwApk
        if ($LASTEXITCODE -ne 0) { throw 'Probe APK signature verification failed.' }
    } finally {
        $env:JAVA_HOME = $LwwOriginalJava
    }
    Get-Item -LiteralPath $LwwApk | Select-Object FullName,Length
    Write-Output 'PASS: ARM64 debug APK export and signature verification. Device execution is NOT tested.'
}
