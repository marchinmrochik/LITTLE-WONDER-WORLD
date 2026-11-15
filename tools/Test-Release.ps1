[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-Xylophone.ps1')
python (Join-Path $PSScriptRoot 'check_release_content.py')
if ($LASTEXITCODE -ne 0) { throw 'Release content validation failed.' }
$LwwLog = Join-Path $LwwRoot '.local/logs/release-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/release_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked|FAIL:' -Quiet) {
    throw "Release integration checks failed; inspect $LwwLog"
}
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'RELEASE TESTS|FAIL:' }
