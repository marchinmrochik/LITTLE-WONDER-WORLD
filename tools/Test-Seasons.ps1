[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-LivingHouse.ps1')
foreach ($LwwScene in @('seasonal_tests','mouse_circle_tests')) {
    $LwwLog = Join-Path $LwwRoot ('.local/logs/' + $LwwScene + '.log')
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene',('tests/' + $LwwScene + '.tscn')) *> $LwwLog
    if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) { throw "Seasonal checks failed; inspect $LwwLog" }
    Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'TESTS:|FAIL:' }
}
