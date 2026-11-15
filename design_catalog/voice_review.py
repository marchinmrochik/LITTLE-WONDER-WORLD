"""Local listening decisions, bound to the exact recording hash."""
from pathlib import Path
from datetime import datetime, timezone
from catalog import read_json, write_json, safe, digest

VERDICTS = ['unreviewed','good','bad','unclear']

def snapshot(root):
    audit=read_json(root/'.local/qa/f01/audit.json')
    if not audit:raise ValueError('Сначала запустите python tools/audit_voice_content.py')
    comparison=read_json(root/'.local/qa/f01/comparison.json',{'variants':[],'samples':[]})
    decisions=read_json(root/'.local/qa/f01/listening-decisions.json')
    current=digest((root/'assets/audio/voice/manifest.json').read_bytes())==audit['manifest_sha256']
    if comparison.get('samples') and comparison.get('manifest_sha256')!=audit['manifest_sha256']:
        comparison={'variants':[],'samples':[],'stale':True}
    asr=read_json(root/'.local/qa/voice-asr/asr.json',{'clips':[]})
    by_id={r['id']:r for r in asr.get('clips',[])}
    asr_current=asr.get('manifest_sha256')==audit['manifest_sha256'] and current
    for row in audit['clips']:
        result=by_id.get(row['id'],{})
        row['asr']=result if asr_current and result.get('sha256')==row['sha256'] else {'state':'not_checked','transcript':'','stale':bool(result)}
        decision=decisions.get(row['id'],{})
        candidate_hashes={s['variant']:s['sha256'] for s in comparison['samples'] if s['locale']==row['locale'] and s['key']==row['key']}
        candidate_current=not decision.get('preferred') or decision.get('preferred')=='current' or decision.get('candidate_hashes')==candidate_hashes
        row['review']=decision if decision.get('sha256')==row['sha256'] and current and candidate_current else {'verdict':'unreviewed','note':'','stale':bool(decision)}
    return {**audit,'current':current,'comparison':comparison,'asr_summary':{'current':asr_current,'complete':asr.get('complete',False) if asr_current else False,'processed':len(by_id) if asr_current else 0,'counts':asr.get('counts',{}) if asr_current else {}}}

def decide(root,identity,sha256,verdict,note='',heard=False,preferred=''):
    data=snapshot(root);row=next((x for x in data['clips'] if x['id']==identity),None)
    if not row or not data['current'] or sha256!=row['sha256']:raise ValueError('Запись изменилась. Обновите очередь и прослушайте снова.')
    if digest(safe(root,row['file']).read_bytes())!=sha256:raise ValueError('Файл изменился. Повторите аудит.')
    if verdict not in VERDICTS or not isinstance(note,str) or len(note)>4000:raise ValueError('Некорректное решение')
    if verdict!='unreviewed' and heard is not True:raise ValueError('Подтвердите, что прослушали запись')
    candidates=[s for s in data['comparison']['samples'] if s['locale']==row['locale'] and s['key']==row['key']]
    valid=['current']+[s['variant'] for s in candidates]
    if preferred and preferred not in valid:raise ValueError('Неизвестный вариант голоса')
    if preferred and heard is not True:raise ValueError('Сначала прослушайте варианты')
    if preferred and preferred!='current':candidate(root,preferred,row['locale'],row['key'])
    decision={'sha256':sha256,'verdict':verdict,'note':note,'heard':heard,'preferred':preferred,'recorded_at':datetime.now(timezone.utc).isoformat(),
              'candidate_hashes':{s['variant']:s['sha256'] for s in candidates}}
    path=root/'.local/qa/f01/listening-decisions.json';records=read_json(path);records[identity]=decision;write_json(path,records)
    return decision

def candidate(root,variant,locale,key):
    data=read_json(root/'.local/qa/f01/comparison.json')
    sample=next((s for s in data.get('samples',[]) if s['variant']==variant and s['locale']==locale and s['key']==key),None)
    if not sample:raise ValueError('Вариант не найден')
    path=safe(root,sample['file'])
    if not path.is_relative_to((root/'.local/qa/f01/candidates').resolve()):raise ValueError('Неверный путь варианта')
    if digest(path.read_bytes())!=sample['sha256']:raise ValueError('Вариант изменился. Повторите подготовку.')
    return path
