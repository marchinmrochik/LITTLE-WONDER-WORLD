param([ValidateRange(1024,65535)][int]$Port=8790)
$ErrorActionPreference='Stop'
$LwwRoot=Split-Path -Parent $PSScriptRoot
& python (Join-Path $LwwRoot 'design_catalog/server.py') --port $Port
