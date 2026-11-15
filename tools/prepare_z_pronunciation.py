"""Whole US letter Z name plus an aligned alternative; never applies on import."""
import hashlib,json,wave
from pathlib import Path
import letter_aligned as rt
from voice_processing import normalize
ROOT=Path(__file__).resolve().parents[1]

def main():
 model=ROOT/'.tools/piper-voices/en_US-ljspeech-high.onnx'
 config=json.loads(model.with_suffix('.onnx.json').read_text(encoding='utf-8'))
 graph=rt.onnx.load(str(model));node=next(n for n in graph.graph.node if n.op_type=='Ceil')
 name=node.output[0];node.output[0]=name+'_raw'
 graph.graph.input.append(rt.onnx.helper.make_tensor_value_info('duration_mask',rt.onnx.TensorProto.FLOAT,[1,1,None]))
 at=list(graph.graph.node).index(node)
 graph.graph.node.insert(at+1,rt.onnx.helper.make_node('Mul',[name+'_raw','duration_mask'],['z_scaled']))
 graph.graph.node.insert(at+2,rt.onnx.helper.make_node('Ceil',['z_scaled'],[name]))
 graph.graph.output.append(rt.onnx.helper.make_tensor_value_info(name,rt.onnx.TensorProto.FLOAT,[1,1,None]))
 options=rt.ort.SessionOptions();options.intra_op_num_threads=2;options.inter_op_num_threads=1
 session=rt.ort.InferenceSession(graph.SerializeToString(),sess_options=options,providers=['CPUExecutionProvider'])
 records=[]
 for variant,context in [('z_whole_zee',False),('z_context_zee',True)]:
  target='zˈiː';prefix=rt.ipa('The letter','en-us')+' ' if context else ''
  suffix=' '+rt.ipa('is here.','en-us')+'.' if context else '.'
  phones=prefix+target+suffix;ids=[1,0];left=right=None;spans=[]
  for i,symbol in enumerate(phones):
   if i==len(prefix):left=len(ids)
   if i==len(prefix)+len(target):right=len(ids)
   start=len(ids);ids.extend(config['phoneme_id_map'][symbol]);ids.append(0)
   if len(prefix)<=i<len(prefix)+len(target):spans.append((symbol,start,len(ids)))
  ids.append(2)
  feeds={'input':rt.np.asarray([ids],dtype=rt.np.int64),'input_lengths':rt.np.asarray([len(ids)],dtype=rt.np.int64),'scales':rt.np.asarray([.4,1.05,.5],dtype=rt.np.float32),'duration_mask':rt.np.ones((1,1,len(ids)),dtype=rt.np.float32)}
  predicted=session.run([name],feeds)[0].reshape(-1)
  for symbol,start,end in spans:
   minimum=.14 if symbol=='z' else .28 if symbol=='i' else 0
   if minimum:feeds['duration_mask'][:,:,start:end]=max(1,float(rt.np.ceil(minimum*config['audio']['sample_rate']/256)/max(1,sum(predicted[start:end]))))
  output,durations=session.run([session.get_outputs()[0].name,name],feeds);audio=output.reshape(-1);durations=durations.reshape(-1)
  if context:
   first=max(0,int(sum(durations[:left])*256)-int(config['audio']['sample_rate']*.035))
   last=min(len(audio),int(sum(durations[:right])*256)+int(config['audio']['sample_rate']*.035));audio=audio[first:last]
  pcm=rt.np.clip(audio*32767/max(.01,float(rt.np.max(rt.np.abs(audio)))),-32767,32767).astype('<i2')
  path=ROOT/f'.local/qa/f01/candidates/{variant}__alph_en_25.wav'
  with wave.open(str(path),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(config['audio']['sample_rate']);f.writeframes(pcm.tobytes())
  normalize(path)
  records.append({'locale':'en','key':'ALPH_EN_25','variant':variant,'label':'Z · zee · '+('aligned comparison' if context else 'whole name'),
     'file':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'phonemes':target,
     'model':model.name,'model_sha256':hashlib.sha256(model.read_bytes()).hexdigest(),'method':'aligned name' if context else 'whole-name IPA',
     'listening_status':'unreviewed'})
  print(variant,flush=True)
 p=ROOT/'.local/qa/z-repair/candidates.json';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(records,indent=2)+'\n')

if __name__=='__main__':main()
