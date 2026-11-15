"""Rebuild finite drawing voice jobs from the checked-in localization catalogs."""
from pathlib import Path
import json
ROOT = Path(__file__).resolve().parents[1]
jobs_path = ROOT / "data/game_content/voice_jobs.json"
manifest_path = ROOT / "data/game_content/foundation.json"
jobs = json.loads(jobs_path.read_text(encoding="utf-8"))
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for locale in jobs:
    jobs[locale] = [job for job in jobs[locale] if not job["key"].startswith("DRAW_")]
for key in ["DRAW_INTRO", "DRAW_SAVED"]:
    manifest["voice"][key] = {}
    for locale in jobs:
        messages = json.loads((ROOT / f"data/localization/{locale}.json").read_text(encoding="utf-8"))
        file = f"assets/audio/voice/{locale}/{key.lower()}.wav"
        jobs[locale].append(dict(key=key, text=messages[key], file=file))
        manifest["voice"][key][locale] = "res://" + file
jobs_path.write_text(json.dumps(jobs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("Prepared four local drawing helper clips.")

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
