extends Control

enum State { BUILDING, FEEDBACK, PICTURE_DONE, COMPLETE }
var state := State.BUILDING
var model: PuzzleRound
var drag := PointerDrag.new()
var body := UiKit.column(12)
var feedback_timer := Timer.new()
var board_surface: Control
var template: TextureRect
var hint_button: ChildButton
var next_button: ChildButton
var message: Label
var fox: FoxieView
var source_cards: Dictionary = {}
var slots: Dictionary = {}
var slot_pictures: Dictionary = {}
var preview: TextureRect
var drag_piece := -1
var atlas: Texture2D
var hint_visible := true
var overlay_paused := false
var focus_paused := false
var session_awarded := false
var snap_tween: Tween
var celebration: Tween

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.puzzles:
		ids.append(entry.id)
	model = PuzzleRound.new(ids)
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(drag)
	drag.moved.connect(_move_preview)
	drag.released.connect(_release_piece)
	drag.canceled.connect(_restore_drag)
	feedback_timer.one_shot = true
	add_child(feedback_timer)
	feedback_timer.timeout.connect(_finish_feedback)
	start_session()

func _entry() -> Dictionary:
	for entry: Dictionary in ContentManager.puzzles:
		if entry.id == model.picture_id():
			return entry
	return {}

func start_session() -> void:
	session_awarded = false
	if model.begin(SettingsManager.values.difficulty):
		hint_visible = SettingsManager.values.difficulty == "easy"
		_show_picture()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	drag.cancel()
	_restore_drag()
	feedback_timer.stop()
	if snap_tween != null:
		snap_tween.kill()
	if celebration != null:
		celebration.kill()
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	source_cards.clear()
	slots.clear()
	slot_pictures.clear()

func _show_picture() -> void:
	_clear_body()
	state = State.BUILDING
	atlas = load(_entry().illustration)
	var heading := UiKit.row(12)
	body.add_child(heading)
	heading.add_child(UiKit.label("PUZZLES_TITLE", 30, UiKit.GREEN))
	heading.add_child(UiKit.spacer())
	heading.add_child(UiKit.label("PUZZLES_HINT", 25))
	var prompt := UiKit.row(14)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(96, 76)
	prompt.add_child(fox)
	fox.set_state("thinking")
	message = UiKit.label("PUZZLES_INTRO", 28)
	message.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(message)
	var repeat := UiKit.button("", repeat_instruction, UiKit.MINT, "speaker")
	repeat.name = "RepeatPrompt"
	repeat.custom_minimum_size.x = 76
	repeat.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(repeat)
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var play_area := UiKit.row(44)
	center.add_child(play_area)
	var frame := UiKit.card()
	frame.name = "PuzzleBoard"
	frame.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 24, 16))
	play_area.add_child(frame)
	board_surface = Control.new()
	board_surface.custom_minimum_size = Vector2(360, 360)
	frame.add_child(board_surface)
	template = _picture(atlas)
	template.modulate.a = 0.23
	board_surface.add_child(template)
	template.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	template.visible = hint_visible
	for piece: int in range(model.piece_count()):
		var target := Panel.new()
		target.name = "PuzzleSlot_" + str(piece)
		var region := model.region(piece, Vector2(360, 360))
		target.position = region.position
		target.size = region.size
		target.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_surface.add_child(target)
		var image := _picture(_piece_texture(piece))
		target.add_child(image)
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.visible = false
		slots[piece] = target
		slot_pictures[piece] = image
	var tray_center := CenterContainer.new()
	play_area.add_child(tray_center)
	var tray := GridContainer.new()
	tray.name = "PuzzleTray"
	tray.columns = 3 if model.piece_count() == 6 else 2
	tray.add_theme_constant_override("h_separation", 12)
	tray.add_theme_constant_override("v_separation", 12)
	tray_center.add_child(tray)
	for piece: int in model.tray_order:
		var card := DragCard.new()
		card.name = "Piece_" + str(piece)
		card.item_id = str(piece)
		card.custom_minimum_size = Vector2(144, 164)
		card.focus_mode = Control.FOCUS_ALL
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 20, 12))
		card.grabbed.connect(func(id: String, pointer: int, point: Vector2) -> void: begin_drag(int(id), pointer, point))
		card.word_requested.connect(func(_id: String) -> void: repeat_word())
		tray.add_child(card)
		var picture := _picture(_piece_texture(piece))
		picture.custom_minimum_size = Vector2(120, 140)
		card.add_child(picture)
		source_cards[piece] = card
	var footer := UiKit.row(12)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(footer)
	var count := UiKit.label("", 23, UiKit.GREEN)
	count.text = LocalizationManager.text("PUZZLES_PROGRESS").format({"current": model.index + 1, "total": PuzzleRound.PICTURES_PER_SESSION})
	footer.add_child(count)
	var word := UiKit.button("", repeat_word, UiKit.MINT, "speaker")
	word.name = "RepeatWord"
	word.text = LocalizationManager.object_name(_entry())
	footer.add_child(word)
	hint_button = UiKit.button("PUZZLES_TEMPLATE", toggle_hint, UiKit.CREAM, "search")
	hint_button.name = "PictureHint"
	hint_button.toggle_mode = true
	hint_button.button_pressed = hint_visible
	footer.add_child(hint_button)
	var restart := UiKit.button("PUZZLES_RESTART", restart_picture, UiKit.CREAM, "replay")
	restart.name = "RestartPicture"
	footer.add_child(restart)
	next_button = UiKit.button("PUZZLES_NEXT", next_picture, UiKit.MINT, "next")
	next_button.name = "NextPicture"
	next_button.disabled = true
	footer.add_child(next_button)
	_highlight(-1)
	AudioManager.say("PUZZLES_INTRO")

func _picture(texture: Texture2D) -> TextureRect:
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image

func _piece_texture(piece: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = model.region(piece, atlas.get_size())
	texture.filter_clip = true
	return texture

func toggle_hint() -> void:
	hint_visible = not hint_visible
	template.visible = hint_visible
	hint_button.button_pressed = hint_visible

func repeat_word() -> void:
	if state != State.COMPLETE:
		AudioManager.say(_entry().word_key)

func repeat_instruction() -> void:
	if state == State.BUILDING:
		AudioManager.say("PUZZLES_INTRO")

func restart_picture() -> void:
	if overlay_paused or focus_paused or state == State.COMPLETE:
		return
	model.reset_picture()
	_show_picture()

func begin_drag(piece: int, pointer: int, point: Vector2) -> void:
	if not overlay_paused and not focus_paused and state == State.FEEDBACK and not model.picture_complete():
		_finish_feedback()
	if state != State.BUILDING or overlay_paused or focus_paused or not source_cards.has(piece) or piece in model.placed:
		return
	if not drag.begin(pointer, point):
		return
	drag_piece = piece
	preview = _picture(_piece_texture(piece))
	# Match the target aspect ratio, but keep the preview small enough for the tray.
	var cell := model.region(piece, Vector2(360, 360)).size
	preview.size = cell * minf(1.0, 180.0 / maxf(cell.x, cell.y))
	preview.z_index = 20
	add_child(preview)
	preview.global_position = point - preview.size * 0.5
	source_cards[piece].modulate.a = 0.3
	_highlight(-1)

func _slot_at(point: Vector2) -> int:
	var best := -1
	var distance := INF
	for piece: int in slots:
		if piece in model.placed:
			continue
		var rect: Rect2 = slots[piece].get_global_rect()
		var candidate := rect.get_center().distance_squared_to(point)
		if rect.grow(10).has_point(point) and candidate < distance:
			best = piece
			distance = candidate
	return best

func _move_preview(point: Vector2) -> void:
	if is_instance_valid(preview):
		preview.global_position = point - preview.size * 0.5
	_highlight(_slot_at(point))

func _highlight(hover: int) -> void:
	for piece: int in slots:
		var style := UiKit.panel(Color(0, 0, 0, 0), 0, 0)
		style.set_border_width_all(3 if piece == drag_piece and piece not in model.placed else 1)
		style.border_color = UiKit.GREEN if piece == hover and piece == drag_piece else Color("baa46c") if piece == drag_piece else Color("cbd6c3")
		slots[piece].add_theme_stylebox_override("panel", style)

func _release_piece(point: Vector2, traveled: bool) -> void:
	var piece := drag_piece
	var slot := _slot_at(point)
	if not traveled or slot == -1:
		_restore_drag()
		return
	var result := model.submit(piece, slot)
	if result == "ignored":
		_restore_drag()
		return
	state = State.FEEDBACK
	ProgressManager.record_answer("puzzles", model.picture_id(), result == "correct", result == "correct")
	message.text = LocalizationManager.text("PUZZLES_CORRECT" if result == "correct" else "PUZZLES_RETRY")
	fox.set_state("happy" if result == "correct" else "encouraging")
	AudioManager.say("PUZZLES_CORRECT" if result == "correct" else "PUZZLES_RETRY")
	if result == "correct":
		source_cards[piece].modulate.a = 0.0
		source_cards[piece].mouse_filter = Control.MOUSE_FILTER_IGNORE
		source_cards[piece].focus_mode = Control.FOCUS_NONE
		AudioManager.play_sfx("sparkle")
		if SettingsManager.values.reduced_motion:
			_reveal_piece(piece)
		else:
			snap_tween = create_tween().set_parallel(true)
			snap_tween.tween_property(preview, "global_position", slots[slot].global_position, 0.22)
			snap_tween.tween_property(preview, "size", slots[slot].size, 0.22)
			snap_tween.chain().tween_callback(_reveal_piece.bind(piece))
	elif SettingsManager.values.reduced_motion:
		_restore_drag()
	else:
		snap_tween = create_tween()
		snap_tween.tween_property(preview, "global_position", source_cards[piece].get_global_rect().get_center() - preview.size * 0.5, 0.22)
		snap_tween.tween_callback(_restore_drag)
	var duration := 0.9
	if AudioManager.voice.playing:
		duration = maxf(duration, AudioManager.voice.stream.get_length() + 0.15)
	feedback_timer.start(duration)

func _reveal_piece(piece: int) -> void:
	if slot_pictures.has(piece):
		slot_pictures[piece].visible = true
	_restore_drag()

func _restore_drag() -> void:
	if source_cards.has(drag_piece) and drag_piece not in model.placed:
		source_cards[drag_piece].modulate.a = 1.0
	drag_piece = -1
	if is_instance_valid(preview):
		preview.queue_free()
	preview = null
	_highlight(-1)

func _finish_feedback() -> void:
	if state != State.FEEDBACK:
		return
	feedback_timer.stop()
	if snap_tween != null:
		snap_tween.kill()
	for piece: int in model.placed:
		slot_pictures[piece].visible = true
	_restore_drag()
	if model.picture_complete():
		if model.index + 1 == PuzzleRound.PICTURES_PER_SESSION:
			model.advance()
			_show_complete()
		else:
			state = State.PICTURE_DONE
			message.text = LocalizationManager.text("PUZZLES_PICTURE_DONE")
			fox.set_state("celebrating")
			next_button.disabled = false
			AudioManager.say("PUZZLES_PICTURE_DONE")
			_celebrate()
	else:
		state = State.BUILDING
		message.text = LocalizationManager.text("PUZZLES_INTRO")
		fox.set_state("thinking")

func _celebrate() -> void:
	if SettingsManager.values.reduced_motion:
		return
	board_surface.pivot_offset = board_surface.size * 0.5
	celebration = create_tween()
	celebration.tween_property(board_surface, "scale", Vector2.ONE * 1.035, 0.18)
	celebration.tween_property(board_surface, "scale", Vector2.ONE, 0.18)

func next_picture() -> void:
	if state == State.PICTURE_DONE and not overlay_paused and not focus_paused and model.advance():
		_show_picture()

func _show_complete() -> void:
	if state == State.COMPLETE and session_awarded: return
	_clear_body()
	state = State.COMPLETE
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed("puzzles")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var card := UiKit.card()
	card.custom_minimum_size = Vector2(760, 430)
	center.add_child(card)
	var column := UiKit.column(18)
	card.add_child(column)
	var title := UiKit.label("PUZZLES_COMPLETE", 34, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(300, 250)
	column.add_child(fox)
	fox.set_state("celebrating")
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.MINT, "replay")
	replay.name = "Replay"
	column.add_child(replay)
	AudioManager.say("PUZZLES_COMPLETE")
	CompletionCelebration.mount(self)

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	if value:
		drag.cancel()
	_update_pause()

func _update_pause() -> void:
	var paused := overlay_paused or focus_paused
	feedback_timer.paused = paused
	for tween: Tween in [snap_tween, celebration]:
		if tween != null and tween.is_valid():
			if paused:
				tween.pause()
			else:
				tween.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		drag.cancel()
		_update_pause()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		_update_pause()

func _exit_tree() -> void:
	drag.cancel()
	_restore_drag()
	feedback_timer.stop()
	if snap_tween != null:
		snap_tween.kill()
	if celebration != null:
		celebration.kill()
	AudioManager.stop_voice()
