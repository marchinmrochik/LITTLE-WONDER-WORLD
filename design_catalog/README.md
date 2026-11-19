# Design catalog

Local browser tool for inspecting project artwork, audio, tracing paths and runtime screenshots. Start from the project root with Python 3.10 or newer:

```powershell
.\tools\Run-DesignCatalog.ps1
```

Open [the local catalog](http://127.0.0.1:8790). Use `-Port 8791` to choose another port. Native previews use the local Godot installation.

Browse by game or search by name, ID or source path. Review notes are stored in `.local/design-catalog/reviews.json`. Asset replacements and supported tracing or palette edits start as drafts. Compare the preview, apply the draft and verify it in Godot. History can restore an earlier version when the underlying files still match.

Only apply assets with a documented source and suitable permissions. Audio analysis helps triage clips, while listening determines whether a replacement is suitable.
