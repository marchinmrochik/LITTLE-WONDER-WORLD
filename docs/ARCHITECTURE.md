# Architecture

Little Wonder World is a Godot 4.7 project built in GDScript. [project.godot](../project.godot) declares the start scene, viewport, renderer and autoloads.

| Area | Responsibilities |
| --- | --- |
| [App shell](../scripts/core/app_root.gd) and [routing](../scripts/core/game_manager.gd) | Shared background, navigation, settings gate, modal overlays and activity lifecycle. |
| [Game scenes](../scenes/games/) and [game scripts](../scripts/games/) | Activity rules, interaction state and game-specific presentation. |
| [Shared components](../scripts/components/) | Theme, buttons, touch scrolling, dragging, tracing, coloring and artwork views. |
| [Content](../data/game_content/) and [localization](../data/localization/) | JSON content catalogs, translations and stable keys for illustrations and speech. |
| [Audio](../scripts/core/audio_manager.gd) | Bundled voice playback, effects, music and separate volume controls. |
| [Persistence](../scripts/core/) | Settings, progress, assessment history and artwork stored locally under Godot's `user://`. |

Activity scenes use the common shell. Content keys connect localized labels to assets and speech through the content and localization services. The [voice manifest](../assets/audio/voice/manifest.json) records bundled clips and their hashes.

Drawing and coloring use a shared artwork gallery with PNG export. Coloring keeps region state and an artwork revision so previously saved pictures can be restored from their original template.

The [design catalog](../design_catalog/README.md) is a separate local development tool. Its previews, drafts, review records and backups are stored outside the application bundle.

See [Development](DEVELOPMENT.md) for run, test and export commands.
