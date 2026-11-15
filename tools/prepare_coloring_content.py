"""Author original closed-region line art and finite offline coloring content."""
from pathlib import Path
import math
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/objects/coloring"
OUT.mkdir(parents=True, exist_ok=True)
pages = []
regions = []
decor = []
locks = []

def polygon(id, points, tap=None):
    points = [[round(x, 2), round(y, 2)] for x, y in points]
    if tap is None:
        tap = [sum(p[0] for p in points)/len(points), sum(p[1] for p in points)/len(points)]
    regions.append(dict(id=id, polygon=points, tap=[round(v,2) for v in tap]))

def ellipse(id, x, y, rx, ry=None, angle=0):
    ry = rx if ry is None else ry
    a = math.radians(angle)
    points=[]
    for i in range(64):
        t=2*math.pi*i/64
        dx,dy=rx*math.cos(t),ry*math.sin(t)
        points.append((x+dx*math.cos(a)-dy*math.sin(a),y+dx*math.sin(a)+dy*math.cos(a)))
    polygon(id,points,(x,y))

def rect(id,x,y,w,h):
    polygon(id,[(x,y),(x+w,y),(x+w,y+h),(x,y+h)])

def eye(x,y,r=10):
    decor.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#354940"/>')
    locks.append([[x+r*math.cos(i*math.pi/12),y+r*math.sin(i*math.pi/12)] for i in range(24)])

def line(path):
    decor.append(f'<path d="{path}" fill="none" stroke="#354940" stroke-width="6" stroke-linecap="round"/>')

def finish(id,english,ukrainian):
    shapes=[]
    for region in regions:
        points=" ".join(f"{x},{y}" for x,y in region["polygon"])
        shapes.append(f'<polygon points="{points}" fill="{{{{{region["id"]}}}}}" stroke="#354940" stroke-width="6" stroke-linejoin="round"/>')
    template='<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="640" viewBox="0 0 1024 640"><rect width="1024" height="640" fill="white"/>'+''.join(shapes+decor)+'</svg>'
    preview=template
    for region in regions: preview=preview.replace('{{'+region['id']+'}}','#ffffff')
    (OUT/f'{id}.svg').write_text(preview+'\n',encoding='utf-8')
    pages.append(dict(id=id,english=english,ukrainian=ukrainian,word_key='BOOK_WORD_'+id.upper(),
        preview=f'res://assets/objects/coloring/{id}.svg',template=template,
        regions=[dict(region) for region in regions],locks=list(locks)))
    regions.clear();decor.clear();locks.clear()

# Friendly animals: large independent ears, body, belly and paws.
ellipse('tail',700,420,65,145,angle=-25)
polygon('left_ear',[(355,200),(355,65),(470,155)],(385,115))
polygon('right_ear',[(555,155),(670,65),(670,200)],(640,115))
ellipse('body',512,420,155,160)
ellipse('head',512,235,158,120)
ellipse('belly',512,438,85,105)
ellipse('left_paw',425,565,65,30)
ellipse('right_paw',599,565,65,30)
eye(458,225);eye(566,225)
line('M497 260L512 272L527 260M512 272V291M476 288Q512 320 548 288')
finish('cat','Cat','Кіт')

ellipse('tail',715,414,45,110,angle=30)
ellipse('body',512,435,158,145)
ellipse('left_ear',350,240,54,123,angle=12)
ellipse('right_ear',674,240,54,123,angle=-12)
ellipse('head',512,235,142,115)
ellipse('muzzle',512,285,78,52)
ellipse('belly',512,438,85,100)
ellipse('left_paw',420,566,65,29);ellipse('right_paw',604,566,65,29)
eye(460,220);eye(564,220)
line('M496 268Q512 255 528 268L512 282ZM512 282V298')
finish('dog','Dog','Собака')

ellipse('tail',730,420,86,151,angle=-32)
polygon('tail_tip',[(746,276),(830,324),(822,414),(773,376)],(804,344))
ellipse('body',494,440,120,146)
polygon('left_ear',[(340,205),(351,62),(462,158)],(376,122))
polygon('right_ear',[(537,158),(650,62),(662,205)],(621,122))
ellipse('head',500,242,153,111)
polygon('left_cheek',[(350,235),(498,304),(410,330)],(417,287))
polygon('right_cheek',[(650,235),(502,304),(590,330)],(583,287))
ellipse('belly',494,440,65,102)
ellipse('left_paw',422,570,51,25);ellipse('right_paw',568,570,51,25)
eye(449,218);eye(551,218)
line('M486 274L500 285L514 274M500 285V304')
finish('fox','Fox','Лисиця')

ellipse('upper_left',354,216,142,153,angle=-25)
ellipse('upper_right',670,216,142,153,angle=25)
ellipse('lower_left',369,440,132,114,angle=18)
ellipse('lower_right',655,440,132,114,angle=-18)
ellipse('left_spot',326,204,61,73);ellipse('right_spot',698,204,61,73)
ellipse('lower_left_spot',356,447,49,44);ellipse('lower_right_spot',668,447,49,44)
ellipse('body',512,353,37,190)
ellipse('head',512,119,58,52)
eye(492,113,8);eye(532,113,8)
line('M490 145Q512 160 534 145M482 80Q451 32 432 42M542 80Q573 32 592 42')
finish('butterfly','Butterfly','Метелик')

polygon('tail',[(687,320),(904,202),(904,438)],(843,320))
polygon('top_fin',[(442,205),(505,87),(652,221)],(528,172))
ellipse('body',494,327,226,149)
ellipse('head',349,327,84,138)
polygon('fin',[(483,351),(641,415),(546,512)],(550,426))
ellipse('bubble_big',130,156,39);ellipse('bubble_small',206,86,25)
eye(331,290,15);line('M277 346Q298 364 315 348')
finish('fish','Fish','Рибка')

rect('chimney',650,106,55,151)
rect('wall',289,269,442,310)
polygon('roof',[(235,273),(512,64),(789,273)],(512,155))
rect('door',452,409,120,170)
rect('left_window',330,332,82,85);rect('right_window',611,332,82,85)
ellipse('attic',512,204,38)
eye(545,490,6)
line('M371 332V417M330 374H412M652 332V417M611 374H693')
finish('house','House','Будинок')

rect('stem',494,310,36,287)
ellipse('left_leaf',399,452,102,43,angle=22)
ellipse('right_leaf',625,510,102,43,angle=-22)
for i in range(8):
    a=i*math.pi/4
    ellipse('petal_'+str(i),512+120*math.cos(a),257+120*math.sin(a),72)
ellipse('center',512,257,72)
eye(489,248,8);eye(535,248,8);line('M486 278Q512 295 538 278')
finish('flower','Flower','Квітка')

polygon('body',[(165,340),(249,306),(320,187),(652,187),(774,306),(855,340),(855,474),(165,474)],(512,380))
polygon('left_window',[(337,228),(482,228),(482,319),(280,319)],(392,274))
polygon('right_window',[(523,228),(632,228),(725,319),(523,319)],(600,274))
rect('left_light',171,358,65,51);rect('right_light',787,358,62,51)
ellipse('left_wheel',337,479,78);ellipse('right_wheel',686,479,78)
ellipse('left_hub',337,479,33);ellipse('right_hub',686,479,33)
line('M511 344V438M557 356H595')
finish('car','Car','Машина')

polygon('tail',[(650,342),(932,311),(769,482),(650,492)],(821,375))
rect('back_leg',579,447,82,176);rect('front_leg',354,447,82,176)
polygon('spine_a',[(438,267),(466,180),(526,259)],(475,233))
polygon('spine_b',[(538,261),(584,183),(625,282)],(580,246))
polygon('spine_c',[(634,296),(697,235),(720,340)],(684,297))
ellipse('body',513,410,202,145)
polygon('neck',[(312,412),(269,186),(383,163),(461,385)],(346,278))
ellipse('head',303,153,117,79)
ellipse('belly',525,435,102,78)
ellipse('spot_a',453,337,30);ellipse('spot_b',551,318,26);ellipse('spot_c',643,374,28)
eye(268,139,12);line('M197 170Q223 191 251 176')
finish('dinosaur','Dinosaur','Динозавр')

for i in range(7):
    outer,inner=400-i*43,400-(i+1)*43
    points=[]
    for step in range(65):
        t=math.pi*(1-step/64);points.append((512+outer*math.cos(t),496-outer*math.sin(t)))
    for step in range(65):
        t=math.pi*step/64;points.append((512+inner*math.cos(t),496-inner*math.sin(t)))
    polygon('band_'+str(i),points,(512,496-(outer+inner)/2))
ellipse('left_cloud',181,513,128,61);ellipse('right_cloud',843,513,128,61)
finish('rainbow','Rainbow','Веселка')

# Explicit taps must point into visible paintable portions, not overlapped centers.
overrides={'cat':{'body':[630,430],'head':[512,170],'tail':[726,460]},
 'dog':{'body':[635,435],'head':[512,167],'muzzle':[548,298]},
 'fox':{'body':[595,435],'head':[500,167],'tail':[724,474]},
 'fish':{'body':[660,315],'head':[354,375]},
 'butterfly':{'upper_left':[270,150],'upper_right':[754,150],'lower_left':[290,490],'lower_right':[734,490]},
 'house':{'wall':[680,490],'left_window':[355,354],'right_window':[635,354]},
 'flower':{'stem':[512,565]},
 'car':{'body':[760,420],'left_wheel':[286,492],'right_wheel':[737,492]},
 'dinosaur':{'body':[668,435],'neck':[365,292],'back_leg':[620,590],'front_leg':[395,590]}}
for page in pages:
    for region in page['regions']:
        if region['id'] in overrides.get(page['id'],{}): region['tap']=overrides[page['id']][region['id']]
path=ROOT/'data/game_content/coloring.json'
path.write_text(json.dumps({'version':1,'pages':pages},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
icon=next(page['template'] for page in pages if page['id']=='butterfly')
icon=icon.replace('width="1024" height="640" viewBox="0 0 1024 640"','width="220" height="180" viewBox="190 20 650 560"')
icon_colors=['#75A477','#6598C1','#A38ABD','#DF93AD','#E8C465','#E8C465','#EDAA68','#EDAA68','#E8C465','#75A477']
for i,region in enumerate(next(page['regions'] for page in pages if page['id']=='butterfly')):
    icon=icon.replace('{{'+region['id']+'}}',icon_colors[i % len(icon_colors)])
(ROOT/'assets/ui/coloring.svg').write_text(icon+'\n',encoding='utf-8')
extra={
 'BOOK_TITLE':('Coloring book','Розмальовки'),'BOOK_INTRO':('Choose a color and tap a shape.','Обери колір і торкнись області.'),
 'BOOK_SAVED':('Your coloring is saved!','Твою розмальовку збережено!'),'BOOK_RESET':('Start again','Спочатку'),
 'BOOK_RESET_TITLE':('Start this picture again?','Почати цю картинку спочатку?'),
 'BOOK_RESET_HINT':('You can restore the colors with Undo.','Кольори можна повернути кнопкою «Назад».'),
 'BOOK_RESET_CONFIRM':('Reset colors','Прибрати кольори'),'BOOK_READY':('Tap inside an outline','Торкнись усередині контуру'),
 'BOOK_WHITE':('White','Білий'),'BOOK_PAGE':('Picture {current} of {total}','Картинка {current} із {total}'),
}
catalogs={}
for i,locale in enumerate(['en','uk']):
    p=ROOT/f'data/localization/{locale}.json'; text=json.loads(p.read_text(encoding='utf-8'))
    text.update({k:v[i] for k,v in extra.items()})
    for page in pages: text[page['word_key']]=page['english']
    p.write_text(json.dumps(text,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');catalogs[locale]=text
jobs_path=ROOT/'data/game_content/voice_jobs.json';jobs=json.loads(jobs_path.read_text(encoding='utf-8'))
manifest_path=ROOT/'data/game_content/foundation.json';manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
for locale in jobs: jobs[locale]=[j for j in jobs[locale] if not j['key'].startswith('BOOK_')]
for key in ['BOOK_INTRO','BOOK_SAVED']:
    manifest['voice'][key]={}
    for locale in jobs:
        file=f'assets/audio/voice/{locale}/{key.lower()}.wav';jobs[locale].append(dict(key=key,text=catalogs[locale][key],file=file));manifest['voice'][key][locale]='res://'+file
for page in pages:
    key=page['word_key'];file=f'assets/audio/voice/en/{key.lower()}.wav'
    jobs['en'].append(dict(key=key,text=page['english']+'.',file=file));manifest['voice'][key]={'en':'res://'+file,'uk':'res://'+file}
jobs_path.write_text(json.dumps(jobs,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Authored ten closed-region pages and fourteen offline helper/word clips.')

# Preserve the full-locale policy after rebuilding activity data.
import runpy
runpy.run_path(str(ROOT / "tools/prepare_full_ukrainian.py"), run_name="__main__")
