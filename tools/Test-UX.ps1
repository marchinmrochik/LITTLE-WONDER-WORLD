[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Release.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/ux-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/ux_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "UX checks failed; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'UX TESTS|FAIL:' }
