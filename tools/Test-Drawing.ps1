[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Counting.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/drawing-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/drawing_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Drawing checks reported an error; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'DRAWING TESTS|FAIL:' }
$LwwFixture = 'user://test-runs/artwork-probe-' + [DateTime]::UtcNow.Ticks
foreach ($LwwMode in @('write','read')) {
    $LwwProbeLog = Join-Path $LwwRoot ".local/logs/artwork-$LwwMode.log"
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/artwork_probe.tscn','--',$LwwMode,$LwwFixture) *> $LwwProbeLog
    if (Select-String -LiteralPath $LwwProbeLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL' -Quiet) {
        throw "Artwork persistence $LwwMode failed."
    }
    Get-Content -LiteralPath $LwwProbeLog | Where-Object { $_ -match 'ARTWORK PERSISTENCE' }
}
