# Foundation Design System

Status: user-approved foundation graphics/music, extended with the Animals desktop slice. New animal illustrations and voices are presented for review; final polish remains separate.

The current direction is a warm, quiet illustrated meadow: cream sky, layered mint hills, rounded cream cards, an apricot fox with a green scarf and a butter-yellow primary action. These are original SVG assets rather than emoji or system stock art.

| Role | Color |
| --- | --- |
| Primary text | #243B36 |
| Secondary text | #64796F |
| Green accent | #367B64 |
| Cream | #FFF8EC |
| Mint selection | #D8EDDF |
| Primary action | #FFE0A1 |
| Destructive confirmation | #FFD1AB |

Nunito variable is bundled with its OFL license and uses numeric OpenType weight selection at 700. Ukrainian-specific glyphs are checked automatically. Child headlines use 57 logical pixels; child primary actions use 32; parent body copy generally uses 18-25. Layout containers wrap the longer Ukrainian headline and parent explanatory text.

Child primary actions are 84-88 logical pixels high; common parent controls are at least 60-64 high. Actual physical size must be checked on the Redmi. Components use generous gaps and rounded corners. Do not add empty game tiles. Parent settings may scroll; child home/meadow should remain fully visible.

Current optional motion: subtle Foxie idle sway, small button press and positive response, short route fade. Reduced motion disables these optional effects. Rest uses a separate closed-eye SVG and quieter music. No flashing, failure screens, punishment or mandatory timer is present. The only timer is the adult hold.

The Animals extension uses twelve original 300x300 SVGs, cream rounded cards and a soft #DEEAD7 backing shape that keeps white bodies visible. Exploration cards are 250x330 logical pixels; quiz cards use the same visual system with 2/3/4 choices. Navigation/mode icons reserve their width rather than disappearing beside text.

Foxie has idle/resting/happy/waving/thinking/encouraging/celebrating vectors. Greeting uses waving, questions use thinking, retry uses encouraging, and success/completion use happy/celebrating. Existing music and base illustrations are retained. Stable paths allow later art replacement without rewriting game logic. New voice preference/pronunciation still needs listening review.

Shapes use original colored geometric pieces and matching pale neutral silhouettes, cream cards and mint accepted slots. Piece and target order vary independently. The five-card activity row uses 216x380 logical cards with wrapped titles; reviewed at all three desktop ratios in both locales. Growing beyond five activities should introduce paging or a new reviewed menu layout.

Puzzles increment replaces the five-card row with six 350x210 logical cards in a 3x2 grid. Each card uses a 120px art column and a wrapped title/subtitle. Puzzles uses a 360x360 picture surface, creamy tray cards, translucent optional source template and subtle rectangular cut lines. Correct-region highlighting is bounded to the piece destination.

Memory increment uses an original mint/star card back with a cream outer button; fronts reuse familiar original illustrations. Only inner artwork flips; cards retain fixed hit boxes. The menu now pages a 2x2 grid of420x210 logical cards with a stable empty second-row area on shorter pages, a page indicator/arrows and persistent Foxie button. Reviewed both pages in EN/UK at all three ratios.

Counting uses equal-size separated objects (up to two rows of five),large numeral choices and a cream basket target with illustrated wicker base. Stored items have individual return controls and a live numeral. Supplies fade when stored rather than producing duplicate visible active objects. Shared mode buttons show choice/basket selection;English quantity text uses numerals while voice speaks number words.

Drawing uses a fitted white 1024x640 page with a left brush/size toolbar, nine colored swatches, top undo/redo/save/gallery/clear actions and a status line. The page preserves its aspect ratio. Thumbnails are reduced to 192x120; adult gallery adds a confirmed Delete action while child gallery only opens pictures.

Coloring Book uses the existing cream/sage shell and large controls, fitted white1024x640 page with dark outlines and independently colored regions. Ten friendly original pages; a colored butterfly distinguishes the menu entry at small size. Render evidence:138 states across EN/UK and three aspect ratios, zero button-boundary issues.

Magic Xylophone keeps the meadow shell and eight large pastel bars with decreasing lengths, rounded corners, wood rails, pitch letters and pressed highlights. Layout uses available width with bounded inter-key gaps and no small play targets.24 EN/UK render captures across1280x800,1440x810,1024x768: zero bounds/input issues. Reduced motion disables decay pulses while retaining held-state feedback.

UX0.13.0: large illustrated virtual game cards in a vertically scrollable grid; one companion footer,no pagination. Original centered tool icons andthree brush-size dots replace reading-dependent drawing labels. One noninteractive finger after10idle seconds;one tap or drag at a time.180render captures acrossEN/UK/3ratios plus native centered-icon/scroll/drawing review. No approved base art/music replaced.

Completion0.14.0: large fixed pastel balloons in3columns×2rows,centered localized praise,one instruction andremaining count. Short foreground firework rays andsoft pop bursts;no flashing orloud explosion. Reduced motion uses static bursts.24render captures,zero balloon/counter bounds issues at3ratios inEN/UK.
