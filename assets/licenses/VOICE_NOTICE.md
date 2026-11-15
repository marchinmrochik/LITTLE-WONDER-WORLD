# Generated speech attribution and provenance

## Current per-cue selections (2026-11-15)

English remains primarily Cori GB. `WORD_SHEEP`, `WORD_CAT`, `BOOK_WORD_CAT` and `ALPH_WORD_EN_02` use the already available
`en_US-ljspeech-high` model, SHA256
`5d4f08ba6a2a48c44592eed3ce56bf85e9de3dd4e20df90541ae68a8310c029a`.
Its retained `ljspeech-MODEL_CARD.txt` identifies the LJ Speech dataset as public
domain. This is a selected stock-model recording, not a custom/cloned voice.

Current Ukrainian uses Tetiana High; earlier Lada descriptions below are
historical. `WORD_CAT`, `BOOK_WORD_CAT` and `ALPH_WORD_UK_14` share the selected
standard-text Tetiana High recording of Кіт. Model/license information is in
`tetiana-high-MODEL_CARD.md` and `tetiana-high-Apache-2.0.txt`.

Per-cue model/frontend/settings and output hashes are recorded in the speech
manifest's `voice_override` fields. `tools/voice_clip_overrides.json` protects
selected bytes from routine regeneration; changed text/audio requires a fresh
listening decision. Unselected comparison recordings remain development-only.

## Repair 0.28

364 Ukrainian recordings now use the same pinned Tetiana High model: standard
text frontend for words/phrases, whole-letter canonical IPA for 33 letter names,
without sentence extraction. Selected Кіт/Качка/Вівця remain byte-for-byte.
23 English vocabulary/body recordings now use the existing LJ Speech model;
Z uses whole-letter Cori /zed/. Previously selected Cat/Sheep and other English
recordings are unchanged. Per-cue `voice_repair` metadata stores model hashes,
method and an explicit **unreviewed** listening status. Technical checks are not
pronunciation approval. `voice_repair_pins.json` prevents accidental regeneration
of these replacements; it is distinct from human-selected overrides. No new
model, executable, library or dataset was acquired or shipped.

## Original and historical notices

The app primarily bundles project-authored short phrases synthesized locally into WAV files. Voice models, Piper/eSpeak and source datasets are not distributed. The standalone human Z recording is the exception described below.

English: `en_GB-cori-high`, from `rhasspy/piper-voices`, pinned revision `375a0fe641dea077c2a47b4e9a056d6da521eed3` (v1.0.0). The model card identifies a female UK English voice trained from scratch on public-domain LibriVox recordings. Card retained in `cori-MODEL_CARD.txt`. Source: https://huggingface.co/rhasspy/piper-voices/blob/375a0fe641dea077c2a47b4e9a056d6da521eed3/en/en_GB/cori/high/MODEL_CARD . This replaces the earlier LJSpeech voice; its old card is retained for historical provenance.

Ukrainian: `uk_UA-lada-x_low`, from repository revision `6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3`. Its model card identifies the Lada source dataset under Apache 2.0. Source: Yehor Smoliakov's Ukrainian TTS datasets, https://github.com/egorsmkv/ukrainian-tts-datasets/tree/master/lada . Copyright 2022 Yehor Smoliakov. Model card and source license retained in `lada-MODEL_CARD.txt` and `lada-Apache-2.0.txt`.

The voice repository declares MIT in its metadata: https://huggingface.co/rhasspy/piper-voices/blob/6b9cfaacb4fb2e02a9621227e3c1a48bec9710c3/README.md . Model-specific source notices above are retained alongside that metadata rather than replaced by it. Model files were verified against the repository's LFS SHA-256 values. Exact local model and output hashes are recorded in `assets/audio/voice/manifest.json` and `tools/voice-toolchain.json`.

Piper `2023.11.14-2` was used as a Windows development tool only. Source: https://github.com/rhasspy/piper/releases/tag/2023.11.14-2 . Its MIT notice is retained in `piper-MIT.txt`; this does not claim that all development-only dependencies have the same license. The synthesis engine/models stay under ignored `.tools/` and are not runtime dependencies of the application.

Generated audio has been trimmed, gently treble-smoothed, peak-normalized to 0.46 and faded at the edges by `tools/generate_voice_pack.py`. These are synthetic stock-model voices, not recordings by a hired actor or an imitation of a user-supplied person. Pronunciation, tone and final voice preference remain subject to listening review.


## Selected human Z — 0.29

The owner selected British human zed from Commons File:En-uk-z.ogg (public domain / PD-self), replacing rejected Cori/LJ synthetic Z attempts. See Z_PRONUNCIATION_NOTICE.md for source, assumed author and processing. Its exact output is protected in voice_clip_overrides.json. Other709clips are unchanged by this increment; ASR triage is not listening approval.
