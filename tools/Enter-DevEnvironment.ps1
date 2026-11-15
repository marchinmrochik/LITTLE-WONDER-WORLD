# Dot-source this file to configure only the current PowerShell session.
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
$LwwTools = Join-Path $LwwRoot '.tools'
$LwwJdk = Join-Path $LwwTools 'jdk-17.0.21+9'
$LwwSdk = Join-Path $LwwTools 'android-sdk'
$LwwGodot = Join-Path $LwwTools 'godot/Godot_v4.7.2-stable_win64_console.exe'

if (-not (Test-Path -LiteralPath (Join-Path $LwwJdk 'bin/java.exe'))) {
    throw "Local OpenJDK is missing: $LwwJdk"
}
if (-not (Test-Path -LiteralPath $LwwGodot)) {
    throw "Local Godot is missing: $LwwGodot"
}

$env:JAVA_HOME = $LwwJdk
$env:ANDROID_HOME = $LwwSdk
$env:ANDROID_SDK_ROOT = $LwwSdk
$env:ANDROID_USER_HOME = Join-Path $LwwTools 'android-user'
$env:GRADLE_USER_HOME = Join-Path $LwwTools 'gradle'
$LwwPathEntries = @(
    (Join-Path $LwwJdk 'bin'),
    (Join-Path $LwwSdk 'platform-tools'),
    (Join-Path $LwwSdk 'cmdline-tools/latest/bin')
)
$env:PATH = ($LwwPathEntries -join ';') + ';' + $env:PATH
New-Item -ItemType Directory -Force -Path $env:ANDROID_USER_HOME | Out-Null

Write-Output "Local development environment: $LwwRoot"
Write-Output "Godot executable: $LwwGodot"
