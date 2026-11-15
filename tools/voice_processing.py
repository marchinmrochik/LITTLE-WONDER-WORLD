"""Shared finite-voice PCM processing; does not perform synthesis on import."""
import array, math, sys, wave

def normalize(path):
    with wave.open(str(path), "rb") as source:
        if source.getnchannels() != 1 or source.getsampwidth() != 2:
            raise ValueError(f"Unexpected voice format: {path}")
        rate = source.getframerate()
        samples = array.array("h", source.readframes(source.getnframes()))
    if sys.byteorder != "little":
        samples.byteswap()
    active = [i for i, value in enumerate(samples) if abs(value) > 80]
    if not active:
        raise ValueError(f"Silent voice: {path}")
    start = max(0, active[0] - int(rate * 0.08))
    end = min(len(samples), active[-1] + int(rate * 0.16))
    samples = samples[start:end]
    # Gentle treble smoothing, retaining intelligibility without sharp peaks.
    alpha = 1.0 - math.exp(-2.0 * math.pi * 4500 / rate)
    previous = 0.0
    for i, value in enumerate(samples):
        previous += alpha * (value - previous)
        samples[i] = round(previous)
    peak = max(abs(value) for value in samples)
    gain = min(4.0, 0.46 * 32767 / peak)
    fade = max(1, int(rate * 0.008))
    for i, value in enumerate(samples):
        envelope = min(1.0, i / fade, (len(samples)-1-i) / fade)
        samples[i] = max(-32767, min(32767, round(value * gain * envelope)))
    if sys.byteorder != "little":
        samples.byteswap()
    with wave.open(str(path), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(rate)
        target.writeframes(samples.tobytes())

