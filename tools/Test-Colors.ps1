[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Animals.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/colors-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/color_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Colors checks reported an error; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'COLORS TESTS|FAIL:' }
