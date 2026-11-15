[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-ScrollPaint.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/living-house-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/living_house_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) { throw "Living house checks failed; inspect $LwwLog" }
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'LIVING HOUSE TESTS|FAIL:' }
