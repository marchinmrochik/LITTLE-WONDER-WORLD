"""Author original color-object SVGs, localized content and finite speech jobs."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
COLORS = [
    ("red", "Red", "Червоний", "#D95150"),
    ("blue", "Blue", "Синій", "#467BC6"),
    ("yellow", "Yellow", "Жовтий", "#F4CF41"),
    ("green", "Green", "Зелений", "#58A46A"),
    ("orange", "Orange", "Помаранчевий", "#EA893F"),
    ("purple", "Purple", "Фіолетовий", "#9162B7"),
    ("pink", "Pink", "Рожевий", "#ED91B6"),
    ("brown", "Brown", "Коричневий", "#946442"),
]
# Every color uses the same recognizable ball: answers depend on color, not object identity.
entries = []
for id, english, ukrainian, color in COLORS:
    path = ROOT / f"assets/objects/colors/{id}.svg"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f'''<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300">
<ellipse cx="150" cy="259" rx="91" ry="13" fill="#DFE5D6"/>
<circle cx="150" cy="144" r="104" fill="{color}" stroke="#494B46" stroke-width="5"/>
<path d="M150 40C104 92 104 196 150 248M150 40C196 92 196 196 150 248M47 144H253" fill="none" stroke="#FFFFFF" stroke-opacity=".38" stroke-width="6"/>
<ellipse cx="112" cy="92" rx="21" ry="12" transform="rotate(-38 112 92)" fill="#FFFFFF" opacity=".28"/>
</svg>''', encoding="utf-8")
    entries.append(dict(id=id, english=english, ukrainian=ukrainian,
        illustration=f"res://assets/objects/colors/{id}.svg",
        word_key=f"COLOR_WORD_{id.upper()}", prompt_key=f"COLOR_FIND_{id.upper()}",
        word_audio=f"res://assets/audio/voice/en/color_word_{id}.wav",
        prompt_audio=f"res://assets/audio/voice/en/color_find_{id}.wav"))
(ROOT / "data/game_content/colors.json").write_text(json.dumps({"version": 1, "colors": entries}, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
extra = {
    "TITLE": ("Colors", "Кольори"), "TAP_HINT": ("Tap a ball", "Торкнись м’ячика"),
    "FIND_INTRO": ("Let's find the colors.", "Знайдімо кольори."),
}
messages = {}
for index, locale in enumerate(["en", "uk"]):
    path = ROOT / f"data/localization/{locale}.json"
    text = json.loads(path.read_text(encoding="utf-8"))
    for key in ["EXPLORE", "FIND", "CORRECT", "TRY_AGAIN", "COMPLETE", "REPLAY", "REPEAT_WORD"]:
        text["COLORS_"+key] = text["ANIMALS_"+key]
    for key, values in extra.items():
        text["COLORS_"+key] = values[index]
    for entry in entries:
        text[entry["word_key"]] = entry["english"]
        # English stays the learning language, including with Ukrainian navigation.
        text[entry["prompt_key"]] = f'Find something {entry["id"]}.'
    path.write_text(json.dumps(text, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
    messages[locale] = text
jobs_path = ROOT / "data/game_content/voice_jobs.json"
jobs = json.loads(jobs_path.read_text(encoding="utf-8"))
for locale in jobs:
    jobs[locale] = [job for job in jobs[locale] if not job["key"].startswith(("COLOR_", "COLORS_"))]
manifest_path = ROOT / "data/game_content/foundation.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
for suffix in ["TAP_HINT", "FIND_INTRO", "CORRECT", "TRY_AGAIN", "COMPLETE"]:
    key = "COLORS_" + suffix
    manifest["voice"][key] = {}
    for locale in jobs:
        file = f"assets/audio/voice/{locale}/{key.lower()}.wav"
        jobs[locale].append(dict(key=key, text=messages[locale][key], file=file))
        manifest["voice"][key][locale] = "res://"+file
for entry in entries:
    for key_field, audio_field in [("word_key", "word_audio"), ("prompt_key", "prompt_audio")]:
        key, file = entry[key_field], entry[audio_field].removeprefix("res://")
        jobs["en"].append(dict(key=key, text=messages["en"][key]+("." if key_field == "word_key" else ""), file=file))
        manifest["voice"][key] = {"en": "res://"+file, "uk": "res://"+file}
jobs_path.write_text(json.dumps(jobs, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
print("Colors: eight objects, two locales, 26 additional offline clips.")

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
