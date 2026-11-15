"""Author original food illustrations and offline feeding vocabulary."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
FOODS = [
    ("apple", "Apple", "Яблуко", "an apple", '<path d="M150 83C90 39 39 102 68 181C88 241 123 253 150 235C182 255 219 233 236 173C261 97 205 44 150 83Z" fill="#DB6757"/><path d="M150 82L160 43" stroke="#75513C" stroke-width="12"/><path d="M161 58Q172 16 209 35Q192 69 161 58" fill="#74A56A"/>'),
    ("banana", "Banana", "Банан", "a banana", '<path d="M67 63Q130 212 238 90Q240 220 135 235Q38 226 52 82Z" fill="#F1CD58"/><path d="M75 100Q121 227 218 133" fill="none" stroke="#D6A84C" stroke-width="7"/><path d="M54 80L53 55L72 50L77 72" fill="#785A3E"/>'),
    ("carrot", "Carrot", "Морква", "a carrot", '<path d="M103 94Q149 59 192 98L143 249Q128 262 121 238Z" fill="#EA974D"/><path d="M145 84Q89 32 119 26L151 73Q150 9 171 24L163 78Q207 26 211 48L174 94" fill="#71A165"/><path d="M113 128L143 136M158 168L174 174M125 201L141 206" stroke="#C57139" stroke-width="7"/>'),
    ("bread", "Bread", "Хліб", "some bread", '<path d="M77 121C17 65 104 30 150 59C200 26 283 72 222 124V241H77Z" fill="#BC8450"/><path d="M93 126C48 75 108 54 150 78C198 52 248 82 206 126V224H93Z" fill="#F5D79F"/>'),
    ("cheese", "Cheese", "Сир", "some cheese", '<path d="M55 126L185 65L245 118V224H55Z" fill="#F2CB58"/><path d="M55 126L245 118L185 65Z" fill="#FFE394"/><g fill="#D4A244"><circle cx="98" cy="169" r="17"/><circle cx="190" cy="192" r="20"/><circle cx="165" cy="146" r="11"/></g>'),
    ("milk", "Milk", "Молоко", "some milk", '<path d="M88 93L120 49H187L216 93V244H88Z" fill="#E9F0E8"/><path d="M88 93H216V134H88ZM88 207H216V244H88Z" fill="#78ACC5"/><path d="M120 49V93H216" fill="none" stroke="#A4B8B9" stroke-width="5"/><path d="M152 148Q118 185 152 191Q184 184 152 148" fill="#78ACC5"/>'),
    ("strawberry", "Strawberry", "Полуниця", "a strawberry", '<path d="M64 116Q65 69 150 83Q236 67 238 117Q233 181 150 249Q77 194 64 116" fill="#DB6370"/><path d="M150 92L97 59L112 96L68 105L128 120L151 101L177 121L231 101L185 91L199 58Z" fill="#70A46B"/><g fill="#FFE8AA"><ellipse cx="105" cy="143" rx="4" ry="8"/><ellipse cx="155" cy="139" rx="4" ry="8"/><ellipse cx="199" cy="142" rx="4" ry="8"/><ellipse cx="129" cy="184" rx="4" ry="8"/><ellipse cx="178" cy="180" rx="4" ry="8"/><ellipse cx="151" cy="217" rx="4" ry="8"/></g>'),
    ("watermelon", "Watermelon", "Кавун", "some watermelon", '<path d="M44 94H256Q244 246 150 248Q56 239 44 94" fill="#689866"/><path d="M56 94H244Q231 228 150 231Q73 222 56 94" fill="#DAE5AB"/><path d="M69 94H231Q217 211 150 216Q87 211 69 94" fill="#E37B77"/><g fill="#5C5145"><ellipse cx="106" cy="131" rx="5" ry="9"/><ellipse cx="151" cy="157" rx="5" ry="9"/><ellipse cx="191" cy="128" rx="5" ry="9"/><ellipse cx="131" cy="187" rx="5" ry="9"/></g>'),
    ("orange", "Orange", "Апельсин", "an orange", '<circle cx="150" cy="161" r="88" fill="#EDAA51"/><path d="M147 76Q160 29 203 51Q190 89 147 76" fill="#7AA66B"/><path d="M105 105Q80 122 81 151" fill="none" stroke="#F9CB7C" stroke-width="12" stroke-linecap="round"/>'),
    ("pear", "Pear", "Груша", "a pear", '<path d="M123 76Q151 52 178 78L188 121Q253 181 214 225Q158 269 94 228Q55 196 104 135Z" fill="#B9C66A"/><path d="M150 70L163 35" stroke="#816247" stroke-width="10"/><path d="M161 52Q182 17 210 45Q191 70 161 52" fill="#75A16B"/>'),
    ("cucumber", "Cucumber", "Огірок", "a cucumber", '<rect x="111" y="43" width="79" height="218" rx="39" transform="rotate(30 150 150)" fill="#72A26D"/><path d="M178 67L95 217" stroke="#98BB7D" stroke-width="8" stroke-linecap="round"/><g fill="#54875A"><circle cx="151" cy="110" r="4"/><circle cx="159" cy="151" r="4"/><circle cx="116" cy="181" r="4"/><circle cx="130" cy="211" r="4"/></g>'),
    ("tomato", "Tomato", "Помідор", "a tomato", '<ellipse cx="150" cy="168" rx="96" ry="81" fill="#DF7360"/><path d="M150 103L100 69L122 111L82 119L137 130L155 110L181 130L224 114L179 103L197 69Z" fill="#71A16A"/><path d="M151 102L159 56" stroke="#64915D" stroke-width="9"/><path d="M95 145Q79 160 83 180" fill="none" stroke="#F0A68C" stroke-width="10" stroke-linecap="round"/>'),
]
entries = []
for id, english, ukrainian, request, drawing in FOODS:
    path = ROOT / f"assets/objects/food/{id}.svg"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300"><ellipse cx="150" cy="261" rx="92" ry="12" fill="#DEE5D5"/>{drawing}</svg>\n', encoding="utf-8")
    entries.append(dict(id=id, english=english, ukrainian=ukrainian,
        illustration=f"res://assets/objects/food/{id}.svg",
        word_key="FOOD_WORD_"+id.upper(), prompt_key="FOOD_GIVE_"+id.upper(),
        word_audio=f"res://assets/audio/voice/en/food_word_{id}.wav",
        prompt_audio=f"res://assets/audio/voice/en/food_give_{id}.wav", request=f"Give me {request}, please."))
(ROOT / "data/game_content/foods.json").write_text(json.dumps({"version":1,"foods":entries},ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
extra = {
    "FEED_TITLE": ("Snack time", "Час перекусити"),
    "FEED_HINT": ("Drag the food to Foxie", "Перетягни їжу до Фоксі"),
    "FEED_DROP": ("Bring it here!", "Неси сюди!"),
    "FEED_CORRECT": ("Yum! Thank you.", "Ням! Дякую."),
    "FEED_TRY_AGAIN": ("Let's try another one.", "Спробуймо інше."),
    "FEED_COMPLETE": ("What a lovely picnic!", "Який чудовий пікнік!"),
    "FEED_REPEAT_WORD": ("Repeat the food word", "Повторити назву їжі"),
}
catalogs = {}
for index, locale in enumerate(["en","uk"]):
    path=ROOT/f"data/localization/{locale}.json"
    text=json.loads(path.read_text(encoding="utf-8"))
    text.update({key:values[index] for key,values in extra.items()})
    for entry in entries:
        text[entry["word_key"]]=entry["english"]
        text[entry["prompt_key"]]=entry["request"]
    path.write_text(json.dumps(text,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    catalogs[locale]=text
jobs_path=ROOT/"data/game_content/voice_jobs.json"
jobs=json.loads(jobs_path.read_text(encoding="utf-8"))
for locale in jobs:
    jobs[locale]=[j for j in jobs[locale] if not j["key"].startswith(("FOOD_","FEED_"))]
manifest_path=ROOT/"data/game_content/foundation.json"
manifest=json.loads(manifest_path.read_text(encoding="utf-8"))
for key in ["FEED_HINT","FEED_CORRECT","FEED_TRY_AGAIN","FEED_COMPLETE"]:
    manifest["voice"][key]={}
    for locale in jobs:
        file=f"assets/audio/voice/{locale}/{key.lower()}.wav"
        jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file))
        manifest["voice"][key][locale]="res://"+file
for entry in entries:
    for field,audio in [("word_key","word_audio"),("prompt_key","prompt_audio")]:
        key,file=entry[field],entry[audio].removeprefix("res://")
        jobs["en"].append(dict(key=key,text=catalogs["en"][key]+("." if field=="word_key" else ""),file=file))
        manifest["voice"][key]={"en":"res://"+file,"uk":"res://"+file}
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("Prepared twelve original foods and 32 offline speech jobs.")

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
