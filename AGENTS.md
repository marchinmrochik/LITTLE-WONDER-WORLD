# Project workflow

- Respond to the owner in Russian; use English for source comments and project documentation.
- Keep work local. Never stage, commit or push unless explicitly requested.
- After each implementation increment, run relevant checks, `python tools/check_git_publish.py`
  and `git diff --check`. Review tracked and non-ignored untracked files, not only `.gitignore`.
- In the final response, include a ready-to-copy commit message for that increment
  and state any unresolved publication blockers. The owner publishes each step manually.
- Keep downloaded tools/models under `.tools/`; child saves, tablet backups, exported
  drawings, reports, audio comparisons and local plans under `.local/`. Both are ignored.
- Commit runtime artwork, audio, content, licenses/provenance, Godot `.import`
  descriptors and script `.uid` files. Never ignore all WAV/PNG/SVG/JSON files.
- Preserve selected speech recordings. ASR results and signal metrics are review
  aids, not listening approvals. A rejected candidate must not be applied.
- Preserve child drawings/settings during upgrades. Build/install on the tablet
  only on an explicit installation request for the current increment.
