[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-UX.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/celebration-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/celebration_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Celebration checks failed; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'CELEBRATION TESTS|FAIL:' }
