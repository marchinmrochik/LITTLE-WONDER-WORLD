"""Validate the shipped instrument signal, tuning, envelope and worst-case mix."""
from pathlib import Path
import array
import math
import wave

root = Path(__file__).resolve().parents[1]
peaks = []
for name, frequency in [('c',523.251),('d',587.330),('e',659.255),('f',698.456),('g',783.991),('a',880),('b',987.767),('c2',1046.502)]:
    with wave.open(str(root/f'assets/audio/instrument/{name}.wav'),'rb') as wav:
        assert (wav.getnchannels(),wav.getsampwidth(),wav.getframerate())==(1,2,44100)
        samples=array.array('h',wav.readframes(wav.getnframes()))
    assert len(samples)==74970 and samples[0]==0 and abs(samples[-1])<=1
    peak=max(abs(x) for x in samples)/32768
    assert .2 < peak < .64
    peaks.append(peak)
    # Correlation distinguishes each intended fundamental from adjacent semitones.
    def strength(hz):
        real=sum(x*math.cos(2*math.pi*hz*i/44100) for i,x in enumerate(samples[:17640]))
        imag=sum(x*math.sin(2*math.pi*hz*i/44100) for i,x in enumerate(samples[:17640]))
        return math.hypot(real,imag)
    assert strength(frequency)>10*max(strength(frequency*2**(-1/12)),strength(frequency*2**(1/12)))
assert max(peaks)*.095*16 < 1, 'Sixteen coincident peaks must stay below clipping'
print(f'INSTRUMENT: eight tuned PCM notes, faded edges, sixteen-voice bound {max(peaks)*.095*16:.3f} < 1; PASS')
