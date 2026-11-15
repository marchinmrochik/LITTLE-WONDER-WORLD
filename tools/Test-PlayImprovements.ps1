$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
foreach ($LwwScene in @('play_improvements_tests','puzzle_tests','memory_tests','xylophone_tests','symbol_tracing_tests','living_house_tests','seasonal_tests','friends_tests','ux_tests')) {
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene',"tests/$LwwScene.tscn")
}
& python (Join-Path $PSScriptRoot 'check_release_content.py')
if ($LASTEXITCODE -ne 0) { throw 'Content audit failed' }
