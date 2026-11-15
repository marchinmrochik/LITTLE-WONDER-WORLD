extends Control

var canvas := PaintCanvas.new()
var column := UiKit.column(6)
var stage := UiKit.row(8)
var palette := PaintPalette.new()
var status: Label
var undo_button: ChildButton
var redo_button: ChildButton
var gallery: ArtworkGallery
var draft_timer := Timer.new()
var overlay_paused := false
var focus_paused := false
var unpublished := false

func _ready() -> void:
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inset := MarginContainer.new();inset.size_flags_vertical=Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_top",32);inset.add_theme_constant_override("margin_bottom",16);column.add_child(inset)
	stage.size_flags_vertical=Control.SIZE_EXPAND_FILL;inset.add_child(stage)
	var right := UiKit.column(14);right.name="DrawingActions";right.custom_minimum_size.x=110
	palette.side_layout=true;right.add_child(palette)
	var actions := GridContainer.new();actions.columns=2;actions.add_theme_constant_override("h_separation",6);actions.add_theme_constant_override("v_separation",6);right.add_child(actions)
	undo_button = UiKit.compact_tool_button("DRAW_UNDO", undo, "undo");undo_button.name="Undo";actions.add_child(undo_button)
	redo_button = UiKit.compact_tool_button("DRAW_REDO", redo, "redo");redo_button.name="Redo";actions.add_child(redo_button)
	for entry: Array in [["DRAW_SAVE", "SaveDrawing", save_picture], ["GALLERY", "OpenGallery", show_gallery], ["DRAW_CLEAR", "ClearDrawing", request_clear]]:
		var button := UiKit.compact_tool_button(entry[0],entry[2],{"SaveDrawing":"save","OpenGallery":"gallery","ClearDrawing":"clear"}[entry[1]])
		button.name=entry[1];actions.add_child(button)
	palette.paint_selected.connect(select_paint)

	var tools := UiKit.column(6)
	tools.name="DrawingTools"
	tools.custom_minimum_size.x = 68
	var left_center := CenterContainer.new();left_center.name="LeftToolsRail";stage.add_child(left_center);left_center.add_child(tools)
	for tool: String in PaintDocument.TOOLS:
		var button := UiKit.compact_tool_button("DRAW_" + tool.to_upper(), select_tool.bind(tool), tool)
		button.name = "Tool_" + tool
		tools.add_child(button)
	
	var sizes := UiKit.column(6)
	tools.add_child(sizes)
	for radius: int in [4, 10, 20]:
		var button := UiKit.compact_tool_button("DRAW_SIZE", select_size.bind(radius), "size_" + str(radius))
		button.name = "Size_" + str(radius)
		button.tooltip_text = LocalizationManager.text("DRAW_SIZE") + " " + str(radius * 2)
		button.custom_minimum_size = Vector2(54, 48)
		sizes.add_child(button)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_child(canvas)
	var right_center := CenterContainer.new();right_center.name="RightPaintRail";stage.add_child(right_center);right_center.add_child(right)
	var footer := UiKit.row(14);column.add_child(footer);footer.add_child(UiKit.label("DRAW_TITLE",22,UiKit.GREEN))
	status = UiKit.label("DRAW_READY",18,UiKit.GREEN);status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;status.size_flags_horizontal=Control.SIZE_EXPAND_FILL;footer.add_child(status)
	draft_timer.one_shot = true
	draft_timer.wait_time = 0.65
	add_child(draft_timer)
	draft_timer.timeout.connect(flush_draft)
	canvas.stroke_committed.connect(_changed)
	var draft := ArtworkManager.load_draft()
	if draft != null:
		canvas.document.load_image(draft)
		canvas.refresh()
		unpublished = not canvas.document.is_blank()
	_update_controls()
	if not ArtworkManager.pending_open_id.is_empty():
		var id := ArtworkManager.pending_open_id
		ArtworkManager.pending_open_id = ""
		call_deferred("request_open", id)
	AudioManager.say("DRAW_INTRO")

func _app() -> Node:
	return get_tree().get_first_node_in_group("app_root")

func _changed() -> void:
	unpublished = true
	status.text = LocalizationManager.text("DRAW_READY")
	draft_timer.start()
	_update_controls()

func _update_controls() -> void:
	undo_button.disabled = canvas.document.cursor == 0
	redo_button.disabled = canvas.document.cursor == canvas.document.history.size()
	for index: int in range(PaintDocument.COLORS.size()):
		var button := palette.find_child("Color_" + str(index), true, false) as Button
		var style := UiKit.panel(PaintDocument.COLORS[index], 18, 8)
		style.set_border_width_all(4 if canvas.document.color == PaintDocument.COLORS[index] else 0)
		style.border_color = Color.WHITE
		button.add_theme_stylebox_override("normal", style)
	for tool: String in PaintDocument.TOOLS:
		var button := stage.find_child("Tool_" + tool, true, false) as Button
		button.add_theme_stylebox_override("normal", UiKit.panel(UiKit.MINT if tool == canvas.document.tool else UiKit.CREAM, 18, 8))
	for radius: int in [4, 10, 20]:
		var button := stage.find_child("Size_" + str(radius), true, false) as Button
		button.add_theme_stylebox_override("normal", UiKit.panel(UiKit.MINT if radius == canvas.document.radius else UiKit.CREAM, 18, 8))

func select_paint(value: String) -> void:
	canvas.finish_stroke()
	var parts := value.split(":")
	canvas.document.gradient_enabled=parts.size()==3
	canvas.document.color=Color(parts[1] if parts.size()==3 else value)
	canvas.document.gradient_to=Color(parts[2]) if parts.size()==3 else Color.WHITE
	if canvas.document.tool in ["eraser","rainbow"]: canvas.document.tool="regular"
	_update_controls()

func select_color(index: int) -> void:
	canvas.finish_stroke()
	canvas.document.color = PaintDocument.COLORS[index]
	canvas.document.gradient_enabled=false
	if canvas.document.tool == "eraser":
		canvas.document.tool = "regular"
	_update_controls()

func select_tool(tool: String) -> void:
	canvas.finish_stroke()
	canvas.document.tool = tool
	_update_controls()

func select_size(radius: int) -> void:
	canvas.finish_stroke()
	canvas.document.radius = radius
	_update_controls()

func undo() -> void:
	canvas.finish_stroke()
	if canvas.document.undo():
		canvas.refresh()
		_changed()

func redo() -> void:
	canvas.finish_stroke()
	if canvas.document.redo():
		canvas.refresh()
		_changed()

func request_clear() -> void:
	canvas.finish_stroke()
	if canvas.document.is_blank():
		return
	_app()._show_confirmation("DRAW_CLEAR_TITLE", "DRAW_CLEAR_HINT", "DRAW_CLEAR_CONFIRM", clear_picture)
	set_overlay_paused(true)

func clear_picture() -> void:
	if canvas.document.clear():
		canvas.refresh()
		_changed()
		flush_draft()

func flush_draft() -> void:
	draft_timer.stop()
	if unpublished:
		if not ArtworkManager.save_draft(canvas.document.image):
			status.text = LocalizationManager.text("SAVE_ERROR")

func save_picture() -> void:
	canvas.finish_stroke()
	if not unpublished:
		status.text = LocalizationManager.text("DRAW_SAVED")
		return
	if canvas.document.is_blank():
		status.text = LocalizationManager.text("DRAW_READY")
		return
	var id := ArtworkManager.save_artwork(canvas.document.image)
	if id.is_empty():
		status.text = LocalizationManager.text("DRAW_FULL" if ArtworkManager.last_error == ERR_OUT_OF_MEMORY else "SAVE_ERROR")
	else:
		unpublished = false
		ArtworkManager.save_draft(canvas.document.image)
		status.text = LocalizationManager.text("DRAW_SAVED")
		AudioManager.say("DRAW_SAVED")

func show_gallery() -> void:
	canvas.finish_stroke()
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
	if ArtworkManager.artwork_route(id) == "coloring":
		ArtworkManager.pending_open_id = id
		GameManager.start_game("coloring")
		return
	if unpublished and not canvas.document.is_blank():
		_app()._show_confirmation("DRAW_REPLACE_TITLE", "DRAW_REPLACE_HINT", "DRAW_OPEN", load_picture.bind(id))
		set_overlay_paused(true)
	else:
		load_picture(id)

func load_picture(id: String) -> void:
	var image := ArtworkManager.load_artwork(id)
	if image == null:
		status.text = LocalizationManager.text("DRAW_DAMAGED")
		return
	canvas.document.load_image(image)
	canvas.refresh()
	unpublished = false
	ArtworkManager.save_draft(image)
	close_gallery()
	_update_controls()
	status.text = LocalizationManager.text("DRAW_READY")

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
	canvas.finish_stroke()
	flush_draft()
	AudioManager.stop_voice()
