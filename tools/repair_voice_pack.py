"""Prepare/apply a reversible speech repair; listening approval is separate.

Existing models only. Never alters selected recordings or application text.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import wave
import letter_aligned as runtime
from voice_processing import normalize
import audio_metrics

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '.local/qa/voice-repair-028'
EN_WORDS = {'COLOR_WORD_RED', 'FOOD_WORD_BREAD', 'COUNT_NUMBER_5'}


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def selected(pack):
    protected = set(read(ROOT/'tools/voice_clip_overrides.json')['clips'])
    # The owner explicitly kept these Ukrainian words, including their reuse.
    keep = {c['text'].strip().rstrip('.').casefold() for c in pack['clips']
            if c['locale']=='uk' and c['key'] in ['WORD_DUCK','WORD_SHEEP']}
    for c in pack['clips']:
        if c['locale']=='uk' and c['text'].strip().rstrip('.').casefold() in keep:
            protected.add('uk:'+c['key'])
    return protected


def whole_letter(clip, target):
    locale = clip['locale']
    session, config, durations_name = runtime.model(locale)
    phones = (runtime.ukrainian_letter_phonemes(clip['key']) if locale=='uk' else 'zˈɛd')+'.'
    ids=[1,0];spans=[]
    for symbol in phones:
        start=len(ids);ids.extend(config['phoneme_id_map'][symbol]);ids.append(0)
        spans.append((symbol,start,len(ids)))
    ids.append(2)
    mask=runtime.np.ones((1,1,len(ids)),dtype=runtime.np.float32)
    feeds={'input':runtime.np.asarray([ids],dtype=runtime.np.int64),
           'input_lengths':runtime.np.asarray([len(ids)],dtype=runtime.np.int64),
           'scales':runtime.np.asarray([.35,1.05,.35],dtype=runtime.np.float32),
           'letter_duration_mask':mask}
    predicted=session.run([durations_name],feeds)[0].reshape(-1)
    for symbol,start,end in spans:
        if symbol in 'aeiouɑɐɛɪɔʊɨɜə':minimum=.19
        elif symbol.isalpha():minimum=.065
        else:continue
        frames=runtime.np.ceil(minimum*config['audio']['sample_rate']/256)
        mask[:,:,start:end]=max(1,float(frames/max(1,sum(predicted[start:end]))))
    output=session.run([session.get_outputs()[0].name],feeds)[0].reshape(-1)
    pcm=runtime.np.clip(output*32767/max(.01,float(runtime.np.max(runtime.np.abs(output)))),-32767,32767).astype('<i2')
    with wave.open(str(target),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(config['audio']['sample_rate']);f.writeframes(pcm.tobytes())
    return phones


def prepare():
    OUT.mkdir(parents=True,exist_ok=True)
    pack=read(ROOT/'assets/audio/voice/manifest.json');protected=selected(pack)
    targets=[c for c in pack['clips'] if c['locale']+':'+c['key'] not in protected and
             (c['locale']=='uk' or c['key'] in EN_WORDS or
              (c['locale']=='en' and c['key'].startswith('WORLD_BODY_') and c['key'].endswith('_WORD')) or
              c['key']=='ALPH_EN_25')]
    result={'version':1,'source_manifest_sha256':digest(ROOT/'assets/audio/voice/manifest.json'),
            'protected':{k:digest(ROOT/next(c['file'] for c in pack['clips'] if c['locale']+':'+c['key']==k)) for k in protected},
            'listening_status':'unreviewed','clips':[]}
    for locale,model_name in [('uk','uk_UA-tetiana-high.onnx'),('en','en_US-ljspeech-high.onnx')]:
        model=ROOT/'.tools/piper-voices'/model_name
        model_hash=digest(model)
        current=[c for c in targets if c['locale']==locale];jobs=[]
        folder=OUT/locale;folder.mkdir(exist_ok=True)
        for clip in current:
            if runtime.is_letter(clip['key']):continue
            jobs.append({'text':clip['text'],'output_file':str(folder/(clip['key'].lower()+'.wav'))})
        command=[str(ROOT/'.tools/piper/piper.exe'),'--model',str(model),'--json-input',
                 '--length_scale','1.05','--noise_scale','.667','--noise_w','.8','--sentence_silence','.15']
        print(f'Preparing {locale}: {len(jobs)} whole text clips',flush=True)
        process=subprocess.run(command,input=('\n'.join(json.dumps(j,ensure_ascii=False) for j in jobs)+'\n').encode(),
                               cwd=ROOT/'.tools/piper',capture_output=True)
        (OUT/(locale+'.log')).write_bytes(process.stderr+process.stdout)
        if process.returncode:raise RuntimeError('Synthesis failed; inspect '+locale+'.log')
        for clip in current:
            target=folder/(clip['key'].lower()+'.wav');phones=None
            if runtime.is_letter(clip['key']):phones=whole_letter(clip,target)
            normalize(target)
            with wave.open(str(target),'rb') as f:seconds=round(f.getnframes()/f.getframerate(),3)
            if not .15<=seconds<=8:raise ValueError('Duration: '+clip['key'])
            metrics=audio_metrics.measure(target) if phones else {}
            if phones and metrics['review']:raise ValueError('Weak voiced letter: '+clip['key'])
            result['clips'].append({'locale':locale,'key':clip['key'],'file':clip['file'],
                'candidate':target.relative_to(ROOT).as_posix(),'text':clip['text'],
                'old_sha256':clip['sha256'],'sha256':digest(target),'seconds':seconds,
                'repair':{'method':'whole-letter IPA; no extraction' if phones else 'standard model text frontend',
                          'model':('en_GB-cori-high.onnx' if locale=='en' and phones else model_name),
                          'model_sha256':digest(ROOT/'.tools/piper-voices/en_GB-cori-high.onnx') if locale=='en' and phones else model_hash,
                          'phonemes':phones,'listening_status':'unreviewed','signal':metrics}})
        print(f'Prepared {locale}: {len(current)} clips',flush=True)
    (OUT/'repair.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f"Ready: {len(result['clips'])} replacements; runtime unchanged",flush=True)


def apply():
    report=read(OUT/'repair.json');manifest_path=ROOT/'assets/audio/voice/manifest.json'
    if digest(manifest_path)!=report['source_manifest_sha256']:raise ValueError('Pack changed; prepare again')
    pack=read(manifest_path);by_id={c['locale']+':'+c['key']:c for c in pack['clips']}
    for key,sha in report['protected'].items():
        if digest(ROOT/by_id[key]['file'])!=sha:raise ValueError('Protected clip changed: '+key)
    for c in report['clips']:
        if digest(ROOT/c['file'])!=c['old_sha256'] or digest(ROOT/c['candidate'])!=c['sha256']:
            raise ValueError('Stale replacement: '+c['key'])
    backup=OUT/'before'
    if backup.exists():raise ValueError('Repair already applied; retain backup')
    backup.mkdir();shutil.copy2(manifest_path,backup/'manifest.json')
    pins={'version':1,'note':'Repair recordings protected from accidental routine regeneration; human listening remains pending.','clips':{}}
    for c in report['clips']:
        old=by_id[c['locale']+':'+c['key']];dest=backup/c['locale']/Path(c['file']).name;dest.parent.mkdir(exist_ok=True)
        shutil.copy2(ROOT/c['file'],dest);shutil.copy2(ROOT/c['candidate'],ROOT/c['file'])
        for obsolete in ['extraction','synthesis_text','source_phonemes','voice_override']:old.pop(obsolete,None)
        old.update(seconds=c['seconds'],sha256=c['sha256'],voice_repair=c['repair'])
        pins['clips'][c['locale']+':'+c['key']]={'sha256':c['sha256'],'variant':'repair028','listening_status':'unreviewed'}
    for key,sha in report['protected'].items():
        if digest(ROOT/by_id[key]['file'])!=sha:raise ValueError('Protected clip was altered: '+key)
    manifest_path.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (ROOT/'tools/voice_repair_pins.json').write_text(json.dumps(pins,indent=2)+'\n',encoding='utf-8')
    print(f"Applied {len(report['clips'])} replacements; {len(report['protected'])} selected clips unchanged; listening pending",flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--apply',action='store_true');args=parser.parse_args()
    apply() if args.apply else prepare()
