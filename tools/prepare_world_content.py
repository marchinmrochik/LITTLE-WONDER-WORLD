"""Original topic illustrations, finite bilingual vocabulary and UI authoring."""
from pathlib import Path
import json,runpy
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def write(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
en=read('data/localization/en.json');uk=read('data/localization/uk.json')
texts={
'RESET_HINT':('Game practice counts will be cleared. Check history, settings and drawings are kept.','Лічильники ігор буде скинуто. Історія перевірок, налаштування та малюнки залишаться.'),
'WORLD_TITLE':('Discover the world','Пізнаємо світ'),'WORLD_ANIMALS':('Animals','Тварини'),'WORLD_BODY':('My body','Моє тіло'),'WORLD_PLANTS':('Plants','Рослини'),
'WORLD_EXPLORE':('Explore','Знайомство'),'WORLD_CHECK':('Remember together','Пригадаймо'),'WORLD_TAP':('Tap a picture and listen.','Натисни на малюнок та послухай.'),
'WORLD_BODY_TAP':('Tap a body part. Tap the head to look closer.','Натисни на частину тіла. Натисни на голову, щоб роздивитися ближче.'),
'WORLD_ZOOM':('Face / whole body','Обличчя / усе тіло'),'WORLD_PROGRESS':('Picture {current} of {total}','Малюнок {current} із {total}'),
'HISTORY_RETRIES':('Additional attempts: {count}','Повторних спроб: {count}'),
'HISTORY_TITLE':('My practice history','Історія моєї практики'),'HISTORY_OPEN':('View checks and compare','Перевірки та порівняння'),'HISTORY_EMPTY':('New checks will appear here. Earlier totals stay in practice.','Тут з’являться нові перевірки. Попередні підсумки залишаються в практиці.'),
'HISTORY_DATE':('Date','Дата'),'HISTORY_TOPIC':('Topic','Тема'),'HISTORY_MODE':('Language / level','Мова / рівень'),'HISTORY_FIRST':('First try, no hint','З першого разу, без підказки'),'HISTORY_HELP':('With a hint','З підказкою'),'HISTORY_COMPARE':('Previous → this time','Попередня → ця спроба'),
'HISTORY_INCOMPLETE':('Not finished','Не завершено'),'HISTORY_NO_MATCH':('No comparable check yet','Ще немає схожої перевірки'),'HISTORY_UNKNOWN':('Earlier topic','Попередня тема'),'HISTORY_LIMIT':('Latest 100 checks. Only matching completed checks are compared.','Останні 100 перевірок. Порівнюються лише завершені перевірки з однаковими умовами.'),
}
for key,(a,b) in texts.items():en[key]=a;uk[key]=b
manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
for locale in jobs:jobs[locale]=[j for j in jobs[locale] if not j['key'].startswith('WORLD_')]
def entry(topic,id,a,b,acc,**extra):
 prefix=f'WORLD_{topic.upper()}_{id.upper()}'
 for key,english,ukrainian in [(prefix+'_WORD',a+'.',b+'.'),(prefix+'_FIND',('Show me the ' if topic=='body' else 'Find the ')+a.lower()+'.','Покажи '+acc+'.' if topic=='body' else 'Знайди '+acc+'.')]:
  en[key]=english;uk[key]=ukrainian;manifest['voice'][key]={}
  for locale,text in [('en',english),('uk',ukrainian)]:
   file=f'assets/audio/voice/{locale}/{key.lower()}.wav'
   manifest['voice'][key][locale]='res://'+file;jobs[locale].append({'key':key,'text':text,'file':file})
 return {'id':id,'english':a,'ukrainian':b,'word_key':prefix+'_WORD','prompt_key':prefix+'_FIND',**extra}
body=[]
for row in [
 ('head','Head','Голова','голову','face',[[230,35,140,60]]),('eye','Eye','Око','око','face',[[230,100,55,40],[315,100,55,40]]),
 ('nose','Nose','Ніс','ніс','face',[[275,140,50,42]]),('mouth','Mouth','Рот','рот','face',[[260,182,80,42]]),('ear','Ear','Вухо','вухо','face',[[175,100,40,85],[385,100,40,85]]),
 ('arm','Arm','Рука','руку','body',[[180,250,75,70],[345,250,75,70]]),('hand','Hand','Долоня','долоню','body',[[105,320,90,75],[405,320,90,75]]),
 ('leg','Leg','Нога','ногу','body',[[235,460,55,90],[310,460,55,90]]),('foot','Foot','Ступня','ступню','body',[[205,550,90,70],[305,550,90,70]])]:
 id,a,b,acc,view,areas=row;body.append(entry('body',id,a,b,acc,view=view,areas=areas))
plants=[]
for id,a,b,acc in [('tree','Tree','Дерево','дерево'),('flower','Flower','Квітка','квітку'),('grass','Grass','Трава','траву'),('leaf','Leaf','Листок','листок'),('seed','Seed','Насінина','насінину'),('root','Root','Корінь','корінь'),('bush','Bush','Кущ','кущ'),('pine','Pine','Сосна','сосну')]:
 plants.append(entry('plants',id,a,b,acc,illustration=f'res://assets/objects/world/{id}.svg'))
animals=read('data/game_content/animals.json')['animals']
write('data/game_content/world_animals.json',{'version':1,'items':animals})
write('data/game_content/world_body.json',{'version':1,'items':body})
write('data/game_content/world_plants.json',{'version':1,'items':plants})
topics=[{'id':id,'title_key':title,'revision':1,'kind':kind,'catalog':f'res://data/game_content/world_{id}.json','illustration':art,'check_items':ids} for id,title,kind,art,ids in [
 ('animals','WORLD_ANIMALS','cards','res://assets/objects/animals/cat.svg',['cat','dog','cow','rabbit','elephant']),
 ('body','WORLD_BODY','body','res://assets/objects/world/body.svg',['eye','nose','arm','leg','foot']),
 ('plants','WORLD_PLANTS','cards','res://assets/objects/world/flower.svg',['tree','flower','leaf','seed','root'])]]
write('data/game_content/world_topics.json',{'version':1,'topics':topics})
out=ROOT/'assets/objects/world';out.mkdir(parents=True,exist_ok=True)
art={
'tree':'<path d="M135 215L142 110H162L170 215" fill="#aa8058"/><path d="M60 125C20 60 100 15 140 48C190 5 255 55 228 110C270 168 155 185 145 158C100 190 45 170 60 125" fill="#80b280"/>',
'flower':'<path d="M150 220V110M150 175Q85 135 85 173Q110 208 150 175M150 184Q215 142 217 176Q190 213 150 184" fill="#80b280"/><g fill="#e995b4"><circle cx="150" cy="55" r="30"/><circle cx="112" cy="82" r="30"/><circle cx="188" cy="82" r="30"/><circle cx="128" cy="123" r="30"/><circle cx="172" cy="123" r="30"/></g><circle cx="150" cy="90" r="28" fill="#efce55"/>',
'grass':'<path d="M55 218L35 123L83 166L98 75L130 161L152 63L171 159L207 95L203 176L254 140L230 220Z" fill="#80b280"/>',
'leaf':'<path d="M64 195Q45 55 238 40Q257 213 64 195Z" fill="#80b280"/><path fill="none" d="M65 195L222 57M113 145L100 99M151 107L150 68M110 151L170 168M156 110L210 121"/>',
'seed':'<ellipse cx="150" cy="136" rx="57" ry="85" transform="rotate(30 150 136)" fill="#b48b61"/><path d="M127 198Q93 121 177 67" fill="none" stroke="#eac79e" stroke-width="8"/>',
'root':'<path d="M150 45V112M150 110L118 145L94 205M150 112L172 155L221 203M130 133L145 209M174 154L177 218M115 155L63 181" stroke="#aa8058" stroke-width="12"/><path d="M150 72Q100 54 112 31Q147 26 150 72M150 72Q199 52 190 29Q153 23 150 72" fill="#80b280"/>',
'bush':'<path d="M47 203C3 165 33 117 69 116C43 48 131 41 150 80C192 22 256 70 235 116C290 130 280 205 239 206Z" fill="#80b280"/><path d="M53 213H246"/>',
'pine':'<path d="M140 200V225H163V200" fill="#aa8058"/><path d="M150 23L213 103H191L241 165H215L261 211H39L85 165H59L111 103H88Z" fill="#6ba46f"/>'}
for id,paths in art.items():(out/f'{id}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 250"><g stroke="#496557" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">{paths}</g></svg>',encoding='utf-8')
(out/'body.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1280" viewBox="0 0 600 640"><g stroke="#496557" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"><path d="M249 258L168 340M351 258L432 340" stroke="#ecc7a5" stroke-width="54"/><ellipse cx="150" cy="356" rx="34" ry="30" fill="#ecc7a5"/><ellipse cx="450" cy="356" rx="34" ry="30" fill="#ecc7a5"/><path d="M246 398L248 561H281L298 444L317 561H351L354 398Z" fill="#719dcb"/><ellipse cx="249" cy="586" rx="43" ry="25" fill="#ec984b"/><ellipse cx="350" cy="586" rx="43" ry="25" fill="#ec984b"/><path d="M247 238Q300 213 353 238L375 408Q300 433 225 408Z" fill="#80b280"/><path d="M278 211V242Q300 259 322 242V211" fill="#ecc7a5"/><ellipse cx="201" cy="143" rx="24" ry="38" fill="#ecc7a5"/><ellipse cx="399" cy="143" rx="24" ry="38" fill="#ecc7a5"/><ellipse cx="300" cy="135" rx="96" ry="103" fill="#ecc7a5"/><path d="M204 102Q189 24 275 30Q366 8 396 101Q346 99 323 66Q281 106 204 102" fill="#986b49"/><circle cx="258" cy="120" r="10" fill="#354940"/><circle cx="342" cy="120" r="10" fill="#354940"/><path d="M299 144L289 166L307 168" fill="none"/><path d="M270 193Q300 217 330 193" fill="none"/><circle cx="246" cy="173" r="14" fill="#e9a6a4" stroke="none"/><circle cx="353" cy="173" r="14" fill="#e9a6a4" stroke="none"/></g></svg>''',encoding='utf-8')
write('data/localization/en.json',en);write('data/localization/uk.json',uk);write('data/game_content/foundation.json',manifest);write('data/game_content/voice_jobs.json',jobs)
runpy.run_path(str(ROOT/'tools/prepare_full_ukrainian.py'),run_name='__main__')
print('World: existing12 animals,9 body parts,8 plants; fixed comparable five-item checks.')

runpy.run_path(str(ROOT/"tools/prepare_body_details.py"),run_name="__main__")
