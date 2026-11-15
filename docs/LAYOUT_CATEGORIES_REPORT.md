# Drawing side rails and category separation - 0.24.0

Digit tracing now belongs to the Numbers and counting / Цифри й лічба category. It has three peer tabs: How many? / Скільки?, Basket / Кошик, and Trace digits / Обвести цифри. The alphabet retains its letter grid, pictured cards and letter-only tracing. Neither tracing context exposes a switch into the other subject. SymbolTracing accepts a fixed mode supplied by its parent; counting owns its embedded digit practice, forwards pause/focus and supplies its tracing idle action without replacing the established counting idle-guide behavior. A stale counting feedback callback cannot overwrite tracing. Both tracing modes retain the endless sequence, exact localized name, small fireworks and speech-aware advance.

Magic drawing now uses the available side space: brush/eraser/size controls sit in a vertically centered left rail; nine quick colors plus the full-palette button sit in two columns on the right, with undo/redo/save/gallery/clear below them. The title/status are in the bottom footer. The canvas has a deliberate upper inset and remains centered between the rails, with its full paper boundary visible. At 1280x800 the fitted paper is 931.2x582 versus the preceding 920x575, and begins at logical (151.4,137). At 4:3 it reaches 1010x631.25. The raster remains 1024x640 and existing drawings/drafts keep their format. The 149-choice palette and gradient modal are retained. The palette's side layout is opt-in, so Coloring keeps its horizontal palette.

## Validation

- Symbol repetition/category routing: 1447 assertions, zero failures. Includes both languages, all symbols/all three difficulties, no digit choice in alphabet, numeric-category tracing, switching back to Basket/How many?, stale-feedback protection, pause, exact spoken name and automatic continuation.
- Existing Counting10874, Drawing420, Coloring1820, ScrollPaint44 and UX882 checks passed, zero failures.
- Drawing layout review:16 captures, EN/UK at1280x800,1440x810,1024x768,1152x664; zero layout issues, including paper bounds/header clearance and palette beside paper. The Ukrainian desktop drawing image was visually inspected.
- Updated letter/digit review:117 captures across two languages and three standard resolutions; zero layout issues. The numeric-category digit8 screenshot was visually inspected.
- Static content:23JSON documents,646 bilingual keys,900 concrete resource references,zero errors.

No speech regeneration, dependency download, Git, APK export, ADB operation or tablet installation occurred. Ukrainian Tetiana High recordings from0.23 are preserved. Source0.24.0,futureAndroidcode27; installed tablet and old APK remain0.18.0/code20. PC rendering/input verification is not tablet acceptance.

Normal app: tools/Run-App.ps1. Isolated current-category preview: tests/layout_categories_native_review.tscn. Render fixtures: tests/drawing_rails_render_review.tscn and tests/symbol_tracing_render_review.tscn. Focused functional fixture: tests/symbol_tracing_tests.tscn. See .local/logs/categories-symbols-final.log, drawing-rails-*.log, categories-*.log and drawing-categories-ux.log.
