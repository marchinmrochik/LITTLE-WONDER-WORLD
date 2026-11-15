"""Original one-picture tracing prototype with finite bilingual speech."""
from pathlib import Path
import json, math, wave, struct, random
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def write(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def rect(x,y,w,h):return [[x,y],[x+w,y],[x+w,y+h],[x,y+h],[x,y]]
parts=[
 dict(id='walls',color='f4ce93',marker=[500,330],zoom=[235,230,530,410],strokes=[rect(290,270,420,310)]),
 dict(id='roof',color='d98173',marker=[500,175],zoom=[170,45,660,310],strokes=[[[235,285],[500,105],[765,285],[235,285]]]),
 dict(id='door',color='86b5b6',marker=[503,478],zoom=[390,345,225,285],strokes=[rect(460,400,85,180)]),
 dict(id='left_window',color='a9dce0',marker=[375,400],zoom=[270,290,210,225],strokes=[rect(330,350,90,105),[[375,350],[375,455]],[[330,402],[420,402]]]),
 dict(id='right_window',color='a9dce0',marker=[625,400],zoom=[520,290,210,225],strokes=[rect(580,350,90,105),[[625,350],[625,455]],[[580,402],[670,402]]]),
 dict(id='chimney',color='bd8a74',marker=[616,119],zoom=[520,20,190,250],strokes=[rect(585,75,62,138)])]
def oval(x,y,rx,ry):return [[round(x+rx*math.cos(i*math.tau/16),2),round(y+ry*math.sin(i*math.tau/16),2)] for i in range(17)]
parts += [
 dict(id='sun',color='f4cb61',marker=[135,35],zoom=[25,-70,220,220],strokes=[oval(135,35,48,48)]),
 dict(id='cloud',color='edf5f4',marker=[840,50],zoom=[710,-55,260,200],strokes=[[[745,70],[745,45],[770,25],[790,30],[800,0],[830,-8],[860,10],[870,35],[900,25],[930,45],[935,70],[745,70]]]),
 dict(id='dog',color='d7a97c',marker=[145,570],zoom=[35,440,235,235],strokes=[[[75,595],[75,540],[95,505],[125,490],[160,500],[180,530],[195,580],[215,595],[195,620],[90,620],[75,595]]]),
 dict(id='flowers',color='ed9ca3',marker=[845,570],zoom=[735,460,220,230],strokes=[oval(845,545,40,40),[[845,585],[845,635]]])]
write('data/game_content/living_house.json',{'version':2,'id':'little_house','bounds':[0,-100,1000,850],'base_parts':6,'parts':parts})
copy={
'LIVE_TITLE':('Living drawings','Живі малюнки'),'LIVE_TAP':('Tap the glowing dot.','Натисни на сяючу крапку.'),'LIVE_TRACE':('Follow the dots with your finger.','Веди пальчиком уздовж крапочок.'),'LIVE_PLAY':('Play in your yard. Tap the sun, dog, cloud or chimney.','Грайся у дворі. Натискай на сонце, песика, хмаринку чи трубу.'),'LIVE_REPLAY':('Draw again','Намалювати ще раз'),'LIVE_PROGRESS':('Part {current} of {total}','Деталь {current} із {total}'),'LIVE_STROKE':('Line {current} of {total}','Лінія {current} із {total}'),'LIVE_DONE':('Your yard is coming alive. Draw and play!','Твій дворик оживає. Малюй та грайся!'),
'LIVE_WALLS':('Draw the walls.','Намалюй стіни.'),'LIVE_ROOF':('Draw the roof.','Намалюй дах.'),'LIVE_DOOR':('Draw the door.','Намалюй двері.'),'LIVE_LEFT_WINDOW':('Draw this window.','Намалюй це віконце.'),'LIVE_RIGHT_WINDOW':('Draw the other window.','Намалюй друге віконце.'),'LIVE_CHIMNEY':('Draw the chimney.','Намалюй трубу.')}
copy.update({
'LIVE_GALLERY':('Story gallery','Галерея сюжетів'),'LIVE_BACK':('Back to stories','До сюжетів'),'LIVE_HOUSE_STORY':('House and yard','Будиночок і дворик'),
'LIVE_EXPLORE':('Choose a dot to draw. Tap finished pictures to play.','Обери крапку та малюй. Натискай на готові малюнки та грайся.'),
'LIVE_SUN':('Draw the sun. Tap it to change day and night.','Намалюй сонечко. Натискай на нього, щоб змінювати день і ніч.'),
'LIVE_CLOUD':('Draw a cloud. Tap it to make rain.','Намалюй хмаринку. Натисни на неї, щоб пішов дощик.'),
'LIVE_DOG':('Draw a puppy. Tap to hear it bark and watch it run.','Намалюй песика. Натисни на нього: він загавкає та побіжить.'),
'LIVE_FLOWERS':('Draw a flower. Tap it to invite butterflies.','Намалюй квіточку. Натисни на неї, щоб прилетіли метелики.')})
en=read('data/localization/en.json');uk=read('data/localization/uk.json');manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
for key,(a,b) in copy.items():en[key]=a;uk[key]=b
spoken=['LIVE_TAP','LIVE_TRACE','LIVE_DONE','LIVE_EXPLORE']+['LIVE_'+p['id'].upper() for p in parts]
for key in spoken:
 manifest['voice'][key]={}
 for loc,text in [('en',en[key]),('uk',uk[key])]:
  file=f'assets/audio/voice/{loc}/{key.lower()}.wav';manifest['voice'][key][loc]='res://'+file;jobs[loc]=[j for j in jobs[loc] if j['key']!=key];jobs[loc].append(dict(key=key,text=text,file=file))
for p,d in [('data/localization/en.json',en),('data/localization/uk.json',uk),('data/game_content/foundation.json',manifest),('data/game_content/voice_jobs.json',jobs)]:write(p,d)
(ROOT/'assets/ui/living_house.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160"><g stroke="#496557" stroke-width="5" stroke-linejoin="round"><path d="M35 70H125V140H35Z" fill="#f4ce93"/><path d="M20 73L80 25L140 73Z" fill="#d98173"/><path d="M70 103H91V140H70Z" fill="#86b5b6"/><path d="M44 87H62V108H44ZM102 87H120V108H102Z" fill="#a9dce0"/><circle cx="127" cy="33" r="12" fill="#efce55"/></g></svg>',encoding='utf-8')
# Original gentle two-woof effect, deterministic synthesis; no external sample.
rng=random.Random(91);rate=22050;samples=[]
for i in range(int(rate*.62)):
 t=i/rate;v=0.0
 for start in [0.03,.32]:
  u=t-start
  if 0<=u<.2:
   envelope=math.sin(math.pi*u/.2)**1.5
   phase=math.tau*(190*u-95*u*u)
   v+=envelope*(.6*math.sin(phase)+.25*math.sin(phase*2)+.15*rng.uniform(-1,1))*.24
 samples.append(max(-32767,min(32767,round(v*32767))))
with wave.open(str(ROOT/'assets/audio/sfx/yard_bark.wav'),'wb') as f:
 f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
print('Living yard: one open-ended story, ten parts, original local bark.')
