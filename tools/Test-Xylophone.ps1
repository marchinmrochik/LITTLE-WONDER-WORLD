[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Coloring.ps1')
python (Join-Path $PSScriptRoot 'check_instrument.py')
if ($LASTEXITCODE -ne 0) { throw 'Instrument signal validation failed.' }
$LwwLog = Join-Path $LwwRoot '.local/logs/xylophone-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/xylophone_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Xylophone checks failed; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'XYLOPHONE TESTS|FAIL:' }
