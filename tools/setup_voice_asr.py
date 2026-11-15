"""Install/verify the pinned PC-only recognizer; no application dependency."""
import argparse,hashlib,json
from pathlib import Path
import urllib.request
import zipfile

ROOT=Path(__file__).resolve().parents[1]

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--verify-only',action='store_true');args=parser.parse_args()
 config=json.loads((ROOT/'tools/voice-asr-toolchain.json').read_text(encoding='utf-8'))
 out=ROOT/'.tools/whisper-cpp';out.mkdir(parents=True,exist_ok=True)
 for entry in config['files']:
  path=out/entry['file']
  if not path.exists():
   if args.verify_only:raise FileNotFoundError(path)
   request=urllib.request.Request(entry['url'],headers={'User-Agent':'LittleWonderWorld-local-voice-audit'})
   with urllib.request.urlopen(request,timeout=60) as response,path.with_suffix(path.suffix+'.part').open('wb') as target:
    while data:=response.read(1024*1024):target.write(data)
   path.with_suffix(path.suffix+'.part').replace(path)
  if hashlib.sha256(path.read_bytes()).hexdigest()!=entry['sha256']:raise ValueError('Toolchain hash mismatch: '+path.name)
 if not args.verify_only:
  with zipfile.ZipFile(out/'whisper-bin-x64.zip') as archive:
   for item in archive.infolist():
    if not (out/item.filename).resolve().is_relative_to(out.resolve()):raise ValueError('Unsafe archive member')
   archive.extractall(out)
 if not (out/'Release/whisper-cli.exe').exists():raise FileNotFoundError('Run setup without --verify-only to extract the binary')
 print('ASR TOOLCHAIN: pinned Windows CPU release/model SHA256 verified; PC-only, ignored by Git and Android export.')

if __name__=='__main__':main()
