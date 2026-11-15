"""Generate finite local WAV assets. Piper/models remain development-only tools."""
from pathlib import Path
import array
import argparse
import hashlib
import json
import math
import shutil
import subprocess
import sys
import wave
import letter_aligned
import audio_metrics
import ukrainian_pronunciation

ROOT = Path(__file__).resolve().parents[1]
PIPER = ROOT / ".tools/piper/piper.exe"
MODELS = {"en": "en_GB-cori-high.onnx", "uk": "uk_UA-tetiana-high.onnx"}
REVISIONS = {"en": "375a0fe641dea077c2a47b4e9a056d6da521eed3", "uk": "42be6e3f72a7c6042271236b94e48edffd1f0c63"}
STAGING = ROOT / ".local/voice-staging"
JOBS = ROOT / "data/game_content/voice_jobs.json"

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

jobs = json.loads(JOBS.read_text(encoding="utf-8"))
parser = argparse.ArgumentParser()
parser.add_argument("--prefix", action="append", default=[], help="Generate only matching new activity keys; preserve the rest of the pack")
parser.add_argument("--locale", choices=["en","uk"], help="Replace only one locale, preserving the other locale byte-for-byte")
args = parser.parse_args()
previous_pack = json.loads((ROOT / "assets/audio/voice/manifest.json").read_text(encoding="utf-8")) if args.prefix or args.locale else None
if args.locale:
    jobs = {args.locale: jobs[args.locale]}
if args.prefix:
    jobs = {locale: [entry for entry in entries if entry["key"].startswith(tuple(args.prefix))] for locale, entries in jobs.items()}
summary = {"engine": "Piper VITS: CLI English / ONNX Runtime Ukrainian (development only)", "processing": {"peak": 0.46, "lowpass_hz": 4500, "length_scale": 1.12}, "models": {}, "clips": []}
if previous_pack:
    summary["models"] = previous_pack["models"].copy()
if previous_pack and previous_pack.get("processing") != summary["processing"]:
    raise ValueError("Partial generation cannot mix different processing settings")
(ROOT / ".local/logs").mkdir(parents=True, exist_ok=True)
for locale, entries in jobs.items():
    model = ROOT / ".tools/piper-voices" / MODELS[locale]
    if not model.is_file() or not model.with_suffix(".onnx.json").is_file():
        raise FileNotFoundError(model)
    summary["models"][locale] = {"file": model.name, "revision": REVISIONS[locale], "sha256": hashlib.sha256(model.read_bytes()).hexdigest()}
    if locale == "uk":
        summary["models"][locale]["phoneme_frontend"] = "Tetiana High IPA; finite reviewed lexical stress; explicit canonical letter names"
    if args.prefix and previous_pack and previous_pack["models"][locale] != summary["models"][locale]:
        raise ValueError("Partial generation cannot mix different voice models")
    lines = []
    for entry in entries:
        path = STAGING / entry["file"]
        path.parent.mkdir(parents=True, exist_ok=True)
        if locale!="uk" and not letter_aligned.is_letter(entry["key"]):lines.append(json.dumps({"text": entry["text"], "output_file": str(path)}, ensure_ascii=False))
    print(f"Generating {locale}: {len(entries)} clips...", flush=True)
    command = [str(PIPER), "--model", str(model), "--json-input", "--length_scale", "1.12", "--noise_scale", "0.35", "--noise_w", "0.4", "--sentence_silence", "0.15"]
    if lines:
        result = subprocess.run(command, input=("\n".join(lines)+"\n").encode("utf-8"), cwd=str(PIPER.parent), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (ROOT / f".local/logs/piper-{locale}.log").write_bytes(result.stderr + b"\n" + result.stdout)
        if result.returncode:
            raise RuntimeError(f"Piper {locale} exited {result.returncode}; inspect .local/logs/piper-{locale}.log")
    for entry in entries:
        path = STAGING / entry["file"]
        extraction=letter_aligned.render(entry,locale,path) if letter_aligned.is_letter(entry["key"]) else None
        source_phonemes=ukrainian_pronunciation.render(entry,path) if locale=="uk" and not extraction else None
        normalize(path)
        if extraction and audio_metrics.measure(path)["review"]:raise ValueError(f"Weak voiced letter: {entry['key']}")
        with wave.open(str(path), "rb") as clip:
            duration = clip.getnframes() / clip.getframerate()
        if not 0.15 <= duration <= 8:
            raise ValueError(f"Unexpected duration for {path}: {duration}")
        summary["clips"].append({**entry, "locale": locale, "seconds": round(duration, 3), "sha256": hashlib.sha256(path.read_bytes()).hexdigest(), **({"extraction":extraction,"synthesis_text":extraction["synthesis_text"]} if extraction else {}), **({"source_phonemes":source_phonemes} if locale=="uk" and not extraction else {})})
    print(f"Completed {locale}.", flush=True)
# All synthesis and signal validation finish before touching the runtime assets.
# Run with the app closed. Keep the first previous pack for comparison/recovery.
backup = ROOT / ".local/voice-backup/pre-soft-voice"
if not backup.exists():
    shutil.copytree(ROOT / "assets/audio/voice", backup)
for clip in summary["clips"]:
    target = ROOT / clip["file"]
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(STAGING / clip["file"], target)
if previous_pack:
    summary["clips"] = [clip for clip in previous_pack["clips"] if clip["locale"] not in jobs or (args.prefix and not clip["key"].startswith(tuple(args.prefix)))] + summary["clips"]
(ROOT / "assets/audio/voice/manifest.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
print(f'Voice pack ready: {len(summary["clips"])} clips.', flush=True)
