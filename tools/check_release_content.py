"""Offline source/content preflight; this is not APK or device verification."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
errors = []

def unique_object(pairs):
    value = {}
    for key, item in pairs:
        if key in value:
            errors.append('Duplicate JSON key: ' + key)
        value[key] = item
    return value

documents = {}
for path in (ROOT / 'data').rglob('*.json'):
    documents[path.relative_to(ROOT).as_posix()] = json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=unique_object)
locales = {locale: documents[f'data/localization/{locale}.json'] for locale in ['en', 'uk']}
if set(locales['en']) != set(locales['uk']):
    errors.append('EN/UK key sets differ')
for key in locales['en']:
    if not isinstance(locales['en'][key], str) or not isinstance(locales['uk'].get(key), str):
        errors.append('Invalid translated string: ' + key)
        continue
    if set(re.findall(r'\{[^}]+\}', locales['en'][key])) != set(re.findall(r'\{[^}]+\}', locales['uk'][key])):
        errors.append('Translation placeholders differ: ' + key)

resources = set()
for directory, extension in [('scripts', '*.gd'), ('scenes', '*.tscn'), ('data', '*.json')]:
    for path in (ROOT / directory).rglob(extension):
        source = path.read_text(encoding='utf-8')
        for resource in re.findall(r'"(res://[^"\n]+\.(?:tscn|gd|json|svg|png|wav|ttf|otf))"', source):
            resources.add(resource)
            if not (ROOT / resource[6:]).is_file():
                errors.append(f'Missing source resource: {resource} in {path.relative_to(ROOT)}')
        if directory == 'scripts':
            # Only complete literal keys; concatenated prefixes resolve at runtime.
            for key in re.findall(r'(?:LocalizationManager\.text|UiKit\.(?:label|paragraph|button))\(\s*"([A-Z][A-Z_0-9]*[A-Z0-9])"\s*[,)]', source):
                if key not in locales['en'] or key not in locales['uk']:
                    errors.append(f'Missing UI key: {key}')
            if re.search(r'\b(?:HTTPRequest|HTTPClient|WebSocketPeer|TCPServer|StreamPeerTCP|PacketPeerUDP|JavaScriptBridge)\b', source):
                errors.append(f'Network/browser API requires review: {path.relative_to(ROOT)}')

print(f'RELEASE CONTENT: {len(documents)} JSON documents, {len(locales["en"])} EN/UK keys, {len(resources)} concrete resource references; {len(errors)} errors')
print('No network/browser API classes found in runtime scripts.' if not errors else '\n'.join(errors))
raise SystemExit(bool(errors))
