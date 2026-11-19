"""Read-only pre-publish guard for tracked and non-ignored untracked files."""
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
PRIVATE_TOP={'.local','.tools','.godot','.aws','.ssh','build','tablet-backups','artwork-exports'}
PRIVATE_SUFFIX={'.apk','.aab','.idsig','.keystore','.jks','.key','.pem','.p12','.pfx','.onnx','.gguf','.safetensors','.pt','.pth','.tflite','.bak','.dmp','.hprof'}
SECRETS=[re.compile(r'^-----BEGIN(?: [A-Z]+)* PRIVATE KEY-----',re.M),
         re.compile(r'\bgh[pousr]_[A-Za-z0-9]{36,}\b'),re.compile(r'\bgithub_pat_[A-Za-z0-9_]{50,}\b'),
         re.compile(r'\bsk-(?:proj-)?[A-Za-z0-9_-]{40,}\b')]

def path_problem(name):
    path=Path(name);parts=path.parts;base=path.name.lower()
    if parts and parts[0] in PRIVATE_TOP:return 'local/private directory'
    if path.suffix.lower() in PRIVATE_SUFFIX:return 'build, model, backup or signing file'
    if base.startswith('ggml-') and base.endswith('.bin'):return 'speech recognition model'
    if (base=='.env' or base.startswith('.env.')) and base not in ['.env.example','.env.sample','.env.template']:return 'environment secrets'
    if base in ['credentials.json','secrets.json','secrets.yaml','secrets.yml','export_credentials.cfg','adbkey','adbkey.pub']:return 'credentials'
    return ''

def main():
    def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT).decode('utf-8').split('\0')
    files=sorted(set(filter(None,git('ls-files','-z','--cached','--others','--exclude-standard'))))
    ignored=list(filter(None,git('ls-files','-z','-ci','--exclude-standard')))
    problems=[(f,'already tracked despite .gitignore') for f in ignored if (ROOT/f).exists()]
    for name in files:
        path=ROOT/name
        if not path.exists() and not path.is_symlink():continue
        issue=path_problem(name)
        if issue:problems.append((name,issue));continue
        if not path.is_file():continue
        if path.stat().st_size>25*1024*1024:problems.append((name,'individual file exceeds25MiB; review before publishing'))
        if path.stat().st_size<=2*1024*1024:
            data=path.read_bytes()
            if b'\0' not in data:
                text=data.decode('utf-8',errors='replace')
                if any(pattern.search(text) for pattern in SECRETS):problems.append((name,'possible embedded credential; inspect locally'))
    print(f'GIT PUBLISH: {len(files)} candidate files; {len(problems)} blockers')
    # Never print matched secrets or file contents.
    for path,reason in problems:print(path+': '+reason)
    print('Read-only heuristic check; also review the diff before committing.')
    return bool(problems)

if __name__=='__main__':sys.exit(main())
