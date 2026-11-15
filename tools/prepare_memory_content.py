"""Build finite memory content from familiar original animal/food/shape art."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
entries=[]
for collection,ids,prefix in [('animals',['cat','dog','rabbit','bear'],'animal'),('foods',['apple','banana','carrot','strawberry'],'food'),('shapes',['circle','square','star','heart'],'shape')]:
 data=json.loads((ROOT/f'data/game_content/{collection}.json').read_text(encoding='utf-8'))[collection]
 for entry in data:
  if entry['id'] in ids:
   entries.append({**entry,'id':prefix+'_'+entry['id']})
(ROOT/'data/game_content/memory.json').write_text(json.dumps({'version':1,'memory':entries},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
extra={
 'MEMORY_TITLE': ('Find the pairs','Знайди пари'),
 'MEMORY_INTRO': ('Turn over two cards.','Відкрий дві картки.'),
 'MEMORY_MATCH': ('A lovely pair!','Чудова пара!'),
 'MEMORY_RETRY': ("Let's look again.",'Пошукаймо ще.'),
 'MEMORY_COMPLETE': ('You found all the pairs!','Ти знайшов усі пари!'),
 'MEMORY_PROGRESS': ('Pairs {found} of {total}','Пари: {found} із {total}'),
 'ACTIVITIES_PAGE': ('Page {current} of {total}','Сторінка {current} із {total}'),
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
 jobs[locale]=[job for job in jobs[locale] if not job['key'].startswith('MEMORY_')]
manifest_path=ROOT/'data/game_content/foundation.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
for key in ['MEMORY_INTRO','MEMORY_MATCH','MEMORY_RETRY','MEMORY_COMPLETE']:
 manifest['voice'][key]={}
 for locale in jobs:
  file=f'assets/audio/voice/{locale}/{key.lower()}.wav'
  jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file))
  manifest['voice'][key][locale]='res://'+file
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Prepared twelve familiar pictures and eight new offline helper clips.')

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
