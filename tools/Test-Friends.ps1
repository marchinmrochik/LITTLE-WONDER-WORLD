[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Test-World.ps1')
$LwwLog = Join-Path $LwwRoot '.local/logs/friends-tests.log'
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene','tests/friends_tests.tscn') *> $LwwLog
if (Select-String -LiteralPath $LwwLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|were leaked|FAIL:' -Quiet) { throw "Friends checks failed; inspect $LwwLog" }
Get-Content -LiteralPath $LwwLog | Where-Object { $_ -match 'FRIENDS TESTS|FAIL:' }
python -X utf8 (Join-Path $PSScriptRoot 'audit_letter_audio.py') *> (Join-Path $LwwRoot '.local/logs/letter-audio-after.log')
if ($LASTEXITCODE -ne 0) { throw 'Letter audio audit failed.' }
