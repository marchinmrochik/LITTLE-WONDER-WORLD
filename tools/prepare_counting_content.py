"""Prepare reusable counting themes, number words and finite offline prompts."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[1]
themes=[]
for collection,id,plural in [('foods','apple','apples'),('foods','carrot','carrots'),('foods','strawberry','strawberries'),('shapes','star','stars')]:
 data=json.loads((ROOT/f'data/game_content/{collection}.json').read_text(encoding='utf-8'))[collection]
 entry=next(item for item in data if item['id']==id)
 themes.append({**entry,'id':plural,'singular':entry['english'].lower(),'plural':plural,'question_key':'COUNT_HOW_'+plural.upper()})
(ROOT/'data/game_content/counting.json').write_text(json.dumps({'version':1,'counting':themes},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
words=['one','two','three','four','five','six','seven','eight','nine','ten']
extra={
 'COUNT_TITLE': ('Numbers and counting','Цифри й лічба'),
 'COUNT_TRACE': ('Trace digits','Обвести цифри'),
 'COUNT_CHOICE': ('How many?','Скільки?'),
 'COUNT_BASKET': ('Basket','Кошик'),
 'COUNT_CHECK': ('All ready!','Готово!'),
 'COUNT_REMOVE': ('Tap a basket item to return it','Торкнись предмета в кошику, щоб повернути'),
 'COUNT_CORRECT': ('You counted it!','Ти порахував!'),
 'COUNT_RETRY': ("Let's count again.",'Порахуймо ще.'),
 'COUNT_COMPLETE': ('What lovely counting!','Як чудово ти рахуєш!'),
 'COUNT_RANGE': ('Numbers 1-{limit}','Числа 1–{limit}'),
}
catalogs={}
for i,locale in enumerate(['en','uk']):
 path=ROOT/f'data/localization/{locale}.json'
 text=json.loads(path.read_text(encoding='utf-8'))
 text.update({key:value[i] for key,value in extra.items()})
 for number,word in enumerate(words,1): text[f'COUNT_NUMBER_{number}']=word.capitalize()
 for theme in themes:
  text[theme['question_key']]='How many '+theme['plural']+'?'
  for number,word in enumerate(words,1):
   text[f"COUNT_PUT_{theme['id'].upper()}_{number}"]=f"Put {word} {theme['singular'] if number==1 else theme['plural']} in the basket."
 path.write_text(json.dumps(text,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 catalogs[locale]=text
jobs_path=ROOT/'data/game_content/voice_jobs.json'
jobs=json.loads(jobs_path.read_text(encoding='utf-8'))
for locale in jobs: jobs[locale]=[job for job in jobs[locale] if not job['key'].startswith('COUNT_')]
manifest_path=ROOT/'data/game_content/foundation.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
for key in ['COUNT_CORRECT','COUNT_RETRY','COUNT_COMPLETE']:
 manifest['voice'][key]={}
 for locale in jobs:
  file=f'assets/audio/voice/{locale}/{key.lower()}.wav'
  jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file))
  manifest['voice'][key][locale]='res://'+file
keys=[f'COUNT_NUMBER_{number}' for number in range(1,11)]
keys += [theme['question_key'] for theme in themes]
keys += [f"COUNT_PUT_{theme['id'].upper()}_{number}" for theme in themes for number in range(1,11)]
for key in keys:
 file=f'assets/audio/voice/en/{key.lower()}.wav'
 jobs['en'].append(dict(key=key,text=catalogs['en'][key]+('.' if key.startswith('COUNT_NUMBER_') else ''),file=file))
 manifest['voice'][key]={'en':'res://'+file,'uk':'res://'+file}
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Prepared four counting themes and 60 offline number/instruction/helper clips.')

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
