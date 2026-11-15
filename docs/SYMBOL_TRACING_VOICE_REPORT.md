# Symbol repetition and Ukrainian voice revision - 0.23.0

## Child flow

The existing alphabet screen now has a separate Trace / Обвести tab, alongside Letters and Letter with picture. Inside it, Letters / Numbers selects 26 English or 33 Ukrainian printed uppercase letters (following app locale), or all ten digits 0-9. This is printed-symbol recognition and motor repetition, not a cursive handwriting curriculum.

A large pale track shows the symbol; only the current stroke has dots and a green leading point. The child traces it using the existing forgiving GuidedTrace model, including either direction on closed contours, spatial jitter tolerance, pointer ownership and lift/resume behavior. Multi-stroke letters are drawn one stroke at a time. The small dot accents in Ukrainian Ї are tappable rather than requiring microscopic drags. No foreign alphabet selector appears in Ukrainian mode.

Completing a symbol plays its existing localized isolated letter/number name, shows three small quiet fireworks and automatically selects another symbol. The next symbol waits for at least 1.5 seconds and for speech to finish, so the name is not cut off. A shuffled bag visits the complete selected set and avoids immediate repeats across bag boundaries. There is no round ending, common balloon party, completed-session award or invented mastery score. Speaker and replay controls permit repetition of the current symbol. Pausing freezes drawing and the fireworks/advance timer; resuming repeats a symbol name interrupted by parent/focus pause. Existing alphabet grid and pictured cards remain accessible.

## Ukrainian speech work

All 369 Ukrainian clips were regenerated, not just the new activity. The previous text-input multispeaker model was replaced by the single female Ukrainian Tetiana High model, trained by Roman Stasyshyn, Apache-2.0. Model weights/config are development-only; the application continues playing local WAVs offline. The 114,204,024-byte model was downloaded to the PC, with pinned revision and upstream LFS SHA256 verification. No new Python dependencies, account, cloud runtime or tablet model installation is needed.

Pinned source: https://huggingface.co/RomanStasyshyn/uk_UA-tetiana-high/tree/42be6e3f72a7c6042271236b94e48edffd1f0c63
Model SHA256: 1206d8447b99632badeb63d6132241f76cf551874e5254eb8836db36aed7c85c

Using a Ukrainian voice alone did not solve all front-end problems: eSpeak's default for один placed its stress on the first vowel. The finite application vocabulary now uses 264 authored lexical stress entries, with explicit coverage checks over all 320 distinct ordinary word tokens. Every polysyllabic word in the current jobs must have a stress entry; a new unreviewed word stops generation. Stress is inserted into Ukrainian IPA before ONNX inference. This is authored vocabulary review, not a claim that a linguist listened to every clip. Selected inflections and problematic distinctions were cross-checked against dictionaries; sources include the Ukrainian orthography's оди́н and dictionary forms for м'яки́й, гнізде́чко, сніговика́ and моркви́ну.

All 33 Ukrainian letter names use explicit canonical IPA, including distinct И / І / Ї, Г / Ґ and Є / Ю / Я. Duration alignment removes the synthesis-only context, retaining just the letter name. Every letter passed individual duration/voicing and intended-phoneme checks. The words качка and качку are regenerated through Ukrainian IPA with first-syllable stress. Speech jobs retain their actual Ukrainian UI spelling; accent/control data do not appear in the child UI.

All 339 pre-existing English clips are byte-for-byte unchanged. Four new clips (tracing hint and zero in each language) bring the pack to 710 clips, 41,403,194 bytes, 0.42-5.36 seconds. Technical format/hash/signal checks pass. A/B players for every Ukrainian recording are under .local/qa/uk-high/listen.html; earlier files remain under .local/voice-backup/pre-uk-high. Individual letter players/audits are under .local/qa/letter-audio. Human listening remains necessary to judge whether the timbre and pronunciation now satisfy the user; signal checks do not prove natural pronunciation.

Sources consulted:
- Voice/model card: https://huggingface.co/RomanStasyshyn/uk_UA-tetiana-high
- Piper model/frontend format: https://github.com/rhasspy/piper/blob/master/src/cpp/piper.cpp
- Official orthography: https://mon.gov.ua/static-objects/mon/sites/1/zagalna%20serednya/Pravopys.2019/ukrayinskii-pravopis-oficiine-vidannia-2026.pdf
- Inflection reference: https://goroh.pp.ua/Словозміна/гніздечко and https://goroh.pp.ua/Словозміна/сніговик (linked upstream to Словники України).

## Verification and use

Final focused symbol suite: 1435 checks, zero failures, including actual viewport tracing of every letter/digit in both locales at all three difficulties, dot accents, pause, exact spoken-name selection, actual audio playback, waiting for speech and automatic continuation. Render review: 117 captures across EN/UK and 1280x800,1440x810,1024x768; zero clipping issues, with geometric checks over all glyph path points and selected Ї/8 frames visually inspected. All 59 EN/UK letter audio checks have no review flags. Content audit: 23 JSON documents, 645 bilingual keys, 900 concrete resource references, zero errors. The full Test-Seasons.ps1 chain passed with the rebuilt voice pack, including foundation, all earlier activity suites, persistence, house777, seasonal1008 and mouse-circle12 checks; final symbol1435 checks passed separately after adding the spoken entry hint.

Normal launch: tools/Run-App.ps1, then Letters -> Trace -> Letters / Numbers. Isolated Ukrainian preview: tests/symbol_tracing_native_review.tscn through tools/Start-Godot.ps1. Full regression wrapper: tools/Test-SymbolTracing.ps1. Data/geometry/localization generation: tools/prepare_symbol_tracing.py. Existing-season and house drawing behavior remains separate.

Source 0.23.0, future Android code26. No APK export, ADB or tablet installation occurred. Existing APK and last installed tablet remain 0.18.0/code20. Real tablet finger input and speaker listening have not been accepted in this increment.
