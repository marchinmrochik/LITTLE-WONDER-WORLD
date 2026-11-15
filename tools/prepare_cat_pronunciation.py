"""Whole-word /kaet/ synthesis candidates; no context extraction or splicing."""
import hashlib,json,wave
from pathlib import Path
import letter_aligned as runtime
from voice_processing import normalize

ROOT=Path(__file__).resolve().parents[1]
PHONEMES='kˈæt.'

def main():
    model=ROOT/'.tools/piper-voices/en_US-ljspeech-high.onnx'
    config=json.loads(model.with_suffix('.onnx.json').read_text(encoding='utf-8'))
    # The US phonemizer gives /ae/; the model's stored generic "en" frontend
    # gives /a/. Select the intended US phonemes explicitly for these samples.
    if runtime.ipa('cat.','en-us')+'.'!=PHONEMES:
        raise ValueError('Unexpected US phonemes; review before synthesis')
    ids=[1,0];spans={}
    for symbol in PHONEMES:
        first=len(ids);ids.extend(config['phoneme_id_map'][symbol]);ids.append(0)
        spans[symbol]=(first,len(ids))
    ids.append(2)
    options=runtime.ort.SessionOptions();options.intra_op_num_threads=2;options.inter_op_num_threads=1
    graph=runtime.onnx.load(str(model));node=next(n for n in graph.graph.node if n.op_type=='Ceil')
    duration_name=node.output[0];raw_name=duration_name+'_raw';node.output[0]=raw_name
    graph.graph.input.append(runtime.onnx.helper.make_tensor_value_info('duration_mask',runtime.onnx.TensorProto.FLOAT,[1,1,None]))
    index=list(graph.graph.node).index(node)
    graph.graph.node.insert(index+1,runtime.onnx.helper.make_node('Mul',[raw_name,'duration_mask'],['word_scaled_durations']))
    graph.graph.node.insert(index+2,runtime.onnx.helper.make_node('Ceil',['word_scaled_durations'],[duration_name]))
    graph.graph.output.append(runtime.onnx.helper.make_tensor_value_info(duration_name,runtime.onnx.TensorProto.FLOAT,[1,1,None]))
    derived=ROOT/'.local/word-models/cat-ljspeech.onnx';derived.parent.mkdir(parents=True,exist_ok=True);runtime.onnx.save(graph,str(derived))
    session=runtime.ort.InferenceSession(str(derived),sess_options=options,providers=['CPUExecutionProvider'])
    path=ROOT/'.local/qa/f01/comparison.json';comparison=json.loads(path.read_text(encoding='utf-8'))
    rejected=[s for s in comparison['samples'] if s['locale']=='en' and s['key']=='WORD_CAT']
    archive=ROOT/'.local/qa/f01/cat-rejected-candidates.json'
    old=json.loads(archive.read_text(encoding='utf-8')) if archive.exists() else []
    known={s['sha256'] for s in old};old.extend(s for s in rejected if s['sha256'] not in known)
    archive.write_text(json.dumps(old,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    comparison['samples']=[s for s in comparison['samples'] if not (s['locale']=='en' and s['key']=='WORD_CAT')]
    for variant,label,phones in [('cat_direct_model','Cat · прямое произнесение · вариант 1','kˈat.'),
                                ('cat_direct_us','Cat · прямое произнесение · вариант 2','kˈæt.')]:
        ids=[1,0];spans={}
        for symbol in phones:
            first=len(ids);ids.extend(config['phoneme_id_map'][symbol]);ids.append(0);spans[symbol]=(first,len(ids))
        ids.append(2)
        feeds={'input':runtime.np.asarray([ids],dtype=runtime.np.int64),'input_lengths':runtime.np.asarray([len(ids)],dtype=runtime.np.int64),
               'scales':runtime.np.asarray([.25,1.0,.0],dtype=runtime.np.float32),'duration_mask':runtime.np.ones((1,1,len(ids)),dtype=runtime.np.float32)}
        predicted=session.run([duration_name],feeds)[0].reshape(-1)
        minimums={'k':.075,'a' if 'a' in phones else 'æ':.21,'t':.085}
        for symbol,seconds in minimums.items():
            first,last=spans[symbol];frames=sum(predicted[first:last]);minimum=runtime.np.ceil(seconds*config['audio']['sample_rate']/256)
            feeds['duration_mask'][:,:,first:last]=max(1.0,float(minimum/max(1,frames)))
        output,durations=session.run([session.get_outputs()[0].name,duration_name],feeds);audio=output.reshape(-1)
        pcm=runtime.np.clip(audio*32767/max(.01,float(runtime.np.max(runtime.np.abs(audio)))),-32767,32767).astype('<i2')
        target=ROOT/f'.local/qa/f01/candidates/{variant}__word_cat.wav'
        with wave.open(str(target),'wb') as f:
            f.setnchannels(1);f.setsampwidth(2);f.setframerate(config['audio']['sample_rate']);f.writeframes(pcm.tobytes())
        normalize(target)
        with wave.open(str(target),'rb') as f:seconds=round(f.getnframes()/f.getframerate(),3)
        comparison['samples'].append({'locale':'en','key':'WORD_CAT','variant':variant,'label':label,
            'file':target.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'seconds':seconds,
            'phonemes':phones,'phoneme_ids':ids,'method':'whole-word ONNX synthesis with minimum phoneme durations; human listening pending','minimum_phoneme_seconds':minimums,
            'model':model.name,'model_sha256':hashlib.sha256(model.read_bytes()).hexdigest(),'scales':[.25,1.0,.0]})
        print(variant,seconds,flush=True)
    comparison['manifest_sha256']=hashlib.sha256((ROOT/'assets/audio/voice/manifest.json').read_bytes()).hexdigest()
    path.write_text(json.dumps(comparison,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
