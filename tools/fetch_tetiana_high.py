"""Fetch pinned development-only Ukrainian candidate with upstream SHA verification."""
from pathlib import Path
import urllib.request,json,hashlib,sys
R=Path(__file__).resolve().parents[1];repo='RomanStasyshyn/uk_UA-tetiana-high';PIN='42be6e3f72a7c6042271236b94e48edffd1f0c63'
def get(url):return urllib.request.urlopen(url,timeout=90).read()
meta=json.loads(get('https://huggingface.co/api/models/'+repo+'/revision/'+PIN+'?blobs=true'))
print(json.dumps({k:meta.get(k) for k in ['sha','cardData','siblings']},ensure_ascii=False,indent=2),flush=True)
if '--download' in sys.argv:
 revision=meta['sha'];folder=R/'.tools/piper-voices';folder.mkdir(parents=True,exist_ok=True)
 for source,target in [('tetiana.onnx','uk_UA-tetiana-high.onnx'),('tetiana.onnx.json','uk_UA-tetiana-high.onnx.json')]:
  entry=next(x for x in meta['siblings'] if x['rfilename']==source);expected=entry.get('lfs',{}).get('sha256')
  payload=get('https://huggingface.co/'+repo+'/resolve/'+revision+'/'+source)
  actual=hashlib.sha256(payload).hexdigest()
  if expected and actual!=expected:raise ValueError('Upstream model SHA mismatch')
  (folder/target).write_bytes(payload);print(target,len(payload),actual,flush=True)
 (R/'.local/tetiana-high-source.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
 card=get('https://huggingface.co/'+repo+'/raw/'+revision+'/README.md')
 (R/'assets/licenses/tetiana-high-MODEL_CARD.md').write_bytes(card)
