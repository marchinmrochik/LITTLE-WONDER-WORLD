"""Reproducible routing/text audit and listening inventory. No speech recognition claims."""
import argparse
from collections import defaultdict
import csv
import hashlib
import json
from pathlib import Path
import re
import wave

ROOT = Path(__file__).resolve().parents[1]
PRIORITY = {'WORD_CAT','FIND_CAT','WORD_SHEEP','FIND_SHEEP','WORD_BEAR','FIND_BEAR',
            'COLOR_WORD_RED','COLOR_FIND_RED','FOOD_WORD_BREAD','FOOD_GIVE_BREAD','COUNT_NUMBER_5','ALPH_EN_25',
            'ALPH_UK_09','WORLD_BODY_FOOT_WORD','WORLD_BODY_FOOT_FIND'}

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def normalized(text):
    # Sentence punctuation used to improve TTS is not a vocabulary mismatch.
    return re.sub(r'\s+', ' ', text.replace('’', "'")).strip().rstrip('.!?…').casefold()

def make_audit(root=ROOT):
    manifest = read(root/'assets/audio/voice/manifest.json')
    foundation = read(root/'data/game_content/foundation.json')['voice']
    jobs = read(root/'data/game_content/voice_jobs.json')
    texts = {l: read(root/f'data/localization/{l}.json') for l in ['en','uk']}
    jobs_by_id = {(l,e['key']):e for l,entries in jobs.items() for e in entries}
    bindings = defaultdict(list)
    def walk(value, source, locale=None):
        if isinstance(value, dict):
            for field,key in value.items():
                if (field.endswith('_key') or field=='prompt') and isinstance(key,str):
                    image = value.get('illustration',value.get('preview',''))
                    bindings[key].append({'source':source,'id':value.get('id',value.get('upper','')),
                        'image':image,'glyph':value.get('upper',''),'art_region':value.get('art_region'), 'locale':locale})
                walk(key,source,field if field in ['en','uk'] else locale)
        elif isinstance(value,list):
            for item in value: walk(item,source,locale)
    for path in sorted((root/'data/game_content').glob('*.json')):
        if path.stem not in ['foundation','voice_jobs','word_translations','symbol_tracing','design_visual_overrides']:
            walk(read(path),path.relative_to(root).as_posix())
    rows=[]; ids=set(); errors=[]
    overrides=read(root/'tools/voice_clip_overrides.json')['clips'] if (root/'tools/voice_clip_overrides.json').exists() else {}
    repairs=read(root/'tools/voice_repair_pins.json')['clips'] if (root/'tools/voice_repair_pins.json').exists() else {}
    for clip in manifest['clips']:
        locale,key=clip['locale'],clip['key']; identity=locale+':'+key
        checks={}; path=root/clip['file']; exists=path.is_file()
        checks['unique']=identity not in ids; ids.add(identity)
        checks['hash']=exists and hashlib.sha256(path.read_bytes()).hexdigest()==clip['sha256']
        if identity in overrides:
            checks['selected_recording']=exists and hashlib.sha256(path.read_bytes()).hexdigest()==overrides[identity]['sha256']
        if identity in repairs:
            checks['repair_recording']=exists and hashlib.sha256(path.read_bytes()).hexdigest()==repairs[identity]['sha256']
        checks['route']=foundation.get(key,{}).get(locale)=='res://'+clip['file']
        job=jobs_by_id.get((locale,key),{})
        checks['job']=job.get('file')==clip['file'] and job.get('text')==clip['text']
        checks['text']=normalized(texts[locale].get(key,''))==normalized(clip['text'])
        checks['format']=False
        if exists:
            with wave.open(str(path),'rb') as f:
                checks['format']=f.getnchannels()==1 and f.getsampwidth()==2 and f.getframerate() in [16000,22050]
                seconds=round(f.getnframes()/f.getframerate(),3)
        else: seconds=0
        associated=[b for b in bindings[key] if b['locale'] in [None,locale]]
        priority=key in PRIORITY or key.startswith('WORLD_BODY_') or (locale=='uk' and key in ['WORD_DUCK','FIND_DUCK'])
        failures=[name for name,passed in checks.items() if not passed]
        errors.extend({'id':identity,'check':name} for name in failures)
        rows.append({'id':identity,'locale':locale,'key':key,'text':clip['text'],
            'ui_text':texts[locale].get(key,''),'file':clip['file'],'sha256':clip['sha256'],
            'seconds':seconds,'priority':priority,'checks':checks,'bindings':associated,
            'source_phonemes':clip.get('source_phonemes',clip.get('extraction',{}).get('target_phonemes','')),
            'technical_status':'pass' if not failures else 'fail','listening_status':'unreviewed'})
    if len(rows)!=len(jobs_by_id): errors.append({'id':'pack','check':'coverage'})
    return {'version':1,'manifest_sha256':hashlib.sha256((root/'assets/audio/voice/manifest.json').read_bytes()).hexdigest(),
            'counts':{l:sum(r['locale']==l for r in rows) for l in ['en','uk']},
            'errors':errors,'clips':sorted(rows,key=lambda r:(not r['priority'],r['locale'],r['key']))}

def main():
    parser=argparse.ArgumentParser();parser.parse_args()
    data=make_audit();out=ROOT/'.local/qa/f01';out.mkdir(parents=True,exist_ok=True)
    (out/'audit.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    with (out/'audit.csv').open('w',encoding='utf-8-sig',newline='') as f:
        columns=['id','locale','key','text','ui_text','file','sha256','seconds','priority','technical_status','listening_status']
        writer=csv.DictWriter(f,columns,extrasaction='ignore');writer.writeheader();writer.writerows(data['clips'])
    print(f"VOICE CONTENT: {len(data['clips'])} clips; {len(data['errors'])} errors; counts {data['counts']}",flush=True)
    for error in data['errors']: print(error,flush=True)
    raise SystemExit(bool(data['errors']))

if __name__=='__main__':main()
