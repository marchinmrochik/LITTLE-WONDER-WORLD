"""Original gentle pop sound and finite localized celebration prompts."""
from pathlib import Path
import array,json,math,wave,runpy

ROOT=Path(__file__).resolve().parents[1]
for locale,values in {
 'en':{'PARTY_TITLE':'Well done! All finished!','PARTY_HINT':'Pop every balloon!','PARTY_REMAINING':'Balloons left: {count}','PARTY_INTRO':'Well done! All finished! Pop every balloon!'},
 'uk':{'PARTY_TITLE':'Молодець! Завдання завершено!','PARTY_HINT':'Лопни всі кульки!','PARTY_REMAINING':'Залишилося кульок: {count}','PARTY_INTRO':'Молодець! Завдання завершено! Лопни всі кульки!'},
}.items():
 path=ROOT/f'data/localization/{locale}.json';data=json.loads(path.read_text(encoding='utf-8'));data.update(values)
 path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path=ROOT/'data/game_content/foundation.json';manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
manifest['voice']['PARTY_INTRO']={locale:f'res://assets/audio/voice/{locale}/party_intro.wav' for locale in ['en','uk']}
manifest['sfx']['balloon_pop']='res://assets/audio/sfx/balloon_pop.wav'
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
jobs_path=ROOT/'data/game_content/voice_jobs.json';jobs=json.loads(jobs_path.read_text(encoding='utf-8'))
for locale in ['en','uk']:
 jobs[locale]=[job for job in jobs[locale] if job['key']!='PARTY_INTRO']
 text=json.loads((ROOT/f'data/localization/{locale}.json').read_text(encoding='utf-8'))['PARTY_INTRO']
 jobs[locale].append({'key':'PARTY_INTRO','text':text,'file':f'assets/audio/voice/{locale}/party_intro.wav'})
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
rate=44100;samples=array.array('h')
for i in range(int(rate*.14)):
 t=i/rate
 value=math.sin(2*math.pi*(600*t-1050*t*t))*math.exp(-t*38)
 envelope=min(1,t/.003,(.14-t)/.012)
 samples.append(round(32767*.14*value*max(0,envelope)))
path=ROOT/'assets/audio/sfx/balloon_pop.wav'
with wave.open(str(path),'wb') as out:
 out.setparams((1,2,rate,0,'NONE','not compressed'));out.writeframes(samples.tobytes())
runpy.run_path(str(ROOT/'tools/prepare_full_ukrainian.py'),run_name='__main__')
print('Completion prompt and original gentle pop prepared.')
