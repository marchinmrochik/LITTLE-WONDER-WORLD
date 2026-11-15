[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Foundation.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/animals-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/animal_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked' -Quiet) {
    throw "Animals checks reported an error; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'ANIMALS TESTS|FAIL:' }
& python (Join-Path $PSScriptRoot 'check_voice_pack.py')
if ($LASTEXITCODE -ne 0) { throw 'Voice pack validation failed.' }
