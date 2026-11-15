[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
$LwwRunner = Join-Path $PSScriptRoot 'Start-Godot.ps1'
$LwwLogs = Join-Path $LwwRoot '.local/logs'
New-Item -ItemType Directory -Force -Path $LwwLogs | Out-Null

function Invoke-LwwCheck {
    param([string]$Name, [string[]]$Arguments)
    $checkLog = Join-Path $LwwLogs "$Name.log"
    & $LwwRunner -GodotArguments $Arguments *> $checkLog
    if (Select-String -LiteralPath $checkLog -Pattern '(^|\s)(ERROR|SCRIPT ERROR):|instances were leaked' -Quiet) {
        throw "Godot check reported an error: $checkLog"
    }
    Write-Output "PASS: $Name"
    Get-Content -LiteralPath $checkLog | Where-Object { $_ -match 'FOUNDATION TESTS|PERSISTENCE' }
}

Invoke-LwwCheck 'phase1-import' @('--headless','--editor','--path',$LwwRoot,'--quit')
Invoke-LwwCheck 'phase1-tests' @('--headless','--path',$LwwRoot,'--scene','tests/foundation_tests.tscn')
$LwwFixture = 'user://test-runs/restart-' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
Invoke-LwwCheck 'phase1-persistence-write' @('--headless','--path',$LwwRoot,'--scene','tests/persistence_probe.tscn','--','write',$LwwFixture)
Invoke-LwwCheck 'phase1-persistence-read' @('--headless','--path',$LwwRoot,'--scene','tests/persistence_probe.tscn','--','read',$LwwFixture)
