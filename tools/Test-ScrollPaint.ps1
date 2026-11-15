[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Friends.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/scroll-paint-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/scroll_paint_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) { throw "Scroll/paint checks failed; inspect $LwwLog" }
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'SCROLL PAINT TESTS|FAIL:' }
