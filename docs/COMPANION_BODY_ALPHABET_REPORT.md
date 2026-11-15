# Companion labels, body exploration and individual alphabet analysis — 0.30.0

Source0.30.0 / future Android code34. Tablet and existing APK remain0.28.0/code32.
No build/install, staging, commit or push. Only the owner-selected human J recording was replaced in this increment;
the other709 recordings, including the previously selected Z, are unchanged.

## Companion mismatch

Home used diminutive PET labels while selecting dictionary WORD recordings:
UK Ведмедик/Ведмідь, Котик/Кіт and similar pairs. The previous voice audit checked
dictionary keys, not these separate rendered labels, so it missed the UI mismatch.

CompanionCatalog now derives the label and audio from the same vocabulary key.
The large portrait caption and its repeat action also use the selected animal's
word, replacing the fixed Foxie greeting for every companion. No new TTS is
needed to reconcile two different noun forms. Tests compare rendered labels,
manifest text and actual playback paths for all11 companions in both languages.
This fixes the word-form mismatch; it does not approve synthesis pronunciation.

## Body exploration

- Explore now displays markers immediately. Whole body offers11 primary parts;
  face zoom exposes facial details, and hand zoom exposes palm/fingers.
- Neutral circles use0.5 alpha. Exactly one selected part has stronger color,
  border and white center. Its localized name/repeat action identifies the choice.
- Deterministic placement keeps circles apart; small leader lines connect shifted
  circles to anatomical anchors. A22px visual radius plus2px touch margin remains
  disjoint at the enforced51px center spacing. Only visible circles are active
  in marker mode, preventing hidden overlapping rectangle hits.
- Original raw geometry remains available for authoring validation without
  markers. Its fallback chooses the smallest containing region, rather than
  whichever overlapping part happens to occur first in the file.
- Nose, mouth, chin, ear, eye and cheek anchors were recalibrated against native
  boy/girl captures; the generator and semantic crops were updated as well.
  Girl coordinates are independently specified rather than uniform boy offsets.
- Selecting head/hand still opens the relevant zoom. Explicit zoom changes clear
  stale selection so a label never claims a hidden marker is active.

## Every letter was analyzed

`audit_spoken_words.py --alphabet --force` independently decoded all26 EN and33
UK letter WAVs again, bypassing the recognition cache. Partial runs now write
`asr-selection.json`, keeping the full710-recording queue intact. A subsequent
full cached aggregation refreshed the current pack report.

`tools/audit_alphabet_quality.py` joins each exact WAV hash with its fresh
transcript, expected name/glyph and measured duration/activity/periodicity.
It checks explicit letter-name aliases and rejects extra words. Examples before
the J replacement included C→"See you", E→"Ian" and J→"Chey". An earlier pass
gave J a non-speech [Music] label; the changed ASR result itself illustrates why
recognition must not be treated as a listening verdict.

After the owner selected a human J replacement, its new WAV was recognized again.
Final59-letter analysis:17 recognizer-consistent names,40 discrepancies and the
two owner-selected J/Z. These are triage states, NOT40 proven wrong recordings or
17 pronunciation approvals. All57 non-selected letter recordings still need
listening acceptance. The agent does not claim to have heard/approved them.

Per-letter JSON and Markdown tables live in ignored
`.local/qa/alphabet-030/`; completed analysis/ASR snapshots are archived locally
for comparison. The listening catalog shows each letter's analysis alongside
its audio. Stale manifest/recording hashes suppress old results.

The owner explicitly accepted the human J recording (Commons En-uk-j.ogg,
Logictheo, CC BY-SA3.0). It was applied, independently recognized as J, credited
in parent sound settings and protected from regeneration. Source, license and
conversion are documented in assets/licenses/J_PRONUNCIATION_NOTICE.md. Previous
J bytes/manifest remain under ignored .local/qa/alphabet-030/j-before. A probed
Ukrainian candidate could not be decoded by the existing Vorbis tool and further
source fetching hit a rate limit; no unverified candidate was shipped.

## Validation

- Companion/body headless:2,560 checks /0failures, including circle centers/edges,
  disjoint placement, all visible targets, sprite landmarks and actual speech
  routes. Final native run:2,560 checks /0failures,
  with24 captures covering EN/UK, boy/girl, whole/face/hand at1280×800 and1024×768.
- World940 / Friends368 / Release2,259 / VoiceRouting3,556 checks passed.
- Semantic/letter classification7, listening-review7 and catalog8 Python tests
  passed. Content26JSON /708 keys /946 references, zero errors. Voice content
  remains710 clips with zero routing/text/hash errors.
- Native images were inspected and face anchors adjusted from those observations.
  The catalog's197 native previews were regenerated.
- Publication guard and whitespace checks passed; local reports, candidate audio,
  child saves and models remain ignored. Only the selected J runtime WAV changed.

Interactive isolated PC preview: `tests/desktop_030_review.tscn`.

Remaining: choose/replace genuinely problematic letter recordings after listening,
continue the other vocabulary complaints, and validate tablet touch feel after
an explicit update request. The alphabet is not declared finished on pronunciation.
