"""Verify bundled speech against the generated manifest without network access."""
from pathlib import Path
import array
import hashlib
import json
import math
import wave

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "assets/audio/voice/manifest.json").read_text(encoding="utf-8"))
jobs = json.loads((root / "data/game_content/voice_jobs.json").read_text(encoding="utf-8"))
assert len(manifest["clips"]) == sum(len(value) for value in jobs.values()) >= 52
durations = []
total_bytes = 0
for entry in manifest["clips"]:
    path = root / entry["file"]
    payload = path.read_bytes()
    assert hashlib.sha256(payload).hexdigest() == entry["sha256"], path
    total_bytes += len(payload)
    with wave.open(str(path), "rb") as clip:
        assert clip.getnchannels() == 1 and clip.getsampwidth() == 2, path
        assert clip.getframerate() in (16000, 22050), path
        seconds = clip.getnframes() / clip.getframerate()
        assert 0.15 <= seconds <= 8, path
        samples = array.array("h", clip.readframes(clip.getnframes()))
        peak = max(abs(value) for value in samples)
        rms = math.sqrt(sum(value*value for value in samples) / len(samples))
        assert 200 < peak <= 20317 and rms > 100, path
        assert samples[0] == 0 and samples[-1] == 0, path
        durations.append(seconds)
print(f'VOICE PACK: {len(manifest["clips"])} verified non-silent PCM clips, {total_bytes:,} bytes, durations {min(durations):.2f}-{max(durations):.2f}s.')
print("Format, checksums and signal bounds verified. Pronunciation/voice preference still requires listening review.")
