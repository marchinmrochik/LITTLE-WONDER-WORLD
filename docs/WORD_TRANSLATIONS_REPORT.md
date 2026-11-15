# Optional Ukrainian translations in English mode - 0.25.0

The parent-only Language section now has Ukrainian word translations / Український переклад слів with an On/Off button and an explanation. The preference defaults off, saves locally, accepts only a boolean and loads older version1 settings without requiring a migration. It can be configured under either UI language, but captions display only when the app and actual spoken lesson language are English.

A small rounded two-line card occupies the existing free center area of the header: English word above its Ukrainian translation. It neither covers the game nor changes spoken language. It appears when a vocabulary word/request is selected or repeated, including with voice muted, and lasts six seconds. Another vocabulary cue replaces it; generic praise leaves the word readable. Leaving the activity, disabling the option or changing to Ukrainian clears it. Modal/focus suspension hides and pauses the caption.

A finite dictionary covers264 cue keys from authored animal, food, color, shape, body, plant, coloring, puzzle, memory and counting catalogs, all26English pictured-alphabet examples, pictured-word assembly, seasonal/house drawing nouns, number names and counting requests. Context-specific keys distinguish Orange the fruit (Апельсин) from Orange the color (Помаранчевий). Alphabet letter names themselves are not incorrectly equated with Ukrainian alphabet letters. Counting requests can show their full short Ukrainian translation. No online translation, dependency download, additional speech generation or Ukrainian audio playback was introduced.

AudioManager emits a presentation-neutral speech_requested signal before its mute check. WordTranslationCaption alone resolves this event into text, while the existing playback path/locale remain unchanged. It is hosted in AppRoot's expanding header slot. Purely parent/menu/helper speech does not create vocabulary captions. New source data is reproducible through tools/prepare_word_translations.py and is included in the future Android asset checks.

## Verification

- Focused translation tests2940 assertions,zero failures: actual parent toggle,settings reload,legacy validity,type rejection,mute behavior,all264keys across11activity routes,English playback assertion,explicitUK override,timeout,modal,locale/disable/route clearing and orange context.
- Foundation699 and UX882 checks passed,zero failures.
- Render review51captures across1280x800,1440x810,1024x768:zero issues. These inject representative vocabulary cues into activity screens to test caption bounds/navigation clearance; they are not full gameplay recordings. Selected short-word and longest-count-request captures visually inspected.
- Static content24JSON documents,648bilingual keys,901concrete resource references,zero errors.

Normal app:tools/Run-App.ps1;Grown-ups -> Language -> Ukrainian word translations. Isolated English preview with the option enabled:tests/word_translation_native_review.tscn. Functional/render fixtures:tests/word_translation_tests.tscn and tests/word_translation_render_review.tscn. Logs:.local/logs/translations-*.log.

Source0.25.0,futureAndroidcode29. No APK export,ADB,tablet install or Git operation. Installedtablet/existingAPK remain0.18.0/code20. Existing voice pack and drawing/category/back changes are retained. Tablet acceptance remains pending.
