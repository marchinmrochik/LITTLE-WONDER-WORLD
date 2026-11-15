[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Feedback.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/world-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/world_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) {
    throw "World/history checks failed; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'WORLD TESTS|FAIL:' }
$LwwFixture = 'user://test-runs/history-probe-' + [DateTime]::UtcNow.Ticks
foreach ($LwwMode in @('write','read')) {
    $LwwProbeLog = Join-Path $LwwRoot ".local/logs/history-$LwwMode.log"
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/history_probe.tscn','--',$LwwMode,$LwwFixture) *> $LwwProbeLog
    if (Select-String -LiteralPath $LwwProbeLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL' -Quiet) { throw "History persistence $LwwMode failed." }
    Get-Content -LiteralPath $LwwProbeLog | Where-Object { $_ -match 'HISTORY PERSISTENCE' }
}
