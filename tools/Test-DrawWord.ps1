$ErrorActionPreference = 'Stop'
$LwwRoot = Split-Path -Parent $PSScriptRoot
foreach ($LwwScene in @('draw_word_tests','drawing_tests','word_translation_tests','living_house_tests','seasonal_tests','release_tests')) {
    & (Join-Path $PSScriptRoot 'Start-Godot.ps1') -GodotArguments @('--headless','--path',$LwwRoot,'--scene',"tests/$LwwScene.tscn")
}
Push-Location $LwwRoot
try {
    & python -m unittest discover -s tests -p test_story_illustrations.py -v
    if ($LASTEXITCODE -ne 0) { throw 'Story art audit failed' }
    & python tools/check_release_content.py
    if ($LASTEXITCODE -ne 0) { throw 'Content audit failed' }
} finally { Pop-Location }
