extends Control

const ROW_HEIGHT := 248.0
const COLUMNS := 4
var entries_offset := 0
var scroll := TouchScroll.new()
var choices := Control.new()
var cells: Array[ChildButton] = []
var overlay_paused := false
var binding_signature := ""
var restore_offset := 0
var entries := [
	{"node":"AnimalsButton", "title":"ANIMALS_TITLE", "art":"res://assets/objects/animals/cat.svg", "route":"animals"},
	{"node":"ColorsButton", "title":"COLORS_TITLE", "art":"res://assets/objects/colors/blue.svg", "route":"colors"},
	{"node":"FeedingButton", "title":"FEED_TITLE", "art":"res://assets/objects/food/apple.svg", "route":"feeding"},
	{"node":"ShapesButton", "title":"SHAPES_TITLE", "art":"res://assets/objects/shapes/star.svg", "route":"shapes"},
	{"node":"PuzzlesButton", "title":"PUZZLES_TITLE", "art":"res://assets/objects/animals/rabbit.svg", "route":"puzzles"},
	{"node":"MemoryButton", "title":"MEMORY_TITLE", "art":"res://assets/ui/memory_back.svg", "route":"memory"},
	{"node":"CountingButton", "title":"COUNT_TITLE", "art":"res://assets/objects/counting/basket.svg", "route":"counting"},
	{"node":"DrawWordButton","title":"CROC_TITLE","art":"res://assets/ui/draw_word.svg","route":"draw_word"},
	{"node":"DrawingButton", "title":"DRAW_TITLE", "art":"res://assets/ui/drawing.svg", "route":"drawing"},
	{"node":"ColoringButton", "title":"BOOK_TITLE", "art":"res://assets/ui/coloring.svg", "route":"coloring"},
	{"node":"XylophoneButton", "title":"XYLO_TITLE", "art":"res://assets/ui/xylophone.svg", "route":"xylophone"},
	{"node":"LettersButton","title":"ALPH_TITLE","art":"res://assets/ui/letters.svg","route":"letters"},
	{"node":"SyllablesButton","title":"BLEND_TITLE","art":"res://assets/ui/syllables.svg","route":"syllables"},
	{"node":"BalloonsButton","title":"BALLOONS_TITLE","art":"res://assets/ui/balloons.svg","route":"balloons"},
	{"node":"LivingDrawingButton","title":"LIVE_TITLE","art":"res://assets/ui/living_house.svg","route":"living_gallery"},
	{"node":"WorldButton","title":"WORLD_TITLE","art":"res://assets/objects/world/flower.svg","route":"world"},
]

func _ready() -> void:
	restore_offset = GameManager.activities_scroll
	var column := UiKit.column(14)
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("ACTIVITIES_TITLE",38)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(DifficultyStrip.new())
	scroll.name = "ActivitiesScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.scroll_deadzone = 18
	column.add_child(scroll)
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(choices)
	scroll.get_v_scroll_bar().value_changed.connect(func(_v: float) -> void: _sync_cells())
	scroll.resized.connect(func() -> void: call_deferred("_sync_cells"))
	var companion := UiKit.button("MEADOW_TITLE",func() -> void: GameManager.navigate("meadow"),UiKit.MINT)
	companion.name = "MeadowButton"
	companion.icon = load(CompanionCatalog.illustration(SettingsManager.values.companion))
	companion.add_theme_constant_override("icon_max_width",44)
	column.add_child(companion)
	call_deferred("_restore_scroll")

func _restore_scroll() -> void:
	if not is_inside_tree(): return
	var tree := get_tree()
	await tree.process_frame
	if not is_inside_tree(): return
	_sync_cells()
	await tree.process_frame
	if not is_inside_tree(): return
	scroll.scroll_vertical = restore_offset
	_sync_cells()

func _sync_cells() -> void:
	if not is_inside_tree() or scroll.size.y <= 0:
		return
	choices.custom_minimum_size = Vector2(0,ceili(entries.size()/float(COLUMNS))*ROW_HEIGHT)
	var first := maxi(0,int(scroll.scroll_vertical/ROW_HEIGHT)-1)*COLUMNS
	var count := mini(entries.size()-first,(ceili(scroll.size.y/ROW_HEIGHT)+2)*COLUMNS)
	var width := maxf(200,scroll.size.x-scroll.get_v_scroll_bar().size.x)
	var signature := str([first,count,width,entries.size(),SettingsManager.values.locale])
	GameManager.activities_scroll=scroll.scroll_vertical
	if signature==binding_signature:return
	binding_signature=signature
	while cells.size() < count:
		var button := UiKit.button("",func() -> void: pass,UiKit.CREAM)
		button.pressed.connect(func() -> void:
			if not overlay_paused and not scroll.dragging:
				GameManager.navigate(str(button.get_meta("route")))
		)
		choices.add_child(button)
		var row := UiKit.column(6)
		button.add_child(row)
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row.offset_left=18;row.offset_right=-18;row.offset_top=16;row.offset_bottom=-16
		row.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var picture := TextureRect.new()
		picture.custom_minimum_size=Vector2(90,125)
		picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
		row.add_child(picture)
		var label := UiKit.label("",23)
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		label.size_flags_vertical=Control.SIZE_SHRINK_CENTER
		row.add_child(label)
		cells.append(button)
	for cell: ChildButton in cells:
		cell.name="VirtualCell_"+str(cell.get_instance_id())
	for i: int in range(cells.size()):
		var button := cells[i]
		button.visible=i<count
		if not button.visible:
			button.name="UnusedCell_"+str(i)
			continue
		var index := first+i
		var item: Dictionary=entries[index]
		button.name=item.node
		button.set_meta("route",item.route)
		button.set_meta("index",index)
		button.position=Vector2((index%COLUMNS)*width/COLUMNS,(index/COLUMNS)*ROW_HEIGHT)
		button.size=Vector2(width/COLUMNS-12,ROW_HEIGHT-14)
		var row := button.get_child(0)
		row.get_child(0).texture=load(item.art)
		row.get_child(1).text=LocalizationManager.text(item.title)
	GameManager.activities_scroll=scroll.scroll_vertical

func ensure_activity(id: String) -> void:
	if id=="living_drawing":id="living_gallery"
	for index: int in range(entries.size()):
		if id in [entries[index].node,entries[index].route]:
			scroll.scroll_vertical=int((index/COLUMNS)*ROW_HEIGHT)
			_sync_cells()
			return

# Compatibility for older rendering fixtures only; no pagination controls in UI.
func set_page(value: int) -> void:
	var index := clampi(value*4,0,entries.size()-1)
	ensure_activity(entries[index].route)

func get_idle_action() -> Dictionary:
	for cell: ChildButton in cells:
		if cell.visible and scroll.get_global_rect().encloses(cell.get_global_rect()):
			return {"from":cell.get_global_rect().get_center()}
	return {}

func set_overlay_paused(value: bool) -> void:
	overlay_paused=value;scroll.interaction_enabled=not value;scroll.cancel_gesture()
