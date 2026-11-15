"""Apply the user's full-locale policy after any activity authoring helpers."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
def read(path): return json.loads((ROOT/path).read_text(encoding='utf-8'))
def write(path,value): (ROOT/path).write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
uk=read('data/localization/uk.json')
en=read('data/localization/en.json')
accusative={'cat':'кота','dog':'собаку','cow':'корову','pig':'свинку','sheep':'вівцю','horse':'коня','duck':'качку','chicken':'курку','rabbit':'кролика','bear':'ведмедя','lion':'лева','elephant':'слона',
 'apple':'яблуко','banana':'банан','carrot':'моркву','bread':'хліб','cheese':'сир','milk':'молоко','strawberry':'полуницю','watermelon':'кавун','orange':'апельсин','pear':'грушу','cucumber':'огірок','tomato':'помідор',
 'circle':'коло','square':'квадрат','triangle':'трикутник','rectangle':'прямокутник','star':'зірку','heart':'серце'}
colors={'red':'червоний','blue':'синій','yellow':'жовтий','green':'зелений','orange':'помаранчевий','purple':'фіолетовий','pink':'рожевий','brown':'коричневий'}
for filename,collection in [('animals','animals'),('colors','colors'),('foods','foods'),('shapes','shapes')]:
 for item in read(f'data/game_content/{filename}.json')[collection]:
  uk[item['word_key']]=item['ukrainian']
  if filename=='colors':uk[item['prompt_key']]=f"Знайди {colors[item['id']]} колір."
  elif filename=='foods':uk[item['prompt_key']]=f"Дай мені {accusative[item['id']]}, будь ласка."
  else:uk[item['prompt_key']]=f"Знайди {accusative[item['id']]}."
for page in read('data/game_content/coloring.json')['pages']:uk[page['word_key']]=page['ukrainian']
numbers=['нуль','один','два','три','чотири',"п'ять",'шість','сім','вісім',"дев'ять",'десять']
for i in range(1,11):uk[f'COUNT_NUMBER_{i}']=numbers[i].capitalize()
for theme,forms,question in [('APPLES',['яблуко','яблука','яблук'],'Скільки яблук?'),('CARROTS',['морквину','морквини','морквин'],'Скільки морквин?'),('STRAWBERRIES',['полуницю','полуниці','полуниць'],'Скільки полуниць?'),('STARS',['зірку','зірки','зірок'],'Скільки зірок?')]:
 uk[f'COUNT_HOW_{theme}']=question
 for i in range(1,11):
  number=('одне' if theme=='APPLES' else 'одну') if i==1 else ('два' if theme=='APPLES' else 'дві') if i==2 else numbers[i]
  noun=forms[0 if i==1 else 1 if i in [2,3,4] else 2]
  uk[f'COUNT_PUT_{theme}_{i}']=f'Поклади {number} {noun} в кошик.'
uk.update({'ENGLISH':'Англійська','LANGUAGE_HINT':'Усі назви, завдання та голос відповідають вибраній мові.','SECTION_ENGLISH':'Пізнання','ANIMALS_REPEAT_WORD':'Повторити назву','COLORS_REPEAT_WORD':'Повторити назву','MEMORY_REPEAT_WORD':'Повторити назву','PUZZLES_REPEAT_WORD':'Повторити назву','APP_TITLE':'Маленький дивосвіт','WORDMARK':'Маленький\nдивосвіт','MEADOW_TITLE':'Галявина друзів','COMPANION_VISITS':'Відвідування галявини друзів: {count}'})
en['LANGUAGE_HINT']='Names, instructions and speech follow the selected language.'
en.update({'MEMORY_REPEAT_WORD':'Repeat name','PUZZLES_REPEAT_WORD':'Repeat name'})
for key in list(uk):uk[key]=uk[key].replace('Foxie','Фоксі').replace('англійське слово','назву').replace('англійські слова','назви')
write('data/localization/uk.json',uk);write('data/localization/en.json',en)
manifest=read('data/game_content/foundation.json')
jobs=read('data/game_content/voice_jobs.json')
study=manifest.get('study_locales',{})
study_jobs={j['key']:j for entries in jobs.values() for j in entries if j['key'] in study}
jobs['uk']=[]
for key,locales in manifest['voice'].items():
 if key in study:
  if study[key]=='uk':jobs['uk'].append(study_jobs[key])
  continue
 path=f'assets/audio/voice/uk/{key.lower()}.wav'
 locales['uk']='res://'+path
 jobs['uk'].append({'key':key,'text':uk[key],'file':path})
write('data/game_content/foundation.json',manifest);write('data/game_content/voice_jobs.json',jobs)
print(f'Full Ukrainian prepared: {len(jobs["uk"])} distinct localized recordings.')
