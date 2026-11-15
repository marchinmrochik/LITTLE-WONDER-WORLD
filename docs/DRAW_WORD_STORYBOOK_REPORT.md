# Draw a word and storybook illustrations — 0.27.0

Desktop source version 0.27.0; future Android code 31. The installed tablet and
existing APK remain 0.25.0/code29. No APK export, installation or Git operation.

## Draw a word

New offline EN/UK activity uses the existing vocabulary, pictures and accepted
recordings. Choose a category, random task or a specific pictured word. Easy and
Normal use one word; Advanced combines two familiar words. Shuffled primary-word
bags cover the category before repeating and avoid an immediate boundary repeat.

Child mode shows the picture and word and can repeat its existing recording.
Family mode privately shows a task, hides it before drawing, and offers Peek,
Reveal and a human-confirmed guessed action. Secret tasks are not spoken and
cannot leak through the optional translation caption. There is no automated
recognition or knowledge score.

The shared drawing editor retains its palette and tools, with compact insets for
more paper. A separate draft and task context resume together; free drawing is
not overwritten. Changing an unpublished drawing asks to save it first. Full
gallery/save errors preserve both ink and task. Gallery limits remain unchanged.

## Living drawings

All 46 actors across House, Spring, Autumn and Winter now use companion-style
art through the shared DesignVisuals registry: 40 original local SVGs plus the
existing dog/rabbit companions. Rounded forms, warm pastels, expressive faces
and soft highlights replace the previous mixed procedural shapes. The hedgehog,
birds, frog, squirrel, penguin, trees and household elements were redrawn.

Completing the cloud also reveals two additional drifting clouds. Day/night and
lit/unlit variants remain meaningful. Smoke/color changes, rain, puppy movement
and bark, flights, hopping, ripples and small highlights retain interaction.
Traces were fitted to the new artwork and remain within their zoom views.
Procedural fallback remains available; art is editable through the local catalog.

The catalog now indexes 1,438 records / 932 media files, 46 story actors and 16
game/world screen entries. The native renderer produced 185 preview images.
No external artwork, models, packages or downloads were added.

## Validation

- DrawWord headless: 1,545 checks, zero failures; native: 1,581 checks, zero
  failures and 24 EN/UK captures at 1280×800 and 1024×768.
- Drawing 420, translations 2,940, house 777, seasonal 1,008 and release 2,259
  checks passed with zero failures in their focused suites.
- Python story-art and catalog fixtures: 10 tests passed. All 46 actor resources
  and their variants resolve; traced points fit the zoom bounds.
- Content audit: 25 JSON documents, 702 EN/UK keys, 945 resource references,
  zero errors. Voice audit: 710 existing recordings, no content errors; no voice
  recordings changed in this increment. Signal checks are not listening approval.
- Inspected native story screenshots and new-game layouts. Touch feel and
  subjective art/pronunciation acceptance still require the user's review.

Run isolated interactive review with:

```powershell
.\tools\Start-Godot.ps1 --path . --scene tests/storybook_native_review.tscn
```

It opens the completed autumn scene with separate saves. Back opens the story
gallery; return to Activities to try Draw a word. Focused checks are repeatable
with `tools/Test-DrawWord.ps1`.

Remaining requested backlog: unfinished speech listening/replacements, artwork
export and gallery capacity, optional coloring reference. The local-only tracker
is `.local/plans/TESTER_FEEDBACK_2026-11-15.md`.
