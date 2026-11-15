"""Reuse original animal artwork for a finite offline puzzle catalog."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
animal_data=json.loads((ROOT/'data/game_content/animals.json').read_text(encoding='utf-8'))['animals']
selected=['cat','dog','rabbit','bear','lion','elephant']
entries=[entry for entry in animal_data if entry['id'] in selected]
(ROOT/'data/game_content/puzzles.json').write_text(json.dumps({'version':1,'puzzles':entries},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
extra={
 'PUZZLES_TITLE': ('Animal puzzles','Пазли з тваринами'),
 'PUZZLES_HINT': ('Drag the pieces into the picture','Перетягни частини на картинку'),
 'PUZZLES_INTRO': ("Let's put the picture together.",'Зберімо картинку разом.'),
 'PUZZLES_CORRECT': ('That piece fits!','Ця частинка підходить!'),
 'PUZZLES_RETRY': ("Let's try another place.",'Спробуймо інше місце.'),
 'PUZZLES_PICTURE_DONE': ('A lovely picture!','Чудова картинка!'),
 'PUZZLES_COMPLETE': ('You made three lovely pictures!','Ти склав три чудові картинки!'),
 'PUZZLES_TEMPLATE': ('Picture hint','Підказка'),
 'PUZZLES_RESTART': ('Restart picture','Зібрати знову'),
 'PUZZLES_NEXT': ('Next picture','Наступна картинка'),
 'PUZZLES_PROGRESS': ('Picture {current} of {total}','Картинка {current} із {total}'),
}
catalogs={}
for i,locale in enumerate(['en','uk']):
 path=ROOT/f'data/localization/{locale}.json'
 text=json.loads(path.read_text(encoding='utf-8'))
 text.update({key:values[i] for key,values in extra.items()})
 path.write_text(json.dumps(text,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 catalogs[locale]=text
jobs_path=ROOT/'data/game_content/voice_jobs.json'
jobs=json.loads(jobs_path.read_text(encoding='utf-8'))
for locale in jobs:
 jobs[locale]=[entry for entry in jobs[locale] if not entry['key'].startswith('PUZZLES_')]
manifest_path=ROOT/'data/game_content/foundation.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
for key in ['PUZZLES_INTRO','PUZZLES_CORRECT','PUZZLES_RETRY','PUZZLES_PICTURE_DONE','PUZZLES_COMPLETE']:
 manifest['voice'][key]={}
 for locale in jobs:
  file=f'assets/audio/voice/{locale}/{key.lower()}.wav'
  jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file))
  manifest['voice'][key][locale]='res://'+file
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Prepared six original animal pictures and ten new local helper clips; word audio reused.')

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
