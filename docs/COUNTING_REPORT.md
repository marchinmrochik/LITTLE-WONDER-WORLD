# Let's Count - desktop0.9.0

Seven of ten educational games now have complete desktop increments,plus Foxie's meadow. Android acceptance remains pending.

## Delivered behavior

Let's count / Нумо рахувати has two modes and four original-art themes:apples,carrots,strawberries,stars. Easy uses1-5,Normal/Advanced1-10;choice mode offers2/3/4 distinct numerals. A session has five distinct quantities and cycles all four themes. No timer,punishment or mistake limit.

How many? renders exactly the required group,asks an English question and speaks the selected number in English. Wrong answers retain the task. Correct answers give positive feedback and advance once;feedback guards ignore rapid duplicate input.

Basket displays a requested numeral with English spoken number words. Unique source objects can be dragged into the illustrated basket;the live numeral and stored objects agree. Tapping a stored object returns it. An instance cannot be stored twice. All ready! checks the exact live count,so empty/underfilled/overfilled baskets cannot complete the task. Incorrect checks preserve the basket for correction. Adding/removing objects alone does not record an answer attempt;only explicit checks count. Duplicate confirmations cannot score twice.

Shared PointerDrag/DragCard handles pointer ownership and drag cancellation. Outside drops,focus loss,parent overlay,mode switch and exit clean up pending input. Short feedback pauses with overlays/focus. Completion/replay works after five solved quantities in either mode. Saved counting counters distinguish actual choice/basket targets,without mastery claims.

## Content/audio

Four existing SVG themes are reused;basket.svg is a new original project vector. counting.json supplies theme metadata,singular/plural and instruction keys. Sixty new finite voice clips:ten numbers,four questions,forty basket quantity requests and six localized feedback/completion helpers. COUNT_ prefix generation preserved all previous150 clips. Current pack210 files,12,483,358 bytes,duration0.66-2.74s. Same documented Cori/Lada models and softened processing. Only WAVs ship;development models stay on PC. Voice preference/pronunciation remains pending. No new downloads or desktop user setup required.

## Verified

Final tools/Test-Counting.ps1:

- Foundation317 assertions,zero failures;shared independent-process persistence passed.
- Animals4757,Colors707,Feeding2914,Shapes5094,Puzzles8473,Memory3031 assertions,zero failures.
- Counting10875 assertions,zero failures.
- All210 voice files passed checksum,format,signal/fade and duration bounds.

Counting model coverage includes120 seeded sessions /600 tasks across both modes and three difficulties,unique in-range quantities/options,all four themes,invalid/duplicate object guards,overfill/underfill/return correction,explicit exact confirmation and duplicate completion rejection. Two-locale real-view tests cover actual viewport mouse and synthetic touch,real rendered cardinality,English repeat/numbers,rapid wrong/right answer/check guards,outside drops,focus/overlay cancellation,unique storage/return,overfill,completion/replay,mode switch cleanup and saved isolated actual attempt/task/session counts. Synthetic input is not physical Android proof.

Renderer produced60 PNGs across EN/UK at1280x800,1440x810,1024x768:second menu page,three choice difficulties,5/10-source basket layouts,drag highlight,ten stored objects,retry and completion. Zero control/card-label boundary issues. Selected boundary/menu screenshots visually inspected.

Native Windows mouse review exercised an incorrect2 for three strawberries,correct3,mode switch,a real apple drag,count1,return to0 and empty confirmation rejection. Full mode completions/replay were checked programmatically. App left open in Basket for user review;desktop log showed no errors during the review.

## Run and continue

Play:.\tools\Run-App.ps1 -> Let's play! -> page2 -> Let's count. Choose How many? or Basket.
Combined checks:.\tools\Test-Counting.ps1.
Render fixture:tests/counting_render_review.tscn;evidence:.local/logs/counting-*.log and .local/qa/counting/.

Next increment:Magic Drawing,including smooth strokes,eight colors,sizes,regular/soft/rainbow brushes,eraser,undo/redo,guarded clear,editable save/gallery and bounded memory. Inspect the original brief before implementation. Coloring Book and Magic Xylophone follow. Current source/export preset0.9.0/code9,ARM64;no current APK exported/installed,no tablet or Git operations. Resume:docs/CONTINUATION.md.
