"""Build finite text-only EN->UK vocabulary captions from the authored catalogs."""
from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
def read(p):return json.loads((R/p).read_text(encoding='utf-8'))
lookup={};words={}
for source,field in [('animals','animals'),('foods','foods'),('colors','colors'),('shapes','shapes'),('world_body','items'),('world_plants','items'),('coloring','pages'),('counting','counting'),('memory','memory'),('puzzles','puzzles')]:
 for item in read('data/game_content/'+source+'.json')[field]:
  pair={'english':item['english'],'ukrainian':item['ukrainian']};words[item['english'].lower()]=pair
  for key in ['word_key','prompt_key']:
   if item.get(key):lookup[item[key]]=pair
extra={'Goat':'Коза','House':'Будинок','Ice cream':'Морозиво','Jelly':'Желе','Kite':'Повітряний змій','Moon':'Місяць','Nest':'Гніздо','Queen':'Королева','Sun':'Сонце','Tree':'Дерево','Umbrella':'Парасолька','Violin':'Скрипка','Whale':'Кит','Xylophone':'Ксилофон','Yo-yo':'Йо-йо','Zebra':'Зебра','Bee':'Бджілка','Cloud':'Хмаринка','Butterfly':'Метелик','Frog':'Жабка','Pond':'Ставок','Rainbow':'Веселка','Bunny':'Зайчик','Leaves':'Листя','Hedgehog':'Їжачок','Mushrooms':'Гриби','Pumpkin':'Гарбуз','Basket':'Кошик','Boots':'Чобітки','Puddle':'Калюжа','Squirrel':'Білка','Cottage':'Хатинка','Snowman':'Сніговик','Pine':'Сосна','Penguin':'Пінгвін','Sled':'Санчата','Gift':'Подарунок','Lantern':'Ліхтарик','Star':'Зірка','Snowflake':'Сніжинка','Bird':'Пташка','Flowers':'Квіти'}
for en,uk in extra.items():words.setdefault(en.lower(),{'english':en,'ukrainian':uk})
for item in read('data/game_content/letters.json')['alphabets']['en']:
 lookup[item['example_key']]={'english':'Orange','ukrainian':'Апельсин'} if item['example']=='Orange' else words[item['example'].lower()]
for season in ['spring','autumn','winter']:
 for item in read('data/game_content/living_'+season+'.json')['parts']:
  word={'pine':'Fir tree','basket':'Basket'}.get(item['id'],item['id'].capitalize())
  pair=words.get(word.lower(),{'english':'Fir tree','ukrainian':'Ялинка'})
  lookup[item['prompt']]=pair
for id,en,uk in [('walls','Walls','Стіни'),('roof','Roof','Дах'),('door','Door','Двері'),('left_window','Left window','Ліве вікно'),('right_window','Right window','Праве вікно'),('chimney','Chimney','Труба'),('sun','Sun','Сонце'),('cloud','Cloud','Хмаринка'),('dog','Puppy','Песик'),('flowers','Flowers','Квіти')]:lookup['LIVE_'+id.upper()]={'english':en,'ukrainian':uk}
en=read('data/localization/en.json');uk=read('data/localization/uk.json')
for i in range(1,11):
 key='COUNT_NUMBER_'+str(i);lookup[key]={'english':en[key],'ukrainian':uk[key]}
for key in en:
 if key.startswith(('COUNT_HOW_','COUNT_PUT_')):lookup[key]={'english':en[key],'ukrainian':uk[key]}
lookup['TRACE_NUMBER_ZERO']={'english':'Zero','ukrainian':'Нуль'}
(R/'data/game_content/word_translations.json').write_text(json.dumps({'version':1,'captions':lookup},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
copy={'EN_UK_TRANSLATIONS':('Ukrainian word translations','Український переклад слів'),'EN_UK_TRANSLATIONS_HINT':('In English mode, show the current word with its Ukrainian translation above the game. Speech stays English.','В англійському режимі показувати поточне слово та його український переклад над грою. Озвучка залишиться англійською.')}
for locale,strings,index in [('en',en,0),('uk',uk,1)]:
 for key,pair in copy.items():strings[key]=pair[index]
 (R/f'data/localization/{locale}.json').write_text(json.dumps(strings,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Text-only bilingual vocabulary captions:',len(lookup))
