"""Protect selected clips and explicit repair pins during routine synthesis.
Repair pins are not human listening approvals.
"""
import hashlib,json

def preserve_approved(root,jobs,manifest):
    path=root/'tools/voice_clip_overrides.json'
    approved=json.loads(path.read_text(encoding='utf-8'))['clips'] if path.exists() else {}
    repairs=root/'tools/voice_repair_pins.json'
    if repairs.exists():
        pinned=json.loads(repairs.read_text(encoding='utf-8'))['clips']
        approved={**pinned,**approved}
    preserved=[];filtered={}
    for locale,entries in jobs.items():
        filtered[locale]=[]
        for entry in entries:
            override=approved.get(locale+':'+entry['key'])
            if not override:
                filtered[locale].append(entry);continue
            clip=next((c for c in manifest['clips'] if c['locale']==locale and c['key']==entry['key']),None)
            if not clip or clip['file']!=entry['file'] or clip['text']!=entry['text']:
                raise ValueError('Protected cue changed; repeat listening review: '+entry['key'])
            actual=hashlib.sha256((root/entry['file']).read_bytes()).hexdigest()
            if actual!=override['sha256'] or clip['sha256']!=actual:
                raise ValueError('Protected audio changed; repeat listening review: '+entry['key'])
            preserved.append(clip)
    return filtered,preserved
