"""Per-letter signal and independent transcript analysis; never approves speech."""
import hashlib,json,re
from pathlib import Path
from audio_metrics import measure
from audit_spoken_words import normalized
ROOT=Path(__file__).resolve().parents[1]
EN_NAMES=['ay','bee','see','dee','ee','ef','gee','aitch','eye','jay','kay','el','em','en','oh','pee','cue','ar','ess','tee','you','vee','double you','ex','why','zed']
EN_ALIASES={'ay':['a'],'bee':['be'],'see':['sea'],'dee':['d'],'ef':['f'],'gee':['g'],'eye':['i'],'kay':['k'],'oh':['o'],'pee':['p'],'cue':['q'],'ar':['are'],'ess':['s'],'tee':['t'],'you':['u'],'vee':['v'],'double you':['w','double u'],'ex':['x'],'why':['y'],'zed':['z','zee']}

def classify(locale,glyph,expected,transcript,metrics,human_selected=False):
 if human_selected:return 'human_selected'
 if re.search(r'\[(music|noise|silence|applause)\]',transcript,re.I):return 'non_speech_asr'
 if metrics.get('review'):return 'weak_voicing'
 actual=normalized(transcript,locale)
 if not actual:return 'unrecognized'
 allowed={normalized(expected,locale),normalized(glyph,locale)}
 if locale=='en':
  name=EN_NAMES[ord(glyph)-ord('A')];allowed.add(normalized(name,locale));allowed.update(normalized(a,locale) for a in EN_ALIASES.get(name,[]))
 return 'recognizer_consistent' if actual in allowed else 'asr_disagreement'

def main():
 manifest_path=ROOT/'assets/audio/voice/manifest.json';manifest=json.loads(manifest_path.read_text(encoding='utf-8'));sha=hashlib.sha256(manifest_path.read_bytes()).hexdigest()
 recognition=json.loads((ROOT/'.local/qa/voice-asr/asr.json').read_text(encoding='utf-8'))
 if recognition['manifest_sha256']!=sha or not recognition['complete']:raise ValueError('Run the complete current-pack ASR audit first')
 by_id={c['id']:c for c in recognition['clips']};clips={(c['locale'],c['key']):c for c in manifest['clips']}
 letters=json.loads((ROOT/'data/game_content/letters.json').read_text(encoding='utf-8'))['alphabets']
 selected=json.loads((ROOT/'tools/voice_clip_overrides.json').read_text(encoding='utf-8'))['clips'];rows=[]
 for locale in ['en','uk']:
  for letter in letters[locale]:
   clip=clips[locale,letter['word_key']];identity=locale+':'+clip['key'];path=ROOT/clip['file'];actual_hash=hashlib.sha256(path.read_bytes()).hexdigest()
   if actual_hash!=clip['sha256'] or by_id[identity]['sha256']!=actual_hash:raise ValueError('Stale letter: '+identity)
   metrics=measure(path);result=classify(locale,letter['upper'],clip['text'],by_id[identity]['transcript'],metrics,identity in selected)
   rows.append({'id':identity,'glyph':letter['upper'],'locale':locale,'expected_name':clip['text'],'transcript':by_id[identity]['transcript'],'state':result,'signal':metrics,'sha256':actual_hash,'file':clip['file'],'listening_approval':'owner-selected' if identity in selected else 'pending'})
 from collections import Counter
 report={'version':1,'manifest_sha256':sha,'counts':dict(Counter(r['state'] for r in rows)),'letters':rows,'note':'Signals and recognizer aliases do not approve pronunciation. All non-selected letters still require human listening.'}
 out=ROOT/'.local/qa/alphabet-030';out.mkdir(parents=True,exist_ok=True);(out/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 import time
 history=out/'history';history.mkdir(exist_ok=True);(history/(str(time.time_ns())+'.json')).write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 text=['# Individual alphabet analysis','',report['note'],'','| Language | Letter | Expected name | Recognized | Signal voiced ms | Result |','|---|---|---|---|---:|---|']
 text.extend('| '+ ' | '.join([r['locale'],r['glyph'],r['expected_name'],r['transcript'].replace('|','/'),str(r['signal']['voiced_ms']),r['state']])+' |' for r in rows)
 (out/'REPORT.md').write_text('\n'.join(text)+'\n',encoding='utf-8')
 print('ALPHABET ANALYSIS:',len(rows),'letters;',report['counts'])
 print('Per-letter report:',out/'REPORT.md')

if __name__=='__main__':main()
