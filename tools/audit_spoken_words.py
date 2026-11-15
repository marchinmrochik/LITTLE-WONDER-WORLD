"""Independent, offline ASR triage. No expected-text prompts or auto approvals.

Whisper/model are PC-only tools under ignored .tools; reports/cache under .local.
An ASR mismatch is a review request, not proof that a recording is wrong.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import unicodedata
import wave

ROOT=Path(__file__).resolve().parents[1]
NUMBERS={
    'en':['zero','one','two','three','four','five','six','seven','eight','nine','ten'],
    'uk':['нуль','один','два','три','чотири',"п'ять",'шість','сім','вісім',"дев'ять",'десять']}
CONFIG={'threads':4,'context':0,'beam':3,'temperature':0,'prompt':None,'max_text_context':0}

def normalized(text,locale):
    text=unicodedata.normalize('NFKC',text).casefold().replace('’',"'").replace('ʼ',"'")
    tokens=re.findall(r"[^\W_]+(?:'[^\W_]+)*",text,flags=re.UNICODE)
    aliases={word:str(i) for i,word in enumerate(NUMBERS[locale])}
    return ' '.join(aliases.get(token,token) for token in tokens)

def word_error_rate(expected,actual):
    a,b=expected.split(),actual.split();row=list(range(len(b)+1))
    for i,word in enumerate(a,1):
        current=[i]
        for j,other in enumerate(b,1):current.append(min(current[-1]+1,row[j]+1,row[j-1]+(word!=other)))
        row=current
    return round(row[-1]/max(1,len(a)),3)

def evaluate(clip,transcript):
    expected=normalized(clip['text'],clip['locale']);actual=normalized(transcript,clip['locale'])
    letter=re.fullmatch(r'ALPH_(EN|UK)_\d{2}',clip['key']) is not None
    # A recognizer cannot reliably certify a sub-second isolated letter name.
    state='letter_manual' if letter else 'unrecognized' if not actual else 'match' if expected==actual else 'mismatch'
    return {'state':state,'transcript':transcript,'expected':clip['text'],
            'word_error_rate':word_error_rate(expected,actual),'human_approved':False}

def checksum(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def pcm(source,target):
    sys.path.insert(0,str(ROOT/'.tools/python-audio'))
    import numpy as np
    with wave.open(str(source),'rb') as f:
        if f.getnchannels()!=1 or f.getsampwidth()!=2:raise ValueError('Unexpected source PCM')
        rate=f.getframerate();samples=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').astype(np.float32)
    count=round(len(samples)*16000/rate)
    audio=np.interp(np.arange(count)*rate/16000,np.arange(len(samples)),samples)
    # Small silence margins; no context words or synthesized expected text.
    audio=np.concatenate([np.zeros(1600),audio,np.zeros(4800)]).clip(-32768,32767).astype('<i2')
    target.parent.mkdir(parents=True,exist_ok=True)
    with wave.open(str(target),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(16000);f.writeframes(audio.tobytes())

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--limit',type=int,default=0);parser.add_argument('--locale',choices=['en','uk']);parser.add_argument('--key',action='append',default=[]);args=parser.parse_args()
    exe=ROOT/'.tools/whisper-cpp/Release/whisper-cli.exe';model=ROOT/'.tools/whisper-cpp/ggml-base.bin'
    if not exe.exists() or not model.exists():raise SystemExit('Install the documented PC-only whisper.cpp toolchain first.')
    manifest_path=ROOT/'assets/audio/voice/manifest.json';manifest=json.loads(manifest_path.read_text(encoding='utf-8'));manifest_hash=checksum(manifest_path)
    out=ROOT/'.local/qa/voice-asr';out.mkdir(parents=True,exist_ok=True)
    model_hash=checksum(model);engine_hash=checksum(exe)
    identity=hashlib.sha256(json.dumps([CONFIG,model_hash,engine_hash],sort_keys=True).encode()).hexdigest()
    clips=[c for c in manifest['clips'] if (not args.locale or c['locale']==args.locale) and (not args.key or c['key'] in args.key)]
    if args.limit:clips=clips[:args.limit]
    results=[]
    def transcribe_batch(task):
        locale,start,batch=task
        pending=[]
        for clip in batch:
            if checksum(ROOT/clip['file'])!=clip['sha256']:raise ValueError('Stale source: '+clip['key'])
            stem=clip['key'].lower()+'-'+clip['sha256'][:12]+'-'+identity[:8]
            target=out/'pcm'/locale/(stem+'.wav')
            if not target.with_suffix('.wav.json').exists():pcm(ROOT/clip['file'],target);pending.append(target)
        if pending:
            command=[str(exe),'-m',str(model),'-l',locale,'-t',str(CONFIG['threads']),'-mc','0','-ac',str(CONFIG['context']),'-bs','3','-bo','1','-nf','-ng','-oj','-nt']+[str(p) for p in pending]
            process=subprocess.run(command,capture_output=True,timeout=900)
            (out/f'{locale}-{start}.log').write_bytes(process.stderr+process.stdout)
            if process.returncode:raise RuntimeError('ASR failed; inspect local log')
        rows=[]
        for clip in batch:
            stem=clip['key'].lower()+'-'+clip['sha256'][:12]+'-'+identity[:8]
            path=out/'pcm'/locale/(stem+'.wav.json')
            data=json.loads(path.read_text(encoding='utf-8'))
            transcript=' '.join(segment['text'].strip() for segment in data.get('transcription',[])).strip()
            rows.append({'id':locale+':'+clip['key'],'locale':locale,'key':clip['key'],'sha256':clip['sha256'],**evaluate(clip,transcript)})
        return rows
    tasks=[]
    # Two bounded CPU workers, distinct files. Only the main thread writes reports.
    for locale in ['en','uk']:
        group=[c for c in clips if c['locale']==locale]
        tasks.extend((locale,start,group[start:start+24]) for start in range(0,len(group),24))
    from concurrent.futures import ThreadPoolExecutor,as_completed
    with ThreadPoolExecutor(max_workers=2) as pool:
        for future in as_completed([pool.submit(transcribe_batch,task) for task in tasks]):
            results.extend(future.result())
            report={'version':1,'manifest_sha256':manifest_hash,'engine_sha256':engine_hash,'model_sha256':model_hash,'settings':CONFIG,
                    'complete':len(results)==len(manifest['clips']),'counts':dict(Counter(r['state'] for r in results)),
                    'note':'Independent ASR triage only; no text prompt, no automatic listening approval. Letters require human listening.','clips':results}
            temporary=out/'asr.json.new';temporary.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');temporary.replace(out/'asr.json')
            print(f'ASR: {len(results)}/{len(clips)}; {report["counts"]}',flush=True)
    print('Speech recognition report:',out/'asr.json',flush=True)

if __name__=='__main__':main()
