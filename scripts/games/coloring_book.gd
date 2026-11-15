extends Control

var documents: Dictionary = {}
var dirty_pages: Dictionary = {}
var page_index := 0
var book_pages: Array[Dictionary]=[]
var selected := PaintDocument.COLORS[0]
var selected_paint := ""
var canvas := ColoringCanvas.new()
var column := UiKit.column(10)
var palette := PaintPalette.new()
var title: Label
var counter: Label
var status: Label
var previous: ChildButton
var next: ChildButton
var undo_button: ChildButton
var redo_button: ChildButton
var gallery: ArtworkGallery
var draft_timer := Timer.new()
var overlay_paused := false
var focus_paused := false
var reference_panel: VBoxContainer
var reference_picture: TextureRect
var reference_button: ChildButton

func _ready() -> void:
	book_pages=ColoringDocument.available_catalog()
	for page: Dictionary in ColoringDocument.catalog():
		documents[page.id] = ColoringDocument.new(page.id)
	var draft := ArtworkManager.load_color_draft()
	for id: String in draft.get("pages", {}):
		documents[id].restore(draft.pages[id])
		dirty_pages[id] = not documents[id].is_blank()
	for i: int in range(book_pages.size()):
		if book_pages[i].id == draft.get("last_page", ""):
			page_index = i
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var workspace := UiKit.row(10);workspace.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(workspace)
	var left_center := CenterContainer.new();workspace.add_child(left_center)
	var navigation := UiKit.column(6);navigation.custom_minimum_size.x=62;left_center.add_child(navigation)
	previous=UiKit.compact_tool_button("BACK",change_page.bind(-1),"previous");previous.name="PreviousPicture";navigation.add_child(previous)
	counter=UiKit.label("",18,UiKit.MUTED);counter.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;navigation.add_child(counter)
	next=UiKit.compact_tool_button("NEXT",change_page.bind(1),"next");next.name="NextPicture";navigation.add_child(next)
	var repeat := UiKit.compact_tool_button("SAY_HELLO",repeat_word,"speaker");repeat.name="RepeatWord";navigation.add_child(repeat)
	reference_button=UiKit.compact_tool_button("BOOK_EXAMPLE",toggle_reference,"palette");reference_button.name="ToggleReference";navigation.add_child(reference_button)
	canvas.size_flags_vertical=Control.SIZE_EXPAND_FILL;canvas.size_flags_horizontal=Control.SIZE_EXPAND_FILL;workspace.add_child(canvas)
	reference_panel=UiKit.column(8);reference_panel.custom_minimum_size.x=180;workspace.add_child(reference_panel)
	reference_panel.add_child(UiKit.label("BOOK_EXAMPLE",22,UiKit.GREEN))
	reference_picture=TextureRect.new();reference_picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;reference_picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;reference_picture.custom_minimum_size=Vector2(180,130);reference_picture.mouse_filter=Control.MOUSE_FILTER_IGNORE;reference_panel.add_child(reference_picture)
	var freedom := UiKit.paragraph("BOOK_EXAMPLE_HINT",18);freedom.custom_minimum_size.x=180;reference_panel.add_child(freedom)
	var right_center := CenterContainer.new();workspace.add_child(right_center)
	var right := UiKit.column(8);right.custom_minimum_size.x=104;right_center.add_child(right)
	palette.side_layout=true;palette.side_swatch_size=Vector2(44,40);right.add_child(palette);palette.paint_selected.connect(select_paint)
	var actions := GridContainer.new();actions.columns=2;actions.add_theme_constant_override("h_separation",6);actions.add_theme_constant_override("v_separation",6);right.add_child(actions)
	undo_button=UiKit.compact_tool_button("DRAW_UNDO",undo,"undo");undo_button.name="Undo";actions.add_child(undo_button)
	redo_button=UiKit.compact_tool_button("DRAW_REDO",redo,"redo");redo_button.name="Redo";actions.add_child(redo_button)
	for entry: Array in [["DRAW_SAVE","SaveColoring",save_picture,"save"],["GALLERY","OpenGallery",show_gallery,"gallery"],["BOOK_RESET","ResetColoring",request_reset,"clear"]]:
		var button := UiKit.compact_tool_button(entry[0],entry[2],entry[3]);button.name=entry[1];button.custom_minimum_size=Vector2(48,48);actions.add_child(button)
	canvas.region_pressed.connect(fill_at)
	var footer := UiKit.row(12);column.add_child(footer);footer.add_child(UiKit.label("BOOK_TITLE",20,UiKit.GREEN))
	title=UiKit.label("",22,UiKit.GREEN);footer.add_child(title);footer.add_child(UiKit.spacer())
	status=UiKit.label("BOOK_READY",18,UiKit.GREEN);footer.add_child(status)
	draft_timer.one_shot = true
	draft_timer.wait_time = 0.5
	add_child(draft_timer)
	draft_timer.timeout.connect(flush_draft)
	_show_page()
	if not ArtworkManager.pending_open_id.is_empty():
		var id := ArtworkManager.pending_open_id
		ArtworkManager.pending_open_id = ""
		call_deferred("request_open", id)
	AudioManager.say("BOOK_INTRO")

func document() -> ColoringDocument:
	return documents[book_pages[page_index].id]

func _show_page() -> void:
	canvas.pointer_owner = -2
	canvas.set_image(document().render_image())
	var bounds: Array=document().page.get("bounds",[0,0,1024,640]);canvas.source_bounds=Rect2(bounds[0],bounds[1],bounds[2],bounds[3]);canvas.queue_redraw()
	title.text = LocalizationManager.object_name(document().page)
	counter.text = str(page_index+1)+" / "+str(book_pages.size())
	previous.disabled = page_index == 0
	next.disabled = page_index == book_pages.size() - 1
	_update_reference()
	_update_controls()

func toggle_reference() -> void:
	SettingsManager.set_value("coloring_reference",not SettingsManager.values.coloring_reference)
	_update_reference()

func _update_reference() -> void:
	reference_panel.visible=SettingsManager.values.coloring_reference
	if reference_panel.visible:
		var image := ColoringDocument.reference_image(document().page.id)
		reference_picture.texture=ImageTexture.create_from_image(image) if image!=null else null
	reference_button.add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if reference_panel.visible else UiKit.CREAM,16,8))

func _update_controls() -> void:
	undo_button.disabled = document().cursor == 0
	redo_button.disabled = document().cursor == document().history.size()
	for i: int in range(PaintDocument.COLORS.size()):
		var color: Color = PaintDocument.COLORS[i] if i < PaintDocument.COLORS.size() else Color.WHITE
		var style := UiKit.panel(color, 18, 8)
		style.set_border_width_all(4 if color == selected else 0)
		style.border_color = UiKit.GREEN if color == Color.WHITE else Color.WHITE
		var swatch: Button=palette.find_child("Color_"+str(i),true,false)
		if swatch!=null:swatch.add_theme_stylebox_override("normal",style)

func select_paint(value: String) -> void:
	selected_paint=value
	if not value.begins_with("gradient:"): selected=Color(value)
	_update_controls()

func select_color(color: Color) -> void:
	selected = color
	selected_paint=""
	_update_controls()

func fill_at(point: Vector2) -> void:
	if overlay_paused or focus_paused or is_instance_valid(gallery):
		return
	if document().fill_paint(point,selected_paint if not selected_paint.is_empty() else selected.to_html(false)):
		_changed()

func _changed() -> void:
	dirty_pages[document().page.id] = true
	canvas.set_image(document().render_image())
	_update_controls()
	status.text = LocalizationManager.text("BOOK_READY")
	draft_timer.start()

func undo() -> void:
	if document().undo():
		_changed()

func redo() -> void:
	if document().redo():
		_changed()

func change_page(delta: int) -> void:
	page_index = clampi(page_index + delta, 0, book_pages.size() - 1)
	_show_page()
	flush_draft()
	repeat_word()

func repeat_word() -> void:
	AudioManager.say(document().page.word_key)

func _app() -> Node:
	return get_tree().get_first_node_in_group("app_root")

func request_reset() -> void:
	if document().is_blank():
		return
	_app()._show_confirmation("BOOK_RESET_TITLE","BOOK_RESET_HINT","BOOK_RESET_CONFIRM",reset_picture)
	set_overlay_paused(true)

func reset_picture() -> void:
	if document().reset():
		_changed()
		flush_draft()

func flush_draft() -> void:
	draft_timer.stop()
	var states := {}
	for id: String in documents:
		states[id] = documents[id].state()
	if not ArtworkManager.save_color_draft({"version":1,"last_page":document().page.id,"pages":states}):
		status.text = LocalizationManager.text("SAVE_ERROR")

func save_picture() -> void:
	if document().is_blank():
		return
	if not dirty_pages.get(document().page.id, false):
		status.text = LocalizationManager.text("BOOK_SAVED")
		return
	var id := ArtworkManager.save_artwork(canvas.image, document().state())
	if id.is_empty():
		status.text = LocalizationManager.text("DRAW_FULL" if ArtworkManager.last_error == ERR_OUT_OF_MEMORY else "SAVE_ERROR")
	else:
		dirty_pages[document().page.id] = false
		flush_draft()
		status.text = LocalizationManager.text("BOOK_SAVED")
		AudioManager.say("BOOK_SAVED")

func show_gallery() -> void:
	flush_draft()
	column.hide()
	gallery = ArtworkGallery.new()
	add_child(gallery)
	gallery.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gallery.opened.connect(request_open)
	gallery.back_requested.connect(close_gallery)
	_update_pause()

func close_gallery() -> void:
	if is_instance_valid(gallery):
		remove_child(gallery)
		gallery.queue_free()
	gallery = null
	column.show()
	_update_pause()

func request_open(id: String) -> void:
	if ArtworkManager.artwork_route(id) != "coloring":
		ArtworkManager.pending_open_id = id
		GameManager.start_game("drawing")
		return
	var state := ArtworkManager.coloring_state(id)
	if state.is_empty():
		return
	if dirty_pages.get(state.page, false):
		_app()._show_confirmation("DRAW_REPLACE_TITLE","DRAW_REPLACE_HINT","DRAW_OPEN",load_picture.bind(id))
		set_overlay_paused(true)
	else:
		load_picture(id)

func load_picture(id: String) -> void:
	var state := ArtworkManager.coloring_state(id)
	if state.is_empty() or not documents[state.page].restore(state):
		status.text = LocalizationManager.text("DRAW_DAMAGED")
		return
	# Archived pages are reachable only by explicitly opening existing artwork.
	if not book_pages.any(func(item: Dictionary) -> bool:return item.id==state.page):
		book_pages.append(documents[state.page].page)
	for i: int in range(book_pages.size()):
		if book_pages[i].id == state.page:
			page_index = i
	dirty_pages[state.page] = false
	close_gallery()
	_show_page()
	flush_draft()

func handle_back() -> bool:
	if is_instance_valid(gallery):
		close_gallery()
		return true
	return false

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	_update_pause()
	if value:
		flush_draft()

func _update_pause() -> void:
	canvas.set_paused(overlay_paused or focus_paused or is_instance_valid(gallery))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		_update_pause()
		if is_instance_valid(status):
			flush_draft()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		_update_pause()

func _exit_tree() -> void:
	flush_draft()
	AudioManager.stop_voice()
