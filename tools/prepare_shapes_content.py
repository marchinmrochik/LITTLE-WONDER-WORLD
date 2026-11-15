"""Create original shape pieces/silhouettes, localized UI and finite voice jobs."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
SHAPES = [
    ("circle", "Circle", "Коло", "#E29B65", '<circle cx="150" cy="150" r="105"/>'),
    ("square", "Square", "Квадрат", "#75A8BD", '<rect x="48" y="48" width="204" height="204" rx="5"/>'),
    ("triangle", "Triangle", "Трикутник", "#92AE71", '<path d="M150 35L268 252H32Z"/>'),
    ("rectangle", "Rectangle", "Прямокутник", "#AC8BC2", '<rect x="25" y="82" width="250" height="136" rx="5"/>'),
    ("star", "Star", "Зірка", "#E8C365", '<path d="M150 25L184 109L275 117L205 176L226 265L150 218L74 265L95 176L25 117L116 109Z"/>'),
    ("heart", "Heart", "Серце", "#DC8F9C", '<path d="M150 263C125 239 30 172 30 103C30 25 119 20 150 82C181 20 270 25 270 103C270 172 175 239 150 263Z"/>'),
]
entries=[]
for id,en,uk,color,geometry in SHAPES:
    directory=ROOT/'assets/objects/shapes'
    directory.mkdir(parents=True,exist_ok=True)
    for suffix,fill,stroke in [("",color,"#526B60"),("_slot","#E4E9DC","#8EAA99")]:
        (directory/f'{id}{suffix}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300"><g fill="{fill}" stroke="{stroke}" stroke-width="6" stroke-linejoin="round">{geometry}</g></svg>\n',encoding='utf-8')
    entries.append(dict(id=id,english=en,ukrainian=uk,illustration=f'res://assets/objects/shapes/{id}.svg',slot=f'res://assets/objects/shapes/{id}_slot.svg',word_key='SHAPE_WORD_'+id.upper(),prompt_key='SHAPE_FIND_'+id.upper(),word_audio=f'res://assets/audio/voice/en/shape_word_{id}.wav',prompt_audio=f'res://assets/audio/voice/en/shape_find_{id}.wav'))
(ROOT/'data/game_content/shapes.json').write_text(json.dumps({'version':1,'shapes':entries},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
extra={
    'SHAPES_TITLE': ('Shape garden','Сад фігур'),
    'SHAPES_HINT': ('Drag each shape to its outline','Перетягни фігуру до її контуру'),
    'SHAPES_INTRO': ("Let's match the shapes.",'Знайдімо місце для фігур.'),
    'SHAPES_CORRECT': ('A lovely match!','Чудово підходить!'),
    'SHAPES_RETRY': ("Let's try another outline.",'Спробуймо інший контур.'),
    'SHAPES_BOARD_DONE': ('This garden is ready!','Цей сад готовий!'),
    'SHAPES_COMPLETE': ('You matched all the shapes!','Усі фігури на місці!'),
    'SHAPES_REPEAT': ('Repeat the shape word','Повторити назву фігури'),
    'SHAPES_BOARD': ('Garden {current} of {total}','Сад {current} із {total}'),
}
catalogs={}
for i,locale in enumerate(['en','uk']):
    path=ROOT/f'data/localization/{locale}.json'
    text=json.loads(path.read_text(encoding='utf-8'))
    text.update({key:value[i] for key,value in extra.items()})
    for entry in entries:
        text[entry['word_key']]=entry['english']
        text[entry['prompt_key']]='Find the '+entry['id']+'.'
    path.write_text(json.dumps(text,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    catalogs[locale]=text
jobs_path=ROOT/'data/game_content/voice_jobs.json'
jobs=json.loads(jobs_path.read_text(encoding='utf-8'))
for locale in jobs:
    jobs[locale]=[j for j in jobs[locale] if not j['key'].startswith(('SHAPE_','SHAPES_'))]
manifest_path=ROOT/'data/game_content/foundation.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
for key in ['SHAPES_INTRO','SHAPES_CORRECT','SHAPES_RETRY','SHAPES_BOARD_DONE','SHAPES_COMPLETE']:
    manifest['voice'][key]={}
    for locale in jobs:
        file=f'assets/audio/voice/{locale}/{key.lower()}.wav'
        jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file))
        manifest['voice'][key][locale]='res://'+file
for entry in entries:
    for field,audio in [('word_key','word_audio'),('prompt_key','prompt_audio')]:
        key,file=entry[field],entry[audio].removeprefix('res://')
        jobs['en'].append(dict(key=key,text=catalogs['en'][key]+('.' if field=='word_key' else ''),file=file))
        manifest['voice'][key]={'en':'res://'+file,'uk':'res://'+file}
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Prepared six shape pieces, six neutral slots and 22 offline speech clips.')

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
