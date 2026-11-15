"""Per-letter signal audit. Voicing is a quality screen, not semantic recognition."""
import array,csv,json,math,wave
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
manifest=json.loads((ROOT/'assets/audio/voice/manifest.json').read_text(encoding='utf-8'))
clips={(c['locale'],c['key']):c for c in manifest['clips']}
expected_en=['eɪ','biː','siː','diː','iː','ɛf','dʒiː','eɪtʃ','aɪ','dʒeɪ','keɪ','ɛl','ɛm','ɛn','əʊ','piː','kjuː','ɑː','ɛs','tiː','juː','viː','dʌbəljuː','ɛks','waɪ','zɛd']
rows=[]
for locale in ['en','uk']:
 data=json.loads((ROOT/'data/game_content/letters.json').read_text(encoding='utf-8'))['alphabets'][locale]
 for position,entry in enumerate(data):
  path=ROOT/f"assets/audio/voice/{locale}/{entry['word_key'].lower()}.wav"
  from audio_metrics import measure
  metrics=measure(path)
  clip=clips[(locale,entry['word_key'])]
  extracted=clip.get('extraction',{})
  actual=extracted.get('target_phonemes','')
  expected=expected_en[position] if locale=='en' else __import__('letter_aligned').ukrainian_letter_phonemes(entry['word_key']).replace('ˈ','').replace('ˌ','')
  normalized=actual.replace('ˈ','').replace('ˌ','')
  if locale=='en' and entry['upper']=='X':normalized=normalized.replace('ɛː','ɛ')
  phonemes_match=normalized==expected
  metrics['phonemes_match']=phonemes_match
  metrics['review']=metrics['review'] or not phonemes_match

  row=dict(locale=locale,glyph=entry['upper'],key=entry['word_key'],**metrics)
  duration=metrics['seconds'];active=metrics['active_ms']//10;voiced=metrics['voiced_ms']//10
  rows.append(row);print(f"{locale} {entry['upper']:2} {duration:.2f}s active={active*10:4}ms voiced={voiced*10:4}ms {'REVIEW' if row['review'] else 'voiced'}",flush=True)
out=ROOT/'.local/qa/letter-audio';out.mkdir(parents=True,exist_ok=True)
(out/'audit.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
with (out/'audit.csv').open('w',encoding='utf-8-sig',newline='') as f:w=csv.DictWriter(f,rows[0].keys());w.writeheader();w.writerows(rows)
print('REVIEW:',[(r['locale'],r['glyph']) for r in rows if r['review']])

import html
cards=[]
for row in rows:
 file=f"assets/audio/voice/{row['locale']}/{row['key'].lower()}.wav"
 cards.append('<article><h2>'+html.escape(row['locale'].upper()+' '+row['glyph'])+'</h2><audio controls preload="none" src="../../../'+file+'"></audio><p>'+str(row['seconds'])+'s · voiced '+str(row['voiced_ms'])+'ms</p></article>')
(out/'listen.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8"><title>Individual letter audio review</title><style>body{font:20px system-ui;background:#f4f3e5;color:#243b36;margin:30px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:16px}article{padding:20px;background:white;border-radius:18px}h2{margin:0 0 12px}p{font-size:15px}</style><h1>59 individual letter recordings</h1><p>Technical voicing and phoneme checks do not replace listening. The game plays only the letter, without the synthesis context.</p><main>'+''.join(cards)+'</main></html>',encoding='utf-8')
raise SystemExit(1 if any(r['review'] for r in rows) else 0)
