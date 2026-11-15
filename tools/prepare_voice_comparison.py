"""Generate a small, local A/B pack. Never replaces runtime speech."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import wave
from voice_processing import normalize

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'.local/qa/f01'
KEYS=['WORD_CAT','WORD_SHEEP','WORD_BEAR','COLOR_WORD_RED','FOOD_WORD_BREAD',
      'COUNT_NUMBER_5','WORLD_BODY_FOOT_WORD','WORLD_BODY_EYEBROW_WORD',
      'WORLD_BODY_CHEEK_WORD','WORD_DUCK','FIND_DUCK','TRACE_HINT']

def main():
    manifest=json.loads((ROOT/'assets/audio/voice/manifest.json').read_text(encoding='utf-8'))
    letters=json.loads((ROOT/'data/game_content/letters.json').read_text(encoding='utf-8'))['alphabets']
    selected={l:KEYS+[e['word_key'] for e in letters[l] if e['upper'] in (['Z','F','X'] if l=='en' else ['З','Г','Ґ','И','І','Ї'])] for l in ['en','uk']}
    configurations=[('en','cori_standard','en_GB-cori-high.onnx','Cori GB · стандартная вариативность',None),
                    ('en','ljspeech','en_US-ljspeech-high.onnx','LJ Speech · US · другой голос',None),
                    ('uk','tetiana_standard','uk_UA-tetiana-high.onnx','Tetiana High · стандартный текстовый вход',None),
                    ('uk','tetiana_medium','uk_UA-ukrainian_tts-medium.onnx','Tetiana Medium · другая модель / текстовый вход',2)]
    result={'version':1,'manifest_sha256':hashlib.sha256((ROOT/'assets/audio/voice/manifest.json').read_bytes()).hexdigest(),'note':'Candidates are unapproved; no runtime files changed. Models already present locally.','variants':[],'samples':[]}
    folder=OUT/'candidates';folder.mkdir(parents=True,exist_ok=True)
    clips={(c['locale'],c['key']):c for c in manifest['clips']}
    for locale,variant,model_name,label,speaker in configurations:
        model=ROOT/'.tools/piper-voices'/model_name
        jobs=[]
        for key in selected[locale]:
            clip=clips.get((locale,key))
            if not clip:continue
            path=folder/f'{variant}__{key.lower()}.wav'
            jobs.append({'text':clip['text'],'output_file':str(path)})
        command=[str(ROOT/'.tools/piper/piper.exe'),'--model',str(model),'--json-input','--length_scale','1.05','--noise_scale','0.667','--noise_w','0.8','--sentence_silence','0.15']
        if speaker is not None:command+=['--speaker',str(speaker)]
        print(f'Comparing {variant}: {len(jobs)} clips',flush=True)
        process=subprocess.run(command,input=('\n'.join(json.dumps(j,ensure_ascii=False) for j in jobs)+'\n').encode('utf-8'),cwd=ROOT/'.tools/piper',capture_output=True)
        (OUT/f'{variant}.log').write_bytes(process.stderr+process.stdout)
        if process.returncode:raise RuntimeError(f'Synthesis failed for {variant}; inspect local log')
        result['variants'].append({'id':variant,'locale':locale,'label':label,'model':model_name,
            'model_sha256':hashlib.sha256(model.read_bytes()).hexdigest(),'speaker':speaker,
            'scales':{'noise':.667,'length':1.05,'noise_w':.8}})
        for job in jobs:
            path=Path(job['output_file']);normalize(path)
            key=path.stem.split('__')[1].upper()
            with wave.open(str(path),'rb') as f:seconds=round(f.getnframes()/f.getframerate(),3)
            result['samples'].append({'locale':locale,'key':key,'variant':variant,'label':label,
                'file':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'seconds':seconds})
    (OUT/'comparison.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f"Comparison ready: {len(result['samples'])} candidates; runtime unchanged",flush=True)

if __name__=='__main__':main()
