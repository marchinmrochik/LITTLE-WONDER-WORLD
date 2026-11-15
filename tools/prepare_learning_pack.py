"""Finite alphabet names, beginning blends and localized UI; no downloaded media."""
from pathlib import Path
import json,runpy
ROOT=Path(__file__).resolve().parents[1]
def read(path):return json.loads((ROOT/path).read_text(encoding='utf-8'))
def write(path,data):(ROOT/path).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
en=read('data/localization/en.json');uk=read('data/localization/uk.json')
copy={
'ALPH_TITLE':('Letters','Літери'),'ALPH_EN':('ABC','ABC'),'ALPH_UK':('АБВ','АБВ'),
'ALPH_HINT':('Tap a letter and listen.','Натисни на літеру та послухай.'),
'BLEND_TITLE':('Build a word','Збери слово'),'BLEND_HINT':('Look at the picture. Tap the letters in order.','Подивись на малюнок. Натискай літери по черзі.'),
'BLEND_NEXT':('Next word','Наступне слово'),'BLEND_GOAL':('Build: {syllable}','Збери: {syllable}'),
'BLEND_PROGRESS':('Word {current} of {total}','Слово {current} із {total}'),
'BALLOONS_TITLE':('Balloon meadow','Галявина кульок'),'BALLOONS_HINT':('Pop the balloons. Take your time!','Лопай кульки. Не поспішай!'),
'BALLOONS_AGAIN':('More balloons','Ще кульки'),
'PALETTE_MORE':('Colors and gradients','Кольори та градієнти'),'PALETTE_GRADIENT':('Two-color gradient','Двоколірний градієнт')}
for key,(a,b) in copy.items():en[key]=a;uk[key]=b
manifest=read('data/game_content/foundation.json');jobs=read('data/game_content/voice_jobs.json')
for locale in jobs:jobs[locale]=[j for j in jobs[locale] if not j['key'].startswith(('ALPH_','BLEND_'))]
study=manifest.setdefault('study_locales',{})
def voice(key,text,locale):
 path=f'assets/audio/voice/{locale}/{key.lower()}.wav'
 manifest['voice'][key]={'en':'res://'+path,'uk':'res://'+path};study[key]=locale
 jobs[locale].append({'key':key,'text':text,'file':path})
 en[key]=text;uk[key]=text
alphabets={}
uk_names=['А','Бе','Ве','Ге','Ґе','Де','Е','Є','Же','Зе','И','І','Ї','Йот','Ка','Ел','Ем','Ен','О','Пе','Ер','Ес','Те','У','Еф','Ха','Це','Че','Ша','Ща',"М'який знак",'Ю','Я']
for locale,glyphs in [('en','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),('uk','АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ')]:
 entries=[]
 for i,glyph in enumerate(glyphs):
  key=f'ALPH_{locale.upper()}_{i:02d}'
  text=f'The letter {glyph}.' if locale=='en' else uk_names[i]+'.'
  voice(key,text,locale)
  entries.append({'id':f'{locale}_{i}','upper':glyph,'lower':glyph.lower(),'word_key':key})
 alphabets[locale]=entries
blends={}
for locale,syllables in [('en',['AT','AN','IN','IT','ON','UP']),('uk',[c+v for c in ['М','Н','С','Т'] for v in ['А','О','У','И','І']])]:
 blends[locale]=[]
 for i,syllable in enumerate(syllables):
  key=f'BLEND_{locale.upper()}_{i:02d}'
  text=syllable.lower()+'.'
  voice(key,text,locale)
  blends[locale].append({'id':f'{locale}_{i}','letters':list(syllable),'word_key':key,'text':syllable})
write('data/game_content/letters.json',{'version':1,'alphabets':alphabets,'syllables':blends})
write('data/localization/en.json',en);write('data/localization/uk.json',uk)
write('data/game_content/foundation.json',manifest);write('data/game_content/voice_jobs.json',jobs)
runpy.run_path(str(ROOT/'tools/prepare_full_ukrainian.py'),run_name='__main__')
print('Learning pack: 26 English +33 Ukrainian letters;6 English +20 Ukrainian starting blends.')

runpy.run_path(str(ROOT/"tools/prepare_alphabet_cards.py"),run_name="__main__")
