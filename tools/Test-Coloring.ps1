[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Drawing.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/coloring-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/coloring_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Coloring checks reported an error; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'COLORING TESTS|FAIL:' }
$LwwFixture = 'user://test-runs/coloring-probe-' + [DateTime]::UtcNow.Ticks
foreach ($LwwMode in @('write','read')) {
    $LwwProbeLog = Join-Path $LwwRoot ".local/logs/coloring-$LwwMode.log"
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/coloring_probe.tscn','--',$LwwMode,$LwwFixture) *> $LwwProbeLog
    if (Select-String -LiteralPath $LwwProbeLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL' -Quiet) {
        throw "Coloring persistence $LwwMode failed."
    }
    Get-Content -LiteralPath $LwwProbeLog | Where-Object { $_ -match 'COLORING PERSISTENCE' }
}
