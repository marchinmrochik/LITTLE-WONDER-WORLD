# Generated speech attribution and provenance

The app bundles project-authored short phrases synthesized locally into WAV files. No voice model, Piper executable, eSpeak library or original dataset recording is distributed inside the app.

English: `en_GB-cori-high`, from `rhasspy/piper-voices`, pinned revision `375a0fe641dea077c2a47b4e9a056d6da521eed3` (v1.0.0). The model card identifies a female UK English voice trained from scratch on public-domain LibriVox recordings. Card retained in `cori-MODEL_CARD.txt`. Source: https://huggingface.co/rhasspy/piper-voices/blob/375a0fe641dea077c2a47b4e9a056d6da521eed3/en/en_GB/cori/high/MODEL_CARD . This replaces the earlier LJSpeech voice; its old card is retained for historical provenance.

Ukrainian: `uk_UA-lada-x_low`, from repository revision `6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3`. Its model card identifies the Lada source dataset under Apache 2.0. Source: Yehor Smoliakov's Ukrainian TTS datasets, https://github.com/egorsmkv/ukrainian-tts-datasets/tree/master/lada . Copyright 2022 Yehor Smoliakov. Model card and source license retained in `lada-MODEL_CARD.txt` and `lada-Apache-2.0.txt`.

The voice repository declares MIT in its metadata: https://huggingface.co/rhasspy/piper-voices/blob/6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3/README.md . Model-specific source notices above are retained alongside that metadata rather than replaced by it. Model files were verified against the repository's LFS SHA-256 values. Exact local model and output hashes are recorded in `assets/audio/voice/manifest.json` and `tools/voice-toolchain.json`.

Piper `2023.11.14-2` was used as a Windows development tool only. Source: https://github.com/rhasspy/piper/releases/tag/2023.11.14-2 . Its MIT notice is retained in `piper-MIT.txt`; this does not claim that all development-only dependencies have the same license. The synthesis engine/models stay under ignored `.tools/` and are not runtime dependencies of the application.

Generated audio has been trimmed, gently treble-smoothed, peak-normalized to 0.46 and faded at the edges by `tools/generate_voice_pack.py`. These are synthetic stock-model voices, not recordings by a hired actor or an imitation of a user-supplied person. Pronunciation, tone and final voice preference remain subject to listening review.
