"""Detailed original vector child and matching bilingual touch regions."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8"))
def write(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
data=read('data/game_content/world_body.json');en=read('data/localization/en.json');uk=read('data/localization/uk.json');manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
# Smaller regions precede broad containing regions in hit-testing.
rows=[
('eyebrow','Eyebrow','Брова','брову','face',[[233,94,52,16],[315,94,52,16]]),
('eye','Eye','Око','око','face',[[233,105,51,35],[316,105,51,35]]),
('nose','Nose','Ніс','ніс','face',[[277,142,46,38]]),
('mouth','Mouth','Рот','рот','face',[[262,184,76,28]]),
('ear','Ear','Вухо','вухо','face',[[177,110,39,73],[384,110,39,73]]),
('cheek','Cheek','Щока','щоку','face',[[228,151,43,35],[330,151,43,35]]),
('chin','Chin','Підборіддя','підборіддя','face',[[279,215,42,21]]),
('hair','Hair','Волосся','волосся','face',[[236,40,65,36]]),
('head','Head','Голова','голову','face',[[300,40,60,36],[216,48,168,182]]),
('finger','Finger','Палець','палець','body',[[108,381,58,33],[434,381,58,33],[166,330,16,30],[418,330,16,30]]),
('hand','Hand','Долоня','долоню','body',[[120,342,49,35],[431,342,49,35]]),
('elbow','Elbow','Лікоть','лікоть','body',[[181,300,35,35],[384,300,35,35]]),
('arm','Arm','Рука','руку','body',[[213,275,28,27],[359,275,28,27],[159,318,44,34],[397,318,44,34]]),
('shoulder','Shoulder','Плече','плече','body',[[238,244,30,31],[332,244,30,31]]),
('neck','Neck','Шия','шию','body',[[280,235,40,23]]),
('belly','Belly','Живіт','живіт','body',[[270,345,60,45]]),
('torso','Torso','Тулуб','тулуб','body',[[267,282,66,53],[237,269,126,143]]),
('knee','Knee','Коліно','коліно','body',[[247,491,38,32],[315,491,38,32]]),
('leg','Leg','Нога','ногу','body',[[247,454,38,32],[315,454,38,32],[247,525,36,32],[317,525,36,32]]),
('foot','Foot','Ступня','ступню','body',[[209,560,83,55],[308,560,83,55]])]
items=[]
for id,a,b,acc,view,areas in rows:
 prefix='WORLD_BODY_'+id.upper()
 for suffix,english,ukrainian in [('WORD',a+'.',b+'.'),('FIND','Show me the '+a.lower()+'.','Покажи '+acc+'.')]:
  key=prefix+'_'+suffix;en[key]=english;uk[key]=ukrainian;manifest['voice'][key]={}
  for loc,text in [('en',english),('uk',ukrainian)]:
   file=f'assets/audio/voice/{loc}/{key.lower()}.wav';manifest['voice'][key][loc]='res://'+file
   jobs[loc]=[j for j in jobs[loc] if j['key']!=key];jobs[loc].append({'key':key,'text':text,'file':file})
 items.append(dict(id=id,english=a,ukrainian=b,word_key=prefix+'_WORD',prompt_key=prefix+'_FIND',view=view,areas=areas))
data['items']=items
write('data/game_content/world_body.json',data)
# Changed regions and distractor vocabulary are a different comparison revision.
topics=read('data/game_content/world_topics.json')
for t in topics['topics']:
 if t['id']=='body':t['revision']=2
en['WORLD_HAND_ZOOM']='Hands / whole body';uk['WORLD_HAND_ZOOM']='Долоні / усе тіло'
en['WORLD_BODY_TAP']='Tap a body part. Tap the head or hand to look closer.';uk['WORLD_BODY_TAP']='Натисни на частину тіла. Натисни на голову чи долоню, щоб роздивитися ближче.'
write('data/game_content/world_topics.json',topics)
for p,d in [('data/localization/en.json',en),('data/localization/uk.json',uk),('data/game_content/foundation.json',manifest),('data/game_content/voice_jobs.json',jobs)]:write(p,d)
skin='#edc9a7';ink='#496557'
parts=['<ellipse cx="300" cy="620" rx="118" ry="9" fill="#496557" opacity=".10" stroke="none"/>',
'<path d="M249 261L202 313L159 350M351 261L398 313L441 350" fill="none" stroke="#496557" stroke-width="47"/>',
'<path d="M249 261L202 313L159 350M351 261L398 313L441 350" fill="none" stroke="'+skin+'" stroke-width="39"/>',
'<path d="M190 309Q198 317 207 316M393 316Q402 317 410 309" fill="none" stroke="#d8a888" stroke-width="3"/>',
'<path d="M244 399L249 560H282L298 451L318 560H352L355 399Z" fill="#729ec1"/>',
'<path d="M250 421Q297 440 350 421M298 430V451" fill="none" stroke="#527f9f" stroke-width="3"/>',
'<path d="M243 241Q300 220 357 241L372 410Q300 430 228 410Z" fill="#8cbb96"/>',
'<path d="M245 247L234 286M355 247L366 286M237 398Q300 415 363 398" fill="none" stroke="#6e9b79" stroke-width="3"/>',
'<path d="M278 212V248Q300 267 322 248V212" fill="'+skin+'"/>',
'<path d="M276 249Q300 270 324 249" fill="none" stroke="#6e9b79" stroke-width="6"/>',
'<path d="M288 300L300 277L312 300L335 305L318 322L320 345L300 335L280 345L282 322L265 305Z" fill="#f5d983" stroke="#7ca784" stroke-width="3"/>',
'<path d="M250 502Q265 512 280 502M319 502Q334 512 350 502" fill="none" stroke="#527f9f" stroke-width="3"/>']
# Five distinct digits, visible nails and palm creases; mirrored right hand.
hand=[]
for x,y,h in [(109,356,39),(122,361,47),(135,364,47),(148,362,39)]:
 hand.append(f'<rect x="{x}" y="{y}" width="13" height="{h}" rx="6.5" fill="{skin}" stroke-width="3"/>')
hand+=['<path d="M157 347Q166 325 175 333Q181 339 172 355L164 377L119 379Q111 361 120 348Q135 333 157 347Z" fill="'+skin+'" stroke-width="3"/>','<path d="M130 357Q144 351 155 360M133 365Q144 363 151 368" fill="none" stroke="#d8a888" stroke-width="2"/>']
for x,y in [(111,384),(124,396),(137,399),(150,389)]:hand.append(f'<rect x="{x}" y="{y}" width="8" height="6" rx="3" fill="#f6ddc5" stroke="none"/>')
parts+=['<g>'+''.join(hand)+'</g>','<g transform="translate(600 0) scale(-1 1)">'+''.join(hand)+'</g>']
for x in [251,349]:
 parts.append(f'<ellipse cx="{x}" cy="588" rx="41" ry="24" fill="{skin}"/>')
 for dx,r in [(-26,10),(-9,9),(7,8),(21,7),(33,6)]:parts.append(f'<ellipse cx="{x+dx}" cy="569" rx="{r}" ry="11" fill="{skin}" stroke-width="2.5"/>')
parts+=['<ellipse cx="201" cy="145" rx="24" ry="38" fill="'+skin+'"/>','<ellipse cx="399" cy="145" rx="24" ry="38" fill="'+skin+'"/>','<path d="M200 128Q184 145 204 161M400 128Q416 145 396 161" fill="none" stroke="#d8a888" stroke-width="3"/>','<ellipse cx="300" cy="135" rx="96" ry="103" fill="'+skin+'"/>','<path d="M204 94Q188 13 260 18Q301 2 328 20Q379 15 398 91Q349 96 321 57Q278 100 204 94Z" fill="#926847"/>','<path d="M221 74Q249 43 279 47M290 46Q314 36 331 49M339 52Q363 61 373 82" fill="none" stroke="#b88b63" stroke-width="4"/>','<path d="M238 103Q258 92 277 102M323 102Q343 92 362 104" fill="none" stroke="#926847" stroke-width="6"/>']
for x in [258,342]:parts +=[f'<ellipse cx="{x}" cy="120" rx="14" ry="16" fill="#fff8ec" stroke-width="2"/>',f'<ellipse cx="{x}" cy="121" rx="9" ry="12" fill="#638f7f" stroke="none"/>',f'<ellipse cx="{x}" cy="122" rx="5" ry="8" fill="#354940" stroke="none"/>',f'<circle cx="{x-3}" cy="116" r="3" fill="white" stroke="none"/>']
parts+=['<path d="M299 144Q285 164 294 170Q301 175 309 168" fill="none" stroke-width="3.5"/>','<ellipse cx="246" cy="171" rx="16" ry="12" fill="#e6a8a0" stroke="none" opacity=".7"/>','<ellipse cx="354" cy="171" rx="16" ry="12" fill="#e6a8a0" stroke="none" opacity=".7"/>','<path d="M270 192Q300 218 330 192Q302 235 270 192Z" fill="#fff8ec" stroke-width="3"/>']
(ROOT/'assets/objects/world/body.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1800" height="1920" viewBox="0 0 600 640"><g stroke="'+ink+'" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">'+''.join(parts)+'</g></svg>',encoding='utf-8')
print('Detailed body:20 labeled interactive parts, mirrored five-digit hands, face and hand zoom art.')

# Semantic crops reuse the same character art for the picture-word builder.
boxes={"head":[165,8,270,240],"eyebrow":[225,80,65,38],"eye":[218,88,78,68],"nose":[265,129,70,60],"mouth":[251,177,98,55],"ear":[164,100,64,92],"cheek":[220,145,60,52],"chin":[266,205,68,37],"hair":[190,5,215,105],"finger":[100,371,77,47],"hand":[95,320,95,102],"elbow":[170,288,68,65],"arm":[150,243,115,117],"shoulder":[229,230,50,60],"neck":[267,216,66,52],"belly":[249,334,102,68],"torso":[218,232,164,195],"knee":[237,479,58,54],"leg":[231,430,72,134],"foot":[195,548,108,77]}
import re
folder=ROOT/'assets/objects/body_parts';folder.mkdir(parents=True,exist_ok=True)
svg=(ROOT/'assets/objects/world/body.svg').read_text(encoding='utf-8')
for item in data['items']:
 x,y,w,h=boxes[item['id']]
 crop=re.sub(r'width="1800" height="1920" viewBox="0 0 600 640"',f'width="600" height="500" viewBox="{x} {y} {w} {h}"',svg, count=1)
 # Explicit clipping prevents outer SVG aspect-fit margins from exposing other parts.
 crop=crop.replace('><g stroke=',f'><defs><clipPath id="partCrop"><rect x="{x}" y="{y}" width="{w}" height="{h}"/></clipPath></defs><g clip-path="url(#partCrop)"><g stroke=',1).replace('</g></svg>','</g></g></svg>')
 (folder/(item['id']+'.svg')).write_text(crop,encoding='utf-8')
 item['illustration']='res://assets/objects/body_parts/'+item['id']+'.svg'
write('data/game_content/world_body.json',data)

import runpy
runpy.run_path(str(ROOT/"tools/prepare_people_layout.py"),run_name="__main__")
