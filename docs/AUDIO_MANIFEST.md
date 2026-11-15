# Audio Manifest

Status: desktop Animals, Colors, Feeding, Shapes, Puzzles, Memory, Counting, Drawing and Coloring slice, 2026-11-14. The approved foundation music/effects are retained. Local synthesized speech has been added; final voice preference/pronunciation review is pending.

## Bundled audio

| Content | Count/status |
| --- | --- |
| tap / sparkle / rest | Three original synthesized effect files, unchanged |
| meadow music | Original 16-second loop, unchanged |
| English animal words | Twelve local WAV files |
| English find instructions | Twelve local WAV files |
| English helper/UI phrases | Eight local WAV files |
| Ukrainian find instructions | Twelve local WAV files; available in the manifest for localized hints |
| Ukrainian helper/UI phrases | Eight local WAV files |
| Colors words/prompts/helpers | 26 files |
| Feeding words/requests/helpers | 32 files |
| Shapes names/prompts/helpers | 22 files |
| Puzzles helpers | Ten new files; animal words reused |
| Memory helpers | Eight new files; original picture words reused |
| Counting numbers/questions/basket/helpers | 60 new files |
| Drawing helpers | Four new intro/save clips |
| Total voice pack | 228 files, 13,421,964 bytes; durations 0.66-2.74 seconds |
| Animal sounds | Not included; optional for this slice |
| Other two games / xylophone | Not implemented |

English speech uses Piper en_GB-cori-high at 22,050 Hz. Ukrainian speech uses uk_UA-lada-x_low at 16,000 Hz. Clips are mono PCM 16-bit, trimmed, gently treble-smoothed at 4,500 Hz, peak-normalized to 0.46 and edge-faded. Pacing uses length_scale 1.12. These are synthetic stock-model voices, not a hired actor or an imitation of a supplied person. Quality labels describe the upstream model variants, not a claim of final application quality.

The actual game always plays English learning words and English find prompts, including under UK UI. Helper reactions/instructions use the UI locale. The Ukrainian find clips are prepared but not used to replace the English learning prompt.

## Runtime behavior

Local files take precedence over system TTS and work with the optional system-voice fallback disabled. No speech model/engine or network request is needed to play the bundled clips. Voice playback interrupts stale speech. Music is attenuated by 8 dB during local speech and restored when it ends; separate music/voice/effects controls remain available. Parent preview now works from a local clip even when no matching system voice is installed.

The optional system fallback remains off by default, checks installed voices and may depend on an external OS service/network. It is not represented as a guaranteed offline feature.

## Generation, checks and attribution

Development tools/models are kept under ignored `.tools/` and remain on the PC. Only finished WAV files and notices are application assets. The English dataset is identified as public domain by its model card; Ukrainian Lada is identified as Apache 2.0. Source cards, the Lada license and voice notices are retained under assets/licenses/. Exact model revision, verified LFS hashes and per-clip output hashes are recorded in assets/audio/voice/manifest.json and tools/voice-toolchain.json.

Generation: tools/prepare_animals_content.py, tools/prepare_colors_content.py, tools/prepare_feeding_content.py and tools/generate_voice_pack.py. Verification: tools/check_voice_pack.py. Do not regenerate files while another running application instance is playing them.

Actual checks: all 228 files matched manifest hashes, had valid PCM format, bounded non-silent signal, faded edges and valid duration. Resource resolution, local playback with system voices off, music duck/restore and interruption on leaving the game were checked. These are technical checks, not expert pronunciation approval. The user should listen to the new voice candidates before treating audio polish as final. Tablet speaker quality, latency and airplane-mode behavior remain pending.

Partial generation: `python tools/generate_voice_pack.py --prefix FOOD_ --prefix FEED_` preserves existing nonmatching clips and requires matching model/processing provenance. Feeding added 32 new clips without rewriting the 78 files used by the running previous app. Full regeneration still requires closing playback instances.

Shapes adds 22 finite clips using `--prefix SHAPE_ --prefix SHAPES_`; existing 110 clips were preserved. Six English names and six prepared find prompts plus five helpers per UI locale. Sorting plays shape names in English and helper instructions/reactions in the UI locale; prepared find prompts are not a required sorting mode. Same licensed models/processing, no new runtime dependency.

Puzzles adds ten helper clips using `--prefix PUZZLES_`; original animal English words and the previous 132 files remain unchanged. Same Cori/Lada models and gentler processing. Subjective listening/pronunciation review remains pending.

Memory adds eight helper clips using `--prefix MEMORY_`, preserving the previous142. Existing animal/food/shape words play in English on reveal, including with UK interface. The second word is allowed to finish during the short pair hold before mismatch/match helper playback. Same licensed models and gentler processing; subjective preference/pronunciation remains pending.

Counting adds60 clips by COUNT_ prefix:ten English numbers,four theme questions,forty quantity basket requests and three localized helper phrases per locale. Previous150 clips preserved. Learning prompts/numbers stay English under either UI locale;basket feedback helpers use the interface locale. Number-choice feedback speaks the selected number while showing localized reaction text;basket transfers speak the live count. Same licensed Cori/Lada processing;subjective listening/pronunciation approval remains pending. This is WAV content size,not measured APK/installed size.

Drawing adds four helper clips with DRAW_ prefix, preserving earlier 210 clips. Existing music/effects are retained. The same Cori/Lada models and softened processing apply; final listening/pronunciation approval remains pending.

Coloring 0.11.0 adds fourteen BOOK_ clips: ten English page nouns and intro/save helpers in EN/UK. Prior 214 clips were preserved. Verified total: 228 clips, 13,421,964 bytes, 0.66-2.74s. Same pinned Cori/Lada models and gentle processing; listening approval remains pending.

Magic Xylophone0.12.0: eight project-original synthesized modal-bar tones under assets/audio/instrument, generated by tools/prepare_xylophone.py. C5,D5,E5,F5,G5,A5,B5,C6; mono PCM16bit44.1kHz,1.7seconds each. Smooth attack/end, decaying harmonic partials. Eight WAVs total1,199,872bytes. No external samples/models/downloads. Instrument uses parent SFX volume and16 voices at gain0.095; signal validation confirms correct fundamentals and worst-case16peak sum0.899<1. Voice pack remains228files/13,421,964bytes, unchanged. Technical checks do not establish subjective timbre approval or tablet latency.

Current UX0.13.0 supersedes earlier UK entries:178 EnglishCori clips preserved,178 separate Ukrainian clips synthesized with ukrainian_tts-medium/Tetiana2,22050Hz. Total356clips,23,876,002bytes,0.58–2.84s. No English fallback in UK game vocabulary/instructions. Same gentle processing. Model PC-only76,735,663bytes; pinnedrevision/hash/speaker recorded in runtime voice manifest,CC0 model card bundled. tools/prepare_full_ukrainian.py supplies canonical Ukrainian jobs; generate_voice_pack.py --locale uk preservesEnglish. Technical checks passed; subjective pronunciation/timbre approval remains pending. SeeUX_REPORT.md and sample.local/qa/uk-tetiana-preview.wav.

Completion0.14.0 adds PARTY_INTRO in EN/UK with the existing Cori/Tetiana voices:358speech clips,total24,256,750bytes,0.58–4.76s. Existing356preserved. Original softballoon_pop.wav,mono44.1kHz16bit,0.14s,amplitude bound0.14;usesSFXvolume. Fireworks have no loud explosion. No new models/downloads. SeeCELEBRATION_REPORT.md.

Feedback0.15.0 adds85finite alphabet/blend clips using existing Cori/Tetiana models.443total27,789,806bytes0.49–4.76s. foundation.study_locales declaresexplicitlessonlanguage mappings;normalUIlocale policy unchanged. Letters speak names,blend targets speak standalone units;not a complete phonics curriculum. Signal/hash checks pass;user pronunciation reviewpending. No downloads.

Learning0.17:614clips,total35,563,904bytes,0.49–4.76s. Replaced English ALPH_ recordings with short isolated letter names (no The letter sentence);59new example words and44new body-part word/prompt clips,usingexisting pinned Cori/Tetiana models. Letter/example mappings andtechnical signal/hash checks passed;single-letter TTS pronunciation still needs user listening. UIlocale now controls the exposed alphabet and picturedword pool;study_locales is retained for asset provenance/legacy syllable data.

Letter revision0.18:all59 names regenerated from unchanged pinned Cori/Tetiana weights,using model duration alignment to remove synthesis-only context. Fixed EnglishAy→A frontend mismatch (/aɪ/→/eɪ/),validated26expected English phoneme sequences and33canonical Ukrainian names;clearerX vowel. Each clip records extraction bounds/phonemes/settings.59names0.423–0.713s;whole614clip pack34,215,400bytes,0.42–4.76s. Voicing/source-phoneme checks passed for every name;this is not a manual listening/ASR claim. Seeindividual players.local/qa/letter-audio/listen.html. Local NumPy/ONNX/ORT development libraries and modified graphs are not shipped.


Living drawings0.20:18new EN/UK finite local clips using existing Cori/Tetiana models. First walls instruction also explains following the dots. Whole pack632clips,35,710,534bytes,0.42-4.76s. Format/hash/non-silence checks passed; listening review remains pending. No new model downloads.


Living yard0.21:28finite LIVE clips (10more than0.20), updated open-ended wording, existing Cori/Tetiana models. Whole pack642clips,37,651,034bytes,0.42-5.15s;technical auditpassed. yard_bark.wav is original deterministic synthesized two-woof effect,mono22050Hz16bit,.62s,controlled by SFX bus and scene pause. No external animal recording/new model downloaded.


Seasonal0.22:64new finite local EN/UK clips from existing Cori/Tetiana models,32spoken seasonalkeys. Fullpack706clips,41,841,548bytes,.42-5.15s. Format/checksum/signalchecks pass;pronunciationrequireslistening. No newmodels/dependenciesdownloaded.


Ukrainian revision0.23 supersedes prior TetianaMedium notes. All369UKclips regenerated with pinned RomanStasyshyn/uk_UA-tetiana-high at42be6e3f72a7c6042271236b94e48edffd1f0c63,modelSHA1206d8447b99632badeb63d6132241f76cf551874e5254eb8836db36aed7c85c,Apache2.0. Direct ONNX CPU inference with Ukrainian IPA and264 authoredstressentries;all320ordinarywordtokenscovered.33letternameIPA explicit,contextdurationextracted;all59letterauditsno flags. FournewTRACEclips/710total41,403,194bytes,.42-5.36s.339oldENclipsbyteidentical. Technicalformat/hash/signalpass;native-listeningqualitypending. Weights114,204,024bytesdownloadeddevelopment-only,nonewpackages/runtime dependencies. A/B.local/qa/uk-high/listen.html;backup.local/voice-backup/pre-uk-high. SeeSYMBOL_TRACING_VOICE_REPORT.md and bundled highmodelcard/Apachelicense.
