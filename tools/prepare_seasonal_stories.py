from pathlib import Path
import json,math
from trace_silhouettes import gesture
R=Path('.')
def read(p):return json.loads((R/p).read_text(encoding='utf-8'))
def write(p,d):(R/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def rect(x,y,w,h):return [[x,y],[x+w,y],[x+w,y+h],[x,y+h],[x,y]]
words={'tree':('tree','дерево'),'sun':('sun','сонечко'),'cloud':('cloud','хмаринку'),'nest':('nest','гніздечко'),'bird':('bird','пташку'),'flowers':('flowers','квіти'),'butterfly':('butterfly','метелика'),'bee':('bee','бджілку'),'frog':('frog','жабку'),'pond':('pond','ставочок'),'rainbow':('rainbow','веселку'),'bunny':('bunny','зайчика'),'leaves':('leaves','листочки'),'hedgehog':('hedgehog','їжачка'),'mushrooms':('mushrooms','грибочки'),'pumpkin':('pumpkin','гарбуз'),'basket':('basket of apples','кошик яблук'),'kite':('kite','повітряного змія'),'boots':('boots','чобітки'),'puddle':('puddle','калюжку'),'squirrel':('squirrel','білочку'),'cottage':('cottage','хатинку'),'moon':('moon','місяць'),'snowman':('snowman','сніговика'),'pine':('fir tree','ялинку'),'penguin':('penguin','пінгвіна'),'sled':('sled','санчата'),'gift':('gift','подарунок'),'lantern':('lantern','ліхтарик'),'star':('star','зірочку'),'snowflake':('snowflake','сніжинку')}
stories={
'spring':['tree','sun','cloud','nest','bird','flowers','butterfly','bee','frog','pond','rainbow','bunny'],
'autumn':['tree','sun','cloud','leaves','hedgehog','mushrooms','pumpkin','basket','kite','boots','puddle','squirrel'],
'winter':['cottage','moon','cloud','snowman','pine','penguin','sled','gift','lantern','star','snowflake','bird']}
positions=[(470,340,180,300),(120,30,120,120),(830,40,170,110),(270,260,120,120),(700,240,120,120),(120,440,140,120),(850,400,140,140),(650,490,140,140),(320,580,140,140),(500,650,190,95),(800,610,170,140),(150,650,130,130)]
layouts={
 'spring':{3:(470,270,100,90),4:(700,210,120,120),5:(170,540,140,120),6:(820,370,140,140),7:(650,470,140,140),10:(600,90,300,150)},
 'autumn':{3:(680,330,140,140),4:(180,620,140,140),5:(330,650,140,120),6:(750,620,140,140),7:(550,650,150,140),8:(230,240,150,170),9:(860,510,140,140),10:(850,675,170,95),11:(450,550,130,130)},
 'winter':{0:(500,350,240,300),3:(750,520,160,180),4:(250,390,160,260),5:(200,650,140,150),6:(470,650,170,120),7:(650,650,130,130),8:(420,410,100,130),9:(480,50,120,120),10:(840,240,140,140),11:(110,420,120,120)}}
colors=['a1c88b','f3ce62','ecf3f9','d8a175','e7b46e','ed9caf','bd9dd2','efc956','8cbf92','89c9d8','e7a3b9','dbb58d']
for story,kinds in stories.items():
 parts=[]
 for i,kind in enumerate(kinds):
  x,y,w,h=layouts[story].get(i,positions[i]);left=x-w/2;top=y-h/2
  if kind in ['sun','moon','pond','puddle','pumpkin','snowman','frog','bee','bunny','hedgehog','bird','squirrel']:
   path=[[round(x+w*.46*math.cos(n*math.tau/20),2),round(y+h*.46*math.sin(n*math.tau/20),2)] for n in range(21)]
  elif kind in ['tree','pine','cottage','kite']:
   path=[[left,y+h/2],[x,top],[x+w/2,y+h/2],[left,y+h/2]]
  else:path=rect(left,top,w,h)
  # Guides follow each object's recognizable outer gesture rather than a generic box.
  shapes={
   'tree':[[-.06,.5],[-.06,.12],[-.4,.08],[-.5,-.16],[-.34,-.35],[-.12,-.35],[0,-.5],[.24,-.42],[.27,-.25],[.46,-.2],[.47,.02],[.12,.12],[.12,.5],[-.06,.5]],
   'cottage':[[-.45,.48],[-.45,-.12],[-.55,-.12],[0,-.5],[.55,-.12],[.45,-.12],[.45,.48],[-.45,.48]],
   'kite':[[0,-.5],[.4,0],[0,.4],[-.4,0],[0,-.5]],
   'pine':[[0,-.5],[.45,.35],[.08,.35],[.08,.5],[-.08,.5],[-.08,.35],[-.45,.35],[0,-.5]],
   'cloud':[[-.48,.2],[-.48,0],[-.3,-.18],[-.15,-.12],[-.1,-.38],[.15,-.45],[.32,-.18],[.45,-.05],[.48,.2],[-.48,.2]],
   'butterfly':[[0,-.1],[-.38,-.43],[-.48,-.1],[-.3,.1],[-.4,.35],[-.12,.42],[0,.1],[.12,.42],[.4,.35],[.3,.1],[.48,-.1],[.38,-.43],[0,-.1]],
   'boots':[[-.3,-.5],[.12,-.5],[.12,.13],[.45,.23],[.45,.46],[-.3,.46],[-.3,-.5]],
   'basket':[[-.45,-.1],[-.32,.42],[.32,.42],[.45,-.1],[-.45,-.1]],
   'mushrooms':[[-.45,0],[-.36,-.25],[0,-.45],[.36,-.25],[.45,0],[.12,0],[.12,.45],[-.12,.45],[-.12,0],[-.45,0]],
   'leaves':[[0,-.48],[.35,-.1],[.18,.25],[0,.45],[-.3,.12],[-.35,-.1],[0,-.48]],
   'sled':[[-.45,-.15],[.4,-.15],[.4,.08],[-.45,.08],[-.45,-.15]],
   'star':[[math.cos(-math.pi/2+n*math.tau/10)*(.48 if n%2==0 else .22),math.sin(-math.pi/2+n*math.tau/10)*(.48 if n%2==0 else .22)] for n in range(11)],
   'snowflake':[[math.cos(n*math.tau/12)*(.48 if n%2==0 else .06),math.sin(n*math.tau/12)*(.48 if n%2==0 else .06)] for n in range(13)],
   'rainbow':[[math.cos(math.pi+n*math.pi/12)*.48,.3+math.sin(math.pi+n*math.pi/12)*.7] for n in range(13)]}
  if kind in shapes:path=[[round(x+a*w,2),round(y+b*h,2)] for a,b in shapes[kind]]
  parts.append(dict(id=kind,prompt='SEASON_'+kind.upper(),color=colors[i],marker=[x,y],zoom=[left-45,top-45,w+90,h+90],box=[left,top,w,h],strokes=[path]))
 for part in parts:
  silhouette=gesture(part)
  if silhouette:part['strokes']=[silhouette]
 write('data/game_content/living_'+story+'.json',dict(version=1,id=story,base_parts=1,bounds=[0,-100,1000,850],parts=parts))
en=read('data/localization/en.json');uk=read('data/localization/uk.json');manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
texts={'SEASON_SPRING':('Spring garden','Весняний сад'),'SEASON_AUTUMN':('Autumn adventure','Осіння пригода'),'SEASON_WINTER':('Winter wonderland','Зимова казка'),'SEASON_PLAY':('Your world is alive. Tap the pictures and explore!','Твій світ ожив. Натискай на малюнки та досліджуй!')}
for key,(a,b) in words.items():texts['SEASON_'+key.upper()]=('Draw the '+a+'.','Намалюй '+b+'.')
for key,(a,b) in texts.items():
 en[key]=a;uk[key]=b
 if key in ['SEASON_SPRING','SEASON_AUTUMN','SEASON_WINTER']:continue
 manifest['voice'][key]={}
 for loc,t in [('en',a),('uk',b)]:
  file=f'assets/audio/voice/{loc}/{key.lower()}.wav';manifest['voice'][key][loc]='res://'+file
  jobs[loc]=[j for j in jobs[loc] if j['key']!=key];jobs[loc].append(dict(key=key,text=t,file=file))
for p,d in [('data/localization/en.json',en),('data/localization/uk.json',uk),('data/game_content/foundation.json',manifest),('data/game_content/voice_jobs.json',jobs)]:write(p,d)
for story,color,shape in [('spring','#a1c88b','<circle cx="80" cy="65" r="45"/>'),('autumn','#df995d','<path d="M80 15L130 85L80 125L30 85Z"/>'),('winter','#b2d8e8','<path d="M80 15L125 115H35Z"/>')]:
 (R/f'assets/ui/living_{story}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160"><path d="M80 65V145" stroke="#7d6652" stroke-width="14"/><g fill="{color}" stroke="#496557" stroke-width="4">{shape}</g><circle cx="130" cy="25" r="15" fill="#f5d475"/></svg>',encoding='utf-8')
print('Three seasonal stories, 36 actors, bilingual local instructions.')

# Apply the current companion-style art/gesture definitions after base content.
import prepare_story_illustrations
