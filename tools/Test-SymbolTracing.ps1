[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Seasons.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/symbol-tracing-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/symbol_tracing_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) { throw "Symbol tracing checks failed; inspect $LwwLog" }
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'SYMBOL TRACING TESTS|FAIL:' }
