# Scroll and drawing revision — desktop 0.19.0

2026-11-14. User requested easier whole-screen scrolling on the initial screens/settings, a larger color palette, smaller side tools and a larger drawing area. Source0.19.0/future Android code21. Installed tablet remains0.18.0/code20; no device operations or APK export in this increment.

## Scrolling

TouchScroll replaces separate gesture behavior in the virtual activity catalog, home page, settings and expanded paint picker. A drag can start over text, cards or ordinary buttons. A stationary release forwards a single click; dragging never clicks the item beneath it. It handles mouse drag/wheel, touch, duplicate emulated mouse events, canceled contacts, extra fingers, focus loss, modal blocking, inertia and boundaries. A tap while a list is moving stops it without selecting an item. Movement is integrated as a floating offset with smooth damping; no timed post-swipe button lock.

Settings distinguish vertical movement from horizontal HSlider adjustment: a vertical swipe over a volume control pans the page without changing volume; a horizontal drag adjusts the slider. Home now has one vertically scrolling page with the existing greeting/play area and a two-row pet grid, rather than a small nested horizontal pet strip. Navigation stays fixed above the page.

The activity list remains virtualized. Rebinding now occurs only when the visible item window, width, locale or catalog size changes; it no longer renames controls and reloads their icons on every pixel of scrolling. The existing bounded-cell test for1000future activities remains active.

## Painting

The shared picker now offers143unique solid colors and6existing gradients,149choices total. It is a large vertically swipeable grid; deliberate selection closes it and resumes drawing. Existing quick colors and gradient IDs are retained. Coloring also receives the expanded shared palette.

Drawing merges its title, quick palette and actions into one compact top row. Side tools are68logical pixels wide, with32px maximum icons; brush sizes stack vertically. Disabled tool styling uses the same compact padding. Actual paper at a1280x800 viewport is920x575; at1024x768 with the project's expanded logical viewport it is1132x707.5. The1024x640 backing image, aspect ratio, brush coordinates, saved PNGs, drafts, undo/redo and coloring metadata are unchanged.

## Validation

Focused scroll/paint suite:36 assertions,zero failures,EN/UK. Real viewport input covers home drag beginning on Play,pet selection after scroll,virtual catalog pan/inertia/stop/cancel,emulated mouse duplicates,extra fingers,normal game tap,settings wheel,vertical gestures over sliders,horizontal slider adjustment,compact tools,larger fitted paper,large-picker pan without selection,deliberate swatch tap and actual touch ink after closing the picker.

Full tools/Test-ScrollPaint.ps1 chain passed:all earlier foundation/game suites,cross-process persistence,release2067,UX834,celebration547,Feedback498,World940,Friends368,andScroll/Paint36;zero failures. See.local/logs/scroll-paint-full.log. Rendering:54captures,zero button-boundary issues,EN/UK at1280x800,1440x810,1024x768. Selected home/menu/settings/drawing and palette top/bottom images visually inspected. Existing gesture/virtualization UX suite also passed834assertions during implementation.

Early development checks caught a native owner-property naming collision and oversized disabled-button padding; both were corrected. White-on-white ink and repeated slider end-value expectations were corrected in fixtures. Final checks above refer to the corrected implementation/fixtures.

No new dependencies, downloads, speech changes, Git actions, tablet changes or APK export. Actual Android gesture feel remains user acceptance; current evidence is PC viewport input and rendered layouts.

Reproduce:tools/Test-ScrollPaint.ps1. Preview:tests/scroll_paint_native_review.tscn. Logs:.local/logs/scroll-paint-{full,focused,render}.log. Captures:.local/qa/scroll-paint.

Next:user PC review or explicitly requested tablet update. Existing artwork must stay intact.


## Home correction0.19.1

User clarified that companions must remain one horizontal strip at the bottom,with previous/next arrows beside the large companion. Replaced the home-only vertical page/grid with a fixed greeting/portrait area and one horizontal TouchScroll. Arrows cycle through all11friends,update saved selection/header/large portrait,and reveal the selected thumbnail. Deferred reveal waits for layout and ignores stale selection requests. TouchScroll now has an explicit horizontal axis;settings/catalog/palette continue to use vertical gestures.

PC source0.19.1/future Android code22;installed tablet remains0.18.0. Focused validation:UX834,Friends368,Scroll/Paint44 assertions passed.66render captures cover both languages/three ratios,strip ends and arrow selection. Earlier full0.19.0chain remains historical;it was not repeated for this small correction. No APK/device operations. Preview:tests/pet_row_native_review.tscn.
