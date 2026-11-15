"""Extract isolated letter names using the model's own phoneme durations."""
from pathlib import Path
import ctypes,hashlib,json,os,sys,wave
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/python-audio'))
import numpy as np
import onnx
import onnxruntime as ort
ort.disable_telemetry_events()
SESSIONS={}
ESPEAK=None

def is_letter(key):
 import re
 return re.fullmatch(r'ALPH_(EN|UK)_[0-9]{2}',key) is not None

def ipa(text,locale="en"):
 global ESPEAK
 if ESPEAK is None:
  folder=ROOT/'.tools/piper';os.add_dll_directory(str(folder));ESPEAK=ctypes.CDLL(str(folder/'espeak-ng.dll'))
  ESPEAK.espeak_Initialize.argtypes=[ctypes.c_int,ctypes.c_int,ctypes.c_char_p,ctypes.c_int]
  if ESPEAK.espeak_Initialize(2,0,str(folder/'espeak-ng-data').encode(),0)<0:raise RuntimeError('eSpeak init')
  ESPEAK.espeak_SetVoiceByName.argtypes=[ctypes.c_char_p]

  ESPEAK.espeak_TextToPhonemes.argtypes=[ctypes.POINTER(ctypes.c_void_p),ctypes.c_int,ctypes.c_int];ESPEAK.espeak_TextToPhonemes.restype=ctypes.c_char_p
 if ESPEAK.espeak_SetVoiceByName(locale.encode())!=0:raise RuntimeError("eSpeak locale "+locale)
 buffer=ctypes.create_string_buffer(text.encode());pointer=ctypes.c_void_p(ctypes.addressof(buffer));result=ESPEAK.espeak_TextToPhonemes(ctypes.byref(pointer),1,2)
 return result.decode()

UK_LETTER_PHONEMES=['a','bɛ','ʋɛ','ɦɛ','ɡɛ','dɛ','ɛ','jɛ','ʒɛ','zɛ','ɪ','i','ji','jot','ka','ɛl','ɛm','ɛn','o','pɛ','ɛr','ɛs','tɛ','u','ɛf','xa','tsɛ','tʃɛ','ʃa','ʃtʃa','mjakˈɪj znˈak','ju','ja']
def ukrainian_letter_phonemes(key):return UK_LETTER_PHONEMES[int(key.rsplit('_',1)[1])]

def model(locale):
 if locale in SESSIONS:return SESSIONS[locale]
 name='en_GB-cori-high.onnx' if locale=='en' else 'uk_UA-tetiana-high.onnx'
 source=ROOT/'.tools/piper-voices'/name;config=json.loads(source.with_suffix('.onnx.json').read_text(encoding='utf-8'))
 graph=onnx.load(str(source));node=next(n for n in graph.graph.node if n.op_type=='Ceil')
 duration_name=node.output[0];raw_name=duration_name+'_raw';node.output[0]=raw_name
 graph.graph.input.append(onnx.helper.make_tensor_value_info('letter_duration_mask',onnx.TensorProto.FLOAT,[1,1,None]))
 index=list(graph.graph.node).index(node)
 graph.graph.node.insert(index+1,onnx.helper.make_node('Mul',[raw_name,'letter_duration_mask'],['letter_scaled_durations']))
 graph.graph.node.insert(index+2,onnx.helper.make_node('Ceil',['letter_scaled_durations'],[duration_name]))
 graph.graph.output.append(onnx.helper.make_tensor_value_info(duration_name,onnx.TensorProto.FLOAT,[1,1,None]))
 target=ROOT/'.local/letter-models'/name;target.parent.mkdir(parents=True,exist_ok=True);onnx.save(graph,str(target))
 options=ort.SessionOptions();options.intra_op_num_threads=2;options.inter_op_num_threads=1;options.log_severity_level=3
 session=ort.InferenceSession(str(target),sess_options=options,providers=['CPUExecutionProvider'])
 SESSIONS[locale]=(session,config,duration_name);return SESSIONS[locale]

def render(entry,locale,path):
 session,config,duration_name=model(locale)
 name=entry['text'].rstrip('.').strip().replace('’',"'")
 prefix=ipa('The letter')+' ' if locale=='en' else ipa('Це літера','uk')+' '
 target=ipa(name+'.') if locale=='en' else ukrainian_letter_phonemes(entry['key'])
 if locale=='en' and name=='X':target=target.replace('ɛ','ɛː')
 suffix=' '+ipa('is here.')+'.' if locale=='en' else ' '+ipa('в абетці.','uk')+'.'
 symbols=list(prefix+target+suffix);start_symbol=len(prefix);end_symbol=start_symbol+len(target)
 ids=[1,0];start=end=None;vowels=[];symbol_spans=[]
 for index,symbol in enumerate(symbols):
  if index==start_symbol:start=len(ids)
  if index==end_symbol:end=len(ids)
  if symbol not in config['phoneme_id_map']:raise ValueError(f'Unknown phoneme{symbol!r} in{entry["key"]}')
  first=len(ids);ids.extend(config['phoneme_id_map'][symbol]);ids.append(0)
  if start_symbol<=index<end_symbol:symbol_spans.append((symbol,first,len(ids)))
  if start_symbol<=index<end_symbol and symbol in 'aeiouæɑɒɔəɛɜɪʊʌ':vowels.append((first,len(ids)-1))
 ids.append(2)
 feeds={'input':np.asarray([ids],dtype=np.int64),'input_lengths':np.asarray([len(ids)],dtype=np.int64),'scales':np.asarray([.25,1.12,0.0],dtype=np.float32)}
 if config.get('num_speakers',1)>1:feeds['sid']=np.asarray([2],dtype=np.int64)
 feeds['letter_duration_mask']=np.ones((1,1,len(ids)),dtype=np.float32)
 predicted=session.run([duration_name],feeds)[0].reshape(-1)
 desired_frames=np.ceil(.38*config['audio']['sample_rate']/256)
 boost=max(1.0,float(desired_frames/max(1,sum(predicted[start:end]))))
 feeds['letter_duration_mask'][:,:,start:end]=boost
 for first,last in vowels:
  # A short letter still needs an audible vowel, particularly F/S/X.
  vowel_frames=max(1,sum(predicted[first:last]));minimum=np.ceil(.18*config['audio']['sample_rate']/256)
  feeds['letter_duration_mask'][:,:,first:last]=max(boost,float(minimum/vowel_frames))


 output,durations=session.run([session.get_outputs()[0].name,duration_name],feeds)
 audio=output.reshape(-1);durations=durations.reshape(-1)
 hop=len(audio)/sum(durations)
 if abs(hop-256)>0.01:raise ValueError(f'Unexpected decoder hop{hop}')
 left=int(sum(durations[:start])*hop);right=int(sum(durations[:end])*hop)
 # Duration boundaries include the inter-phoneme blank; keep a small quiet margin.
 rate=config['audio']['sample_rate'];left=max(0,left-int(rate*.015));right=min(len(audio),right+int(rate*.025))
 isolated=audio[left:right]
 seconds=len(isolated)/rate
 if not .20<=seconds<=1.65:raise ValueError(f'{entry["key"]}: duration{seconds:.3f}s outside bounds')
 if float(np.sqrt(np.mean(isolated**2)))<.003:raise ValueError(f'{entry["key"]}: weak extracted letter')
 # Piper C++ normalizes each utterance before PCM conversion.
 gain=32767/max(.01,float(np.max(np.abs(audio))));pcm=np.clip(isolated*gain,-32767,32767).astype('<i2')
 path.parent.mkdir(parents=True,exist_ok=True)
 with wave.open(str(path),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(pcm.tobytes())
 return {'method':'model phoneme-duration alignment; prefix removed','synthesis_text':('The letter ' if locale=='en' else 'Це літера ')+name+(' is here.' if locale=='en' else ' '+ipa('в абетці.','uk')+'.'),'target_phonemes':target,'source_start_seconds':round(left/rate,4),'source_end_seconds':round(right/rate,4),'duration_frames':int(sum(durations[start:end])),'duration_boost':round(boost,4),'inference_scales':[.25,1.12,0.0],'tokens':[{'symbol':symbol,'before':predicted[first:last].tolist(),'after':durations[first:last].tolist()} for symbol,first,last in symbol_spans]}
