"""Create original, softly struck modal-bar tones. No downloads or external samples."""
from pathlib import Path
import json
import math
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/audio/instrument'
OUT.mkdir(parents=True, exist_ok=True)
notes = [('C', 523.251), ('D', 587.330), ('E', 659.255), ('F', 698.456),
         ('G', 783.991), ('A', 880.000), ('B', 987.767), ('C2', 1046.502)]
for name, frequency in notes:
    rate = 44100
    samples = []
    for frame in range(int(rate * 1.7)):
        t = frame / rate
        attack = 1 - math.exp(-t / 0.0025)
        fade = min(1, (1.7 - t) / 0.06)
        value = sum(gain * math.exp(-t / decay) * math.sin(2 * math.pi * frequency * ratio * t)
                    for ratio, gain, decay in [(1, .72, .42), (3.99, .18, .12), (9.1, .035, .045)])
        samples.append(int(32767 * .68 * attack * fade * value))
    with wave.open(str(OUT / (name.lower() + '.wav')), 'wb') as wav:
        wav.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        wav.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
for locale, values in {
    'en': {'XYLO_TITLE': 'Magic xylophone', 'XYLO_HINT': 'Tap the rainbow keys. Make your own music!',
           'XYLO_VOLUME': 'Instrument volume: Grown-ups → Sound effects'},
    'uk': {'XYLO_TITLE': 'Чарівний ксилофон', 'XYLO_HINT': 'Торкайся веселкових клавіш. Створюй свою музику!',
           'XYLO_VOLUME': 'Гучність інструмента: Для дорослих → Звукові ефекти'},
}.items():
    path = ROOT / f'data/localization/{locale}.json'
    data = json.loads(path.read_text(encoding='utf-8'))
    data.update(values)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
colors = ['d85e63','e9a050','e8c35b','80b280','67adba','719dcb','9980bc','d893b6']
bars = ''.join(f'<rect x="{12+i*22}" y="{12+i*4}" width="19" height="{160-i*8}" rx="7" fill="#{c}" stroke="#456255" stroke-width="2"/>' for i,c in enumerate(colors))
(ROOT/'assets/ui/xylophone.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 190"><path d="M10 60H190M10 130H190" stroke="#aa8058" stroke-width="12"/>{bars}</svg>\n', encoding='utf-8')
print('XYLOPHONE: eight original mono PCM notes and localized UI prepared.')
