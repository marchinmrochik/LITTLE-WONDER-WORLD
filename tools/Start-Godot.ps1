[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GodotArguments = @('--project-manager')
)

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
$LwwGodot = Join-Path $LwwRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $LwwGodot)) {
    throw "Local Godot is missing: $LwwGodot"
}
$LwwOriginalAppData = $env:APPDATA
$LwwRuntimeData = Join-Path $LwwRoot '.local/windows-appdata'
New-Item -ItemType Directory -Force -Path $LwwRuntimeData | Out-Null
try {
    # Godot's portable editor mode does not relocate user:// on Windows.
    # Keep desktop test saves inside the workspace without changing Windows settings.
    $env:APPDATA = $LwwRuntimeData
    & $LwwGodot @GodotArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Godot exited with code $LASTEXITCODE"
    }
} finally {
    $env:APPDATA = $LwwOriginalAppData
}
