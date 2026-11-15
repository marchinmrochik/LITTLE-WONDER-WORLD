"""Project inventory and reversible edits for the local design catalog. Standard library only."""
from __future__ import annotations
import base64, hashlib, io, json, math, re, threading, uuid, wave, zlib
from collections import defaultdict
from pathlib import Path
from datetime import datetime, timezone
import xml.etree.ElementTree as ET

GAMES={
 'animals':'Животные','colors':'Цвета','feeding':'Покорми животных','shapes':'Фигуры','puzzles':'Пазлы',
 'memory':'Найди пару','counting':'Цифры и счёт','drawing':'Рисовалка','coloring':'Раскраски','xylophone':'Ксилофон',
 'letters':'Алфавит','syllables':'Собери слово','balloons':'Шарики','living_drawing':'Живые рисунки',
 'draw_word':'Нарисуй слово','world':'Познаём мир','shared':'Общие элементы'}
SOURCE_GAMES={'animals':['animals','memory','puzzles','feeding','world','syllables'],'foods':['feeding','counting','syllables'],
 'colors':['colors','drawing','coloring','syllables'],'shapes':['shapes','syllables'],'counting':['counting','syllables'],
 'memory':['memory'],'puzzles':['puzzles'],'coloring':['coloring','syllables'],'world_body':['world','syllables'],
 'world_plants':['world','syllables'],'world_animals':['world'],'world_topics':['world'],'letters':['letters','syllables'],'symbol_tracing':['letters','counting']}
STORY_TITLES={'house':'Домик и дворик','spring':'Весенний сад','autumn':'Осенняя история','winter':'Зимняя сказка'}
NAMES={'tree':'Дерево','sun':'Солнце','cloud':'Облако','nest':'Гнездо','bird':'Птичка','flowers':'Цветы','butterfly':'Бабочка',
 'bee':'Пчёлка','frog':'Лягушка','pond':'Пруд','rainbow':'Радуга','bunny':'Зайчик','leaves':'Листья','hedgehog':'Ёжик',
 'mushrooms':'Грибы','pumpkin':'Тыква','basket':'Корзинка','kite':'Воздушный змей','boots':'Сапожки','puddle':'Лужа',
 'squirrel':'Белка','cottage':'Домик','moon':'Луна','snowman':'Снеговик','pine':'Ёлка','penguin':'Пингвин','sled':'Санки',
 'gift':'Подарок','lantern':'Фонарь','star':'Звезда','snowflake':'Снежинка','walls':'Стены','roof':'Крыша','door':'Дверь',
 'left_window':'Левое окно','right_window':'Правое окно','chimney':'Труба','dog':'Пёсик'}
MEDIA={'.svg':'image','.png':'image','.jpg':'image','.jpeg':'image','.webp':'image','.wav':'audio','.ttf':'font','.otf':'font'}

def digest(data: bytes)->str:return hashlib.sha256(data).hexdigest()
def read_json(path: Path,default=None):return json.loads(path.read_text(encoding='utf-8-sig')) if path.exists() else ({} if default is None else default)
def write_json(path: Path,data):
 path.parent.mkdir(parents=True,exist_ok=True);temp=path.with_name(path.name+'.tmp');temp.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');temp.replace(path)
def safe(root:Path,relative:str)->Path:
 p=(root/relative).resolve()
 if not p.is_relative_to(root.resolve()):raise ValueError('Путь находится вне проекта')
 return p

def indexed_sources(root):
 return [p for folder in ['scripts','scenes','data'] for p in (root/folder).rglob('*') if p.is_file() and p.suffix in ['.gd','.tscn','.json']]

def inventory(root:Path):
 entries=[];assets={};refs=defaultdict(set);contexts=defaultdict(set);all_sources=indexed_sources(root)
 source_text={p.relative_to(root).as_posix():p.read_text(encoding='utf-8-sig') for p in all_sources}
 for name,text in source_text.items():
  for target in re.findall(r'res://([^"\s<>]+)',text):refs[target].add(name)
 def add(entry):
  entry.setdefault('games',[]);entry.setdefault('description','');entry.setdefault('editable',[]);entries.append(entry);return entry
 for p in sorted((root/'assets').rglob('*')):
  if not p.is_file() or p.suffix.lower() not in MEDIA:continue
  name=p.relative_to(root).as_posix();kind=MEDIA[p.suffix.lower()];parts=p.parts;groups=[]
  if '/ui/' in name or '/fonts/' in name or '/backgrounds/' in name:groups=['shared']
  elif '/characters/' in name:groups=['shared','world']
  else:
   for folder,games in [('animals',['animals','memory','puzzles','feeding','world','syllables','shared']),('food',['feeding','syllables','counting']),('colors',['colors','drawing','coloring']),('shapes',['shapes']),('people',['world']),('world',['world','syllables']),('alphabet',['letters','syllables']),('coloring',['coloring']),('counting',['counting']),('puzzles',['puzzles'])]:
    if '/'+folder+'/' in name:groups+=games
  if kind=='image' and '/illustrations/stories/' in name:groups=['living_drawing']
  if kind=='image' and 'syllables' in groups:groups.append('draw_word')
  if kind=='audio':
   if '/instrument/' in name:groups=['xylophone']
   if p.stem=='balloon_pop':groups=['balloons','shared']
   stem=p.stem
   for prefix,game in [('word_','animals'),('find_','animals'),('food_','feeding'),('color_','colors'),('shape','shapes'),('alph_','letters'),('count_','counting'),('world_','world'),('book_','coloring'),('live_','living_drawing'),('season_','living_drawing'),('trace_','letters'),('blend_','syllables'),('memory_','memory'),('puzzles_','puzzles')]:
    if stem.startswith(prefix):groups.append(game)
   if not groups:groups=['shared']
  entry=add({'id':'asset:'+name,'type':kind,'title':p.stem.replace('_',' '),'path':name,'size':p.stat().st_size,'sha256':digest(p.read_bytes()),'games':sorted(set(groups)),
   'extension':p.suffix.lower(),'editable':['file'] if kind=='image' and p.suffix in ['.svg','.png'] else [],'usage':sorted(refs[name])})
  if kind=='audio':
   with wave.open(str(p),'rb') as f:entry.update(seconds=round(f.getnframes()/f.getframerate(),2),sample_rate=f.getframerate())
   entry['locale']='uk' if '/uk/' in name else 'en' if '/en/' in name else ''
  if p.suffix=='.png':
   raw=p.read_bytes();entry['width']=int.from_bytes(raw[16:20],'big');entry['height']=int.from_bytes(raw[20:24],'big')
  assets[name]=entry
 voice=read_json(root/'assets/audio/voice/manifest.json')
 for clip in voice.get('clips',[]):
  asset=assets.get(clip['file'])
  if asset:asset.update(title=clip['text'],key=clip['key'],locale=clip['locale'],description=clip['key'])
 for p in sorted((root/'data/game_content').glob('*.json')):
  if p.stem in ['foundation','voice_jobs','word_translations','design_visual_overrides']:continue
  data=read_json(p);source=p.relative_to(root).as_posix();games=SOURCE_GAMES.get(p.stem,[])
  if p.stem.startswith('living_') or p.stem=='symbol_tracing':continue
  lists=[]
  for field,items in data.items():
   if isinstance(items,list):lists += [(field,i,item) for i,item in enumerate(items) if isinstance(item,dict)]
  if p.stem=='letters':lists=[('alphabets.'+loc,i,item) for loc,items in data.get('alphabets',{}).items() for i,item in enumerate(items)]
  for field,i,item in lists:
   title=item.get('english',item.get('example',item.get('title_key',item.get('id',str(i)))))
   en=read_json(root/'data/localization/en.json');title=en.get(title,title)
   art=item.get('illustration',item.get('preview',''));art=art.removeprefix('res://')
   e=add({'id':f'content:{p.stem}:{field}:{i}','type':'content','title':title,'ukrainian':item.get('ukrainian',item.get('example','')),'path':source,'games':games,
    'media_id':'asset:'+art if art in assets else None,'data':item,'editable':[],'description':p.stem+' / '+str(item.get('id',i))})
   if art in assets:
    assets[art]['games']=sorted(set(assets[art]['games']+games));assets[art]['usage']=sorted(set(assets[art]['usage']+[source]))
 for story,title in STORY_TITLES.items():
  file='data/game_content/living_'+story+'.json';data=read_json(root/file);board='scripts/components/'+('living_house_board.gd' if story=='house' else 'seasonal_drawing_board.gd')
  for i,part in enumerate(data['parts']):
   key='story/'+story+'/'+part['id'];entry=add({'id':'procedural:'+key,'type':'procedural','title':NAMES.get(part['id'],part['id']),'games':['living_drawing'],'story':story,'story_title':title,
    'path':file,'source_code':board,'part_id':part['id'],'part_index':i,'data':part,'strokes':part['strokes'],'view_box':part['zoom'],'bounds':part.get('box'),
    'preview':f'{story}_{part["id"]}_idle.png','frames':[f'{story}_{part["id"]}_{s}.png' for s in ['idle','react','react2']],
    'editable':['art','trace'],'override_key':key,'description':'Рисуется Godot · '+title,'usage':[file,board]})
  add({'id':'story:'+story,'type':'scene','title':title,'games':['living_drawing'],'story':story,'path':file,'preview':'screen_story_'+story+'.png','editable':[],'description':str(len(data['parts']))+' элементов · интерактивный сюжет'})
 symbols=read_json(root/'data/game_content/symbol_tracing.json')
 for kind,loc,items in [('letters',loc,items) for loc,items in symbols['letters'].items()]+[('digits','',symbols['digits'])]:
  for i,item in enumerate(items):add({'id':f'symbol:{kind}:{loc}:{i}','type':'trace','title':('Буква ' if kind=='letters' else 'Цифра ')+item['glyph'],'games':['letters' if kind=='letters' else 'counting'],
   'locale':loc,'path':'data/game_content/symbol_tracing.json','symbol_kind':kind,'symbol_index':i,'glyph':item['glyph'],'strokes':item['strokes'],'view_box':[-100,-120,600,660],
   'editable':['trace'],'description':str(len(item['strokes']))+' штрихов · '+(loc.upper() if loc else '0–9')})
 kit=source_text.get('scripts/components/ui_kit.gd','')
 for name,value in re.findall(r'const (\w+) := Color\("([0-9a-fA-F]+)"\)',kit):
  add({'id':'token:'+name,'type':'token','title':name,'value':'#'+value,'path':'scripts/components/ui_kit.gd','games':['shared'],'editable':['color'],'description':'Общий цвет UiKit'})
 native=read_json(root/'.local/design-catalog/native.json')
 for i,color in enumerate(native.get('paints',[])):
  add({'id':'paint:'+str(i),'type':'paint','title':'Градиент' if color.startswith('gradient:') else color,'value':color,'games':['drawing','coloring'],'path':'scripts/components/paint_palette.gd','editable':[]})
 components={
  'button_primary':'Основная кнопка','button_secondary':'Обычная кнопка','button_disabled':'Недоступная кнопка','button_pressed':'Нажатая кнопка','back':'Кнопка «Назад»','icon':'Кнопка инструмента','card':'Карточка','slider':'Громкость','tabs':'Вкладки','caption':'Перевод слова'}
 for id,title in components.items():add({'id':'ui:'+id,'type':'component','title':title,'games':['shared'],'path':'scripts/components/ui_kit.gd' if id!='caption' else 'scripts/components/word_translation_caption.gd','preview':'ui_'+id+'.png','editable':[],'description':'Реальное превью Godot'})
 for p in sorted((root/'scripts/components').glob('*.gd')):
  name=p.relative_to(root).as_posix();name_game=[g for g in GAMES if g in p.stem]
  add({'id':'component:'+p.stem,'type':'component','title':p.stem.replace('_',' '),'games':name_game or ['shared'],'path':name,'editable':[],'description':'Компонент проекта · исходный код','preview':None})
 for game,title in GAMES.items():
  if game=='shared':continue
  source=('scripts/home/world_hub.gd' if game=='world' else {'animals':'scripts/games/learn_animals.gd','colors':'scripts/games/learn_colors.gd','feeding':'scripts/games/feed_animals.gd','shapes':'scripts/games/shape_sorting.gd','puzzles':'scripts/games/animal_puzzles.gd','memory':'scripts/games/memory_match.gd','counting':'scripts/games/lets_count.gd','draw_word':'scripts/games/draw_word.gd','drawing':'scripts/games/magic_drawing.gd','coloring':'scripts/games/coloring_book.gd','xylophone':'scripts/games/magic_xylophone.gd','letters':'scripts/games/alphabet_garden.gd','syllables':'scripts/games/syllable_garden.gd','balloons':'scripts/games/balloon_meadow.gd','living_drawing':'scripts/games/living_drawing.gd'}[game])
  add({'id':'screen:'+game,'type':'screen','title':title,'games':[game],'path':source,'preview':'screen_'+game+'.png','editable':[],'description':'Экран игры в текущем проекте'})
 for key,title,games,source,preview in [
  ('draw_word_child','Рисование по слову',['draw_word'],'scripts/games/draw_word.gd','screen_draw_word_child.png'),
  ('draw_word_family','Семейный Крокодил',['draw_word'],'scripts/games/draw_word.gd','screen_draw_word_family.png'),
  ('coloring_reference','Зразок / Coloring example',['coloring'],'scripts/games/coloring_book.gd','screen_coloring_reference.png'),
  ('artwork_export','PNG export / Gallery',['drawing','coloring','draw_word'],'scripts/components/artwork_gallery.gd','screen_artwork_export.png'),
  ('difficulty','Выбор сложности',['shared'],'scripts/components/difficulty_strip.gd','screen_activities.png'),
  ('material_picker','Выбор картинок',['puzzles','memory','syllables'],'scripts/components/material_picker.gd','screen_material_picker.png'),
  ('music_practice','Мелодии с подсказкой',['xylophone'],'scripts/games/magic_xylophone.gd','screen_music_practice.png'),
  ('balloon_challenge','Шарики: испытание',['balloons'],'scripts/games/balloon_meadow.gd','screen_balloon_challenge.png'),
  ('balloon_records','Шарики: рекорды',['balloons'],'scripts/games/balloon_records.gd','screen_balloon_records.png')]:
  add({'id':'mode:'+key,'type':'scene','title':title,'games':games,'path':source,'preview':preview,'editable':[],'description':'Новый режим · настоящий экран Godot'})
 for page in read_json(root/'data/game_content/coloring.json',{'pages':[]})['pages']:
  add({'id':'content:coloring_reference:'+page['id'],'type':'content','title':'Coloring example: '+page['english'],'games':['coloring'],'path':'data/game_content/coloring_references.json','preview':'coloring_example_'+page['id']+'.png','editable':[],'description':'Optional creative reference; no color scoring'})
 order={name:i for i,name in enumerate(['screen','scene','procedural','image','content','trace','component','token','paint','font','audio'])}
 entries.sort(key=lambda e:order.get(e['type'],99))
 reviews=read_json(root/'design_catalog/reviews.json')
 for entry in entries:
  entry['review']=reviews.get(entry['id'],{'status':'current','note':''})
  if entry.get('path') and (root/entry['path']).is_file():entry['source_sha']=digest((root/entry['path']).read_bytes())
  entry['preview_ready']=bool(entry.get('preview') and (root/'.local/design-catalog/previews'/entry['preview']).is_file())
  entry['source_links']=sorted(set(entry.get('usage',[])+([entry['source_code']] if entry.get('source_code') else [])+([entry['path']] if entry.get('path') else [])))
 return {'entries':entries,'games':GAMES,'stats':{'items':len(entries),'assets':len(assets),'audio':sum(e['type']=='audio' for e in entries),'procedural':sum(e['type']=='procedural' for e in entries),'screens':sum(e['type']=='screen' for e in entries)},'native':native,'version':(root/'project.godot').read_text().split('config/version="')[1].split('"')[0]}

class Catalog:
 def __init__(self,root):self.root=Path(root).resolve();self.lock=threading.RLock();self.refresh()
 def refresh(self):
  self.snapshot=inventory(self.root);self.by_id={e['id']:e for e in self.snapshot['entries']};return self.snapshot
 def entry(self,id):
  if id not in self.by_id:raise ValueError('Элемент не найден')
  return self.by_id[id]
 def source(self,path):
  allowed={p for e in self.by_id.values() for p in e.get('source_links',[])}
  if path not in allowed:raise ValueError('Исходник не относится к каталогу')
  p=safe(self.root,path)
  if p.suffix not in ['.gd','.json','.tscn','.md']:raise ValueError('Это не текстовый исходник')
  return p.read_text(encoding='utf-8-sig')
 def review(self,id,status,note):
  self.entry(id)
  if status not in ['current','review','approved','needs_work']:raise ValueError('Неизвестный статус')
  if not isinstance(note,str) or len(note)>4000:raise ValueError('Слишком длинная заметка')
  with self.lock:
   path=self.root/'design_catalog/reviews.json';data=read_json(path);data[id]={'status':status,'note':note};write_json(path,data);self.refresh()
  return data[id]
 def stage(self,id,kind,payload):
  e=self.entry(id)
  current_sha=digest(safe(self.root,e['path']).read_bytes())
  if payload.get('expected_sha',current_sha)!=current_sha:raise ValueError('Исходник уже изменился. Обновите каталог перед созданием черновика.')
  if kind not in e['editable']:raise ValueError('Для этого элемента доступен просмотр; данный редактор не поддерживается')
  draft={'id':uuid.uuid4().hex,'entry_id':id,'kind':kind,'source_sha':digest(safe(self.root,e['path']).read_bytes()),'created':datetime.now(timezone.utc).isoformat()}
  directory=self.root/'.local/design-catalog/drafts'/draft['id'];directory.mkdir(parents=True)
  if kind in ['file','art']:
   ext=payload.get('extension','').lower();note=payload.get('source_note','').strip()
   if not note:raise ValueError('Укажите автора или источник нового рисунка')
   if ext not in ['.png','.svg']:raise ValueError('Замена иллюстраций поддерживает PNG и SVG')
   if kind=='file' and ext!=Path(e['path']).suffix:raise ValueError('Для прямой замены сохраните исходный формат файла')
   raw=base64.b64decode(payload.get('base64',''),validate=True)
   if not raw or len(raw)>16*1024*1024:raise ValueError('Размер изображения должен быть от 1 байта до 16 МБ')
   validate_image(raw,ext)
   name='art'+ext;(directory/name).write_bytes(raw);draft.update(file=name,extension=ext,source_note=note)
  elif kind=='trace':
   strokes=payload.get('strokes');validate_strokes(strokes);draft['strokes']=strokes
  elif kind=='color':
   color=payload.get('color','')
   if not re.fullmatch('#[0-9a-fA-F]{6}',color):raise ValueError('Цвет должен быть #RRGGBB')
   draft['color']=color.lower()
  write_json(directory/'draft.json',draft);return draft
 def load_draft(self,id):
  if not re.fullmatch('[a-f0-9]{32}',id):raise ValueError('Некорректный черновик')
  return read_json(self.root/'.local/design-catalog/drafts'/id/'draft.json')
 def apply(self,id):
  with self.lock:
   draft=self.load_draft(id)
   if not draft or draft.get('applied'):raise ValueError('Черновик отсутствует или уже применён')
   e=self.entry(draft['entry_id']);path=safe(self.root,e['path'])
   if digest(path.read_bytes())!=draft['source_sha']:raise ValueError('Исходник изменился после создания черновика. Обновите каталог и создайте новый черновик.')
   changes={};kind=draft['kind'];folder=self.root/'.local/design-catalog/drafts'/id
   if kind=='file':changes[e['path']]=(folder/draft['file']).read_bytes()
   elif kind=='art':
    override='assets/design/overrides/'+e['override_key'].replace('/','_')+draft['extension'];changes[override]=(folder/draft['file']).read_bytes()
    target='data/game_content/design_visual_overrides.json';data=read_json(self.root/target,{'version':1,'overrides':{}});data['overrides'][e['override_key']]={'texture':'res://'+override,'source_note':draft['source_note']};changes[target]=(json.dumps(data,ensure_ascii=False,indent=2)+'\n').encode()
   elif kind=='trace':
    data=read_json(path)
    if e['type']=='procedural':item=next(x for x in data['parts'] if x['id']==e['part_id'])
    else:item=data['letters'][e['locale']][e['symbol_index']] if e['symbol_kind']=='letters' else data['digits'][e['symbol_index']]
    item['strokes']=draft['strokes'];changes[e['path']]=(json.dumps(data,ensure_ascii=False,indent=2)+'\n').encode()
   elif kind=='color':
    text=path.read_text(encoding='utf-8');token=e['id'].split(':')[1];text,count=re.subn(r'(const '+re.escape(token)+r' := Color\(")[0-9a-fA-F]+("\))',lambda m:m[1]+draft['color'].lstrip('#')+m[2],text)
    if count!=1:raise ValueError('Цветовой токен не найден однозначно')
    changes[e['path']]=text.encode()
   journal={'id':id,'entry_id':e['id'],'kind':kind,'created':datetime.now(timezone.utc).isoformat(),'files':[],'rolled_back':False}
   backup=self.root/'.local/design-catalog/history'/id;backup.mkdir(parents=True,exist_ok=True)
   for i,(relative,raw) in enumerate(changes.items()):
    target=safe(self.root,relative);old=target.read_bytes() if target.exists() else None;name=str(i)+'.bin'
    if old is not None:(backup/name).write_bytes(old)
    journal['files'].append({'path':relative,'backup':name if old is not None else None,'sha_after':digest(raw)})
   # All validation and backups finish before the first runtime file changes.
   written=[]
   try:
    for relative,raw in changes.items():
     target=safe(self.root,relative);target.parent.mkdir(parents=True,exist_ok=True);tmp=target.with_name(target.name+'.catalog-tmp');tmp.write_bytes(raw);tmp.replace(target);written.append(relative)
   except Exception:
    for record in journal['files']:
     if record['path'] not in written:continue
     target=safe(self.root,record['path'])
     if record['backup']:target.write_bytes((backup/record['backup']).read_bytes())
     else:target.unlink(missing_ok=True)
    raise
   write_json(backup/'journal.json',journal);draft['applied']=True;write_json(folder/'draft.json',draft);self.refresh();return journal
 def history(self):return sorted([read_json(p) for p in (self.root/'.local/design-catalog/history').glob('*/journal.json')],key=lambda x:x['created'],reverse=True)
 def rollback(self,id):
  with self.lock:
   if not re.fullmatch('[a-f0-9]{32}',id):raise ValueError('Некорректная версия')
   folder=self.root/'.local/design-catalog/history'/id;j=read_json(folder/'journal.json')
   if not j or j['rolled_back']:raise ValueError('Версия уже отменена или не найдена')
   for record in j['files']:
    target=safe(self.root,record['path'])
    if not target.exists() or digest(target.read_bytes())!=record['sha_after']:raise ValueError('После применения файл изменился. Автоматический откат остановлен.')
   for record in j['files']:
    target=safe(self.root,record['path'])
    if record['backup']:target.write_bytes((folder/record['backup']).read_bytes())
    else:target.unlink()
   j['rolled_back']=True;write_json(folder/'journal.json',j);self.refresh();return j

def validate_strokes(strokes):
 if not isinstance(strokes,list) or not 1<=len(strokes)<=20:raise ValueError('Нужно от 1 до 20 штрихов')
 for stroke in strokes:
  if not isinstance(stroke,list) or not 2<=len(stroke)<=512:raise ValueError('В штрихе нужно от 2 до 512 точек')
  for point in stroke:
   if not isinstance(point,list) or len(point)!=2 or any(type(n) not in [int,float] or not math.isfinite(n) or abs(n)>5000 for n in point):raise ValueError('Некорректная точка контура')
  if any(a==b for a,b in zip(stroke,stroke[1:])):raise ValueError('Соседние точки не должны совпадать')
def validate_image(raw,ext):
 if ext=='.png':
  if not raw.startswith(b'\x89PNG\r\n\x1a\n') or len(raw)<33 or raw[12:16]!=b'IHDR':raise ValueError('Повреждённый PNG')
  w=int.from_bytes(raw[16:20],'big');h=int.from_bytes(raw[20:24],'big')
  if not 0<w<=8192 or not 0<h<=8192 or w*h>40_000_000:raise ValueError('Слишком большое изображение')
  offset=8;idat=[];ended=False
  while offset+12<=len(raw):
   length=int.from_bytes(raw[offset:offset+4],'big');tag=raw[offset+4:offset+8];end=offset+12+length
   if end>len(raw):raise ValueError('Обрезанный PNG')
   data=raw[offset+8:offset+8+length];crc=int.from_bytes(raw[offset+8+length:end],'big')
   if zlib.crc32(tag+data)&0xffffffff!=crc:raise ValueError('Ошибка контрольной суммы PNG')
   if tag==b'IDAT':idat.append(data)
   if tag==b'IEND':ended=True;break
   offset=end
  if not ended or not idat:raise ValueError('Повреждённый PNG: нет изображения/IEND')
  decoder=zlib.decompressobj();decoder.decompress(b''.join(idat),min(320_000_000,w*h*9+h*8+1024))
  if not decoder.eof:raise ValueError('Повреждённые или слишком большие данные PNG')
 else:
  text=raw.decode('utf-8-sig')
  if '<!DOCTYPE' in text.upper() or '<!ENTITY' in text.upper():raise ValueError('SVG с DTD/ENTITY не поддерживается')
  tree=ET.fromstring(text)
  if tree.tag.split('}')[-1]!='svg':raise ValueError('Это не SVG')
  for node in tree.iter():
   if node.tag.split('}')[-1].lower() in ['script','foreignobject','iframe']:raise ValueError('Исполняемые элементы в SVG запрещены')
   if node.tag.split('}')[-1].lower()=='style' and re.search(r'(?i)https?:|file:|javascript:|@import',node.text or ''):raise ValueError('Внешние ссылки в стилях SVG запрещены')
   for key,value in node.attrib.items():
    name=key.split('}')[-1].lower()
    if any(not v.strip().strip("\"'").startswith('#') for v in re.findall(r'url\(([^)]+)\)',value)):raise ValueError('Внешние ссылки в SVG запрещены')
    if name.startswith('on') or ('href' in name and not value.startswith('#')) :raise ValueError('SVG должен быть автономным и не содержать внешних ссылок')
