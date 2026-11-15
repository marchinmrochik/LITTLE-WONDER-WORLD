[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--path', $LwwRoot)
