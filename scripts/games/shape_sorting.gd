extends Control

enum State { SORTING, FEEDBACK, COMPLETE }
var state := State.SORTING
var model: ShapeBoard
var drag := PointerDrag.new()
var body := UiKit.column(16)
var feedback_timer := Timer.new()
var source_cards: Dictionary = {}
var slots: Dictionary = {}
var slot_pictures: Dictionary = {}
var preview: TextureRect
var drag_id := ""
var selected_id := ""
var word_button: ChildButton
var message: Label
var fox: FoxieView
var overlay_paused := false
var focus_paused := false
var session_awarded := false
var snap_tween: Tween

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.shapes:
		ids.append(entry.id)
	model = ShapeBoard.new(ids)
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

func _entry(id: String) -> Dictionary:
	for entry: Dictionary in ContentManager.shapes:
		if entry.id == id:
			return entry
	return {}

func start_session() -> void:
	session_awarded = false
	if model.begin(SettingsManager.values.difficulty):
		_show_board()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	drag.cancel()
	_restore_drag()
	feedback_timer.stop()
	if snap_tween != null:
		snap_tween.kill()
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	source_cards.clear()
	slots.clear()
	slot_pictures.clear()

func _show_board() -> void:
	_clear_body()
	state = State.SORTING
	selected_id = model.sources[0]
	var heading := UiKit.row(12)
	body.add_child(heading)
	heading.add_child(UiKit.label("SHAPES_TITLE", 30, UiKit.GREEN))
	heading.add_child(UiKit.spacer())
	heading.add_child(UiKit.label("SHAPES_HINT", 25))
	var prompt := UiKit.row(14)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(100, 82)
	prompt.add_child(fox)
	fox.set_state("thinking")
	message = UiKit.label("SHAPES_INTRO", 29)
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
	var target_row := UiKit.row(24)
	center.add_child(target_row)
	for id: String in model.targets:
		var slot := UiKit.button("", select_word.bind(id), UiKit.CREAM)
		slot.name = "Slot_" + id
		slot.custom_minimum_size = Vector2(204, 220)
		target_row.add_child(slot)
		var picture := _picture(_entry(id).slot, Vector2(180, 180))
		slot.add_child(picture)
		picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		picture.offset_left = 14
		picture.offset_right = -14
		picture.offset_top = 14
		picture.offset_bottom = -14
		slots[id] = slot
		slot_pictures[id] = picture
	var tray := UiKit.row(24)
	tray.name = "ShapeTray"
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(tray)
	for id: String in model.sources:
		var card := DragCard.new()
		card.item_id = id
		card.name = "Shape_" + id
		card.custom_minimum_size = Vector2(204, 184)
		card.focus_mode = Control.FOCUS_ALL
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 24, 10))
		card.grabbed.connect(begin_drag)
		card.word_requested.connect(select_word)
		tray.add_child(card)
		var column := UiKit.column(2)
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(column)
		column.add_child(_picture(_entry(id).illustration, Vector2(150, 124)))
		var label := UiKit.label("", 25)
		label.text = LocalizationManager.object_name(_entry(id))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(label)
		source_cards[id] = card
	var footer := UiKit.row(16)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(footer)
	var progress := UiKit.label("", 24, UiKit.GREEN)
	progress.text = LocalizationManager.text("SHAPES_BOARD").format({"current": model.index + 1, "total": ShapeBoard.BOARD_COUNT})
	footer.add_child(progress)
	word_button = UiKit.button("", repeat_word, UiKit.MINT, "speaker")
	word_button.name = "RepeatWord"
	word_button.text = LocalizationManager.object_name(_entry(selected_id))
	word_button.tooltip_text = LocalizationManager.text("SHAPES_REPEAT")
	footer.add_child(word_button)
	AudioManager.say("SHAPES_INTRO")

func _picture(path: String, minimum: Vector2) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = load(path)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = minimum
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture

func select_word(id: String) -> void:
	if state != State.SORTING or overlay_paused or focus_paused or id not in model.sources:
		return
	selected_id = id
	word_button.text = LocalizationManager.object_name(_entry(id))
	repeat_word()

func repeat_word() -> void:
	if state == State.SORTING:
		AudioManager.say(_entry(selected_id).word_key)

func repeat_instruction() -> void:
	if state == State.SORTING:
		AudioManager.say("SHAPES_INTRO")

func begin_drag(id: String, pointer: int, position: Vector2) -> void:
	if not overlay_paused and not focus_paused and state == State.FEEDBACK and not model.board_complete():
		_finish_feedback()
	if state != State.SORTING or overlay_paused or focus_paused or id not in model.sources or id in model.placed:
		return
	if not drag.begin(pointer, position):
		return
	select_word(id)
	drag_id = id
	preview = _picture(_entry(id).illustration, Vector2.ZERO)
	preview.size = Vector2(130, 130)
	preview.z_index = 20
	add_child(preview)
	preview.global_position = position - preview.size * 0.5
	source_cards[id].modulate.a = 0.3
	_highlight("")

func _slot_at(position: Vector2) -> String:
	var best := ""
	var distance := INF
	for id: String in slots:
		if id in model.placed:
			continue
		var rect: Rect2 = slots[id].get_global_rect()
		var candidate := rect.get_center().distance_squared_to(position)
		if rect.grow(12).has_point(position) and candidate < distance:
			best = id
			distance = candidate
	return best

func _move_preview(position: Vector2) -> void:
	if is_instance_valid(preview):
		preview.global_position = position - preview.size * 0.5
	_highlight(_slot_at(position))

func _highlight(hover: String) -> void:
	for id: String in slots:
		var style := UiKit.panel(UiKit.MINT if id in model.placed or id == hover else UiKit.CREAM, 24, 12)
		style.set_border_width_all(3 if not drag_id.is_empty() and id not in model.placed else 0)
		style.border_color = UiKit.GREEN if id == hover else Color("c4d4bb")
		slots[id].add_theme_stylebox_override("normal", style)

func _release_piece(position: Vector2, traveled: bool) -> void:
	var piece := drag_id
	var slot := _slot_at(position)
	if not traveled or slot.is_empty():
		_restore_drag()
		return
	var result := model.submit(piece, slot)
	if result == "ignored":
		_restore_drag()
		return
	state = State.FEEDBACK
	ProgressManager.record_answer("shapes", piece, result == "correct", result == "correct")
	message.text = LocalizationManager.text("SHAPES_CORRECT" if result == "correct" else "SHAPES_RETRY")
	fox.set_state("happy" if result == "correct" else "encouraging")
	AudioManager.say("SHAPES_CORRECT" if result == "correct" else "SHAPES_RETRY")
	if result == "correct":
		source_cards[piece].modulate.a = 0.0
		source_cards[piece].mouse_filter = Control.MOUSE_FILTER_IGNORE
		source_cards[piece].focus_mode = Control.FOCUS_NONE
		AudioManager.play_sfx("sparkle")
		if SettingsManager.values.reduced_motion:
			_reveal_placed(piece)
		else:
			snap_tween = create_tween()
			snap_tween.tween_property(preview, "global_position", slots[slot].get_global_rect().get_center() - preview.size * 0.5, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			snap_tween.tween_callback(_reveal_placed.bind(piece))
	else:
		if not SettingsManager.values.reduced_motion:
			snap_tween = create_tween()
			snap_tween.tween_property(preview, "global_position", source_cards[piece].get_global_rect().get_center() - preview.size * 0.5, 0.22)
			snap_tween.tween_callback(_restore_drag)
		else:
			_restore_drag()
	var duration := 1.0
	if AudioManager.voice.playing:
		duration = maxf(duration, AudioManager.voice.stream.get_length() + 0.15)
	feedback_timer.start(duration)

func _reveal_placed(id: String) -> void:
	if slot_pictures.has(id):
		slot_pictures[id].texture = load(_entry(id).illustration)
	_restore_drag()

func _restore_drag() -> void:
	if not drag_id.is_empty() and source_cards.has(drag_id) and drag_id not in model.placed:
		source_cards[drag_id].modulate.a = 1.0
	drag_id = ""
	if is_instance_valid(preview):
		preview.queue_free()
	preview = null
	_highlight("")

func _finish_feedback() -> void:
	if state != State.FEEDBACK:
		return
	feedback_timer.stop()
	if snap_tween != null:
		snap_tween.kill()
	# Settle visuals even when a test/skip finishes feedback before the tween.
	for id: String in model.placed:
		slot_pictures[id].texture = load(_entry(id).illustration)
	_restore_drag()
	if model.board_complete():
		if model.advance():
			_show_board()
		else:
			_show_complete()
	else:
		state = State.SORTING
		message.text = LocalizationManager.text("SHAPES_INTRO")
		fox.set_state("thinking")

func _show_complete() -> void:
	if state == State.COMPLETE and session_awarded: return
	_clear_body()
	state = State.COMPLETE
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed("shapes")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var card := UiKit.card()
	card.custom_minimum_size = Vector2(720, 440)
	center.add_child(card)
	var column := UiKit.column(20)
	card.add_child(column)
	var title := UiKit.label("SHAPES_COMPLETE", 35, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(280, 260)
	column.add_child(fox)
	fox.set_state("celebrating")
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.MINT, "replay")
	replay.name = "Replay"
	column.add_child(replay)
	AudioManager.say("SHAPES_COMPLETE")
	CompletionCelebration.mount(self)

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	if value:
		drag.cancel()
	_update_pause()

func _update_pause() -> void:
	var paused := overlay_paused or focus_paused
	feedback_timer.paused = paused
	if snap_tween != null and snap_tween.is_valid():
		if paused:
			snap_tween.pause()
		else:
			snap_tween.play()

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
	AudioManager.stop_voice()
