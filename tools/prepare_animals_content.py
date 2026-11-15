"""Prepare localized Animals text and finite offline voice-generation jobs."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
catalog = json.loads((ROOT / "data/game_content/animals.json").read_text(encoding="utf-8"))["animals"]
extra = {
    "ACTIVITIES_TITLE": ("Choose a little adventure", "РћР±РµСЂРё РјР°Р»РµРЅСЊРєСѓ РїСЂРёРіРѕРґСѓ"),
    "SECTION_ENGLISH": ("English", "РђРЅРіР»С–Р№СЃСЊРєР°"),
    "ANIMALS_TITLE": ("Animals", "РўРІР°СЂРёРЅРё"),
    "ANIMALS_EXPLORE": ("Explore", "Р—РЅР°Р№РѕРјСЃС‚РІРѕ"),
    "ANIMALS_FIND": ("Find", "Р—РЅР°Р№РґРё"),
    "ANIMALS_TAP_HINT": ("Tap an animal", "РўРѕСЂРєРЅРёСЃСЊ С‚РІР°СЂРёРЅРєРё"),
    "ANIMALS_FIND_INTRO": ("Let's find the animals!", "Р—РЅР°Р№РґС–РјРѕ С‚РІР°СЂРёРЅРѕРє!"),
    "ANIMALS_CORRECT": ("Great job!", "РњРѕР»РѕРґРµС†СЊ!"),
    "ANIMALS_TRY_AGAIN": ("Let's try again!", "РЎРїСЂРѕР±СѓР№РјРѕ С‰Рµ!"),
    "ANIMALS_COMPLETE": ("You did it!", "РЈ С‚РµР±Рµ РІРёР№С€Р»Рѕ!"),
    "ANIMALS_REPLAY": ("Play again", "Р©Рµ СЂР°Р·"),
    "ANIMALS_REPEAT_WORD": ("Repeat the English word", "РџРѕРІС‚РѕСЂРёС‚Рё Р°РЅРіР»С–Р№СЃСЊРєРµ СЃР»РѕРІРѕ"),
    "VOICE_NOTE": ("Local English and Ukrainian speech is included. These are synthesized voices; pronunciation and tone are under review.", "Р”РѕРґР°РЅРѕ Р»РѕРєР°Р»СЊРЅСѓ Р°РЅРіР»С–Р№СЃСЊРєСѓ С‚Р° СѓРєСЂР°С—РЅСЃСЊРєСѓ РѕР·РІСѓС‡РєСѓ. Р“РѕР»РѕСЃРё СЃРёРЅС‚РµР·РѕРІР°РЅС–; РІРёРјРѕРІСѓ Р№ С–РЅС‚РѕРЅР°С†С–СЋ С‰Рµ РїРµСЂРµРІС–СЂСЏС”РјРѕ."),
    "SYSTEM_VOICE_NOTE": ("Optional system voices are a fallback only. They may need internet; offline behavior must be checked separately.", "РЎРёСЃС‚РµРјРЅС– РіРѕР»РѕСЃРё вЂ” Р»РёС€Рµ Р·Р°РїР°СЃРЅРёР№ РІР°СЂС–Р°РЅС‚. Р‡Рј РјРѕР¶Рµ Р±СѓС‚Рё РїРѕС‚СЂС–Р±РµРЅ С–РЅС‚РµСЂРЅРµС‚; СЂРѕР±РѕС‚Сѓ Р±РµР· РјРµСЂРµР¶С– СЃР»С–Рґ РїРµСЂРµРІС–СЂРёС‚Рё РѕРєСЂРµРјРѕ."),
    "COMPLETED_ANIMAL_SESSIONS": ("Animal adventures completed: {count}", "Р—Р°РІРµСЂС€РµРЅС– РїСЂРёРіРѕРґРё Р· С‚РІР°СЂРёРЅР°РјРё: {count}"),
}
accusatives = ["РєРѕС‚Р°", "СЃРѕР±Р°РєСѓ", "РєРѕСЂРѕРІСѓ", "СЃРІРёРЅРєСѓ", "РІС–РІС†СЋ", "РєРѕРЅСЏ", "РєР°С‡РєСѓ", "РєСѓСЂРєСѓ", "РєСЂРѕР»РёРєР°", "РІРµРґРјРµРґСЏ", "Р»РµРІР°", "СЃР»РѕРЅР°"]
catalogs = {}
for index, locale in enumerate(["en", "uk"]):
    path = ROOT / f"data/localization/{locale}.json"
    messages = json.loads(path.read_text(encoding="utf-8-sig"))
    messages.update({key: value[index] for key, value in extra.items()})
    for entry, accusative in zip(catalog, accusatives):
        messages[entry["word_key"]] = entry["english"]
        messages[entry["prompt_key"]] = f'Find the {entry["english"].lower()}!' if locale == "en" else f"Р—РЅР°Р№РґРё {accusative}!"
    path.write_text(json.dumps(messages, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
    catalogs[locale] = messages

manifest_path = ROOT / "data/game_content/foundation.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
voice = manifest["voice"]
previous_jobs = json.loads((ROOT / "data/game_content/voice_jobs.json").read_text(encoding="utf-8"))
jobs = {locale: [job for job in entries if job["key"].startswith(("COLOR_", "COLORS_", "FOOD_", "FEED_", "SHAPE_", "SHAPES_", "PUZZLES_", "MEMORY_", "COUNT_", "DRAW_", "BOOK_", "PARTY_", "ALPH_", "BLEND_", "WORLD_"))] for locale, entries in previous_jobs.items()}
spoken_ui = ["FOX_HELLO", "FOX_HAPPY", "FOX_REST", "ANIMALS_TAP_HINT", "ANIMALS_FIND_INTRO", "ANIMALS_CORRECT", "ANIMALS_TRY_AGAIN", "ANIMALS_COMPLETE"]
for key in spoken_ui:
    voice[key] = {}
    for locale in jobs:
        relative = f"assets/audio/voice/{locale}/{key.lower()}.wav"
        voice[key][locale] = "res://" + relative
        jobs[locale].append({"key": key, "text": catalogs[locale][key], "file": relative})
for entry in catalog:
    voice[entry["word_key"]] = {"en": entry["word_audio"], "uk": entry["word_audio"]}
    jobs["en"].append({"key": entry["word_key"], "text": entry["english"] + ".", "file": entry["word_audio"].removeprefix("res://")})
    voice[entry["prompt_key"]] = {}
    for locale in jobs:
        relative = f'assets/audio/voice/{locale}/find_{entry["id"]}.wav'
        voice[entry["prompt_key"]][locale] = "res://" + relative
        jobs[locale].append({"key": entry["prompt_key"], "text": catalogs[locale][entry["prompt_key"]], "file": relative})
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
(ROOT / "data/game_content/voice_jobs.json").write_text(json.dumps(jobs, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
print("Prepared EN/UK catalogs and", sum(map(len, jobs.values())), "local speech jobs.")

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
