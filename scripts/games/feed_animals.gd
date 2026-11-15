extends Control

enum State { QUESTION, FEEDBACK, COMPLETE }

var state := State.QUESTION
var model: FeedingRound
var body := UiKit.column(12)
var feedback_timer := Timer.new()
var drop_zone: PanelContainer
var fox: FoxieView
var message: Label
var word_button: ChildButton
var preview: TextureRect
var drag_id := ""
var pointer_owner := -2
var drag_origin := Vector2.ZERO
var drag_position := Vector2.ZERO
var drag_moved := false
var selected_id := ""
var overlay_paused := false
var focus_paused := false
var session_awarded := false
var eat_tween: Tween
var eating_visual: TextureRect

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.foods:
		ids.append(entry.id)
	model = FeedingRound.new(ids)
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_timer.one_shot = true
	add_child(feedback_timer)
	feedback_timer.timeout.connect(_finish_feedback)
	start_session()

func _entry(id: String) -> Dictionary:
	for entry: Dictionary in ContentManager.foods:
		if entry.id == id:
			return entry
	return {}

func start_session() -> void:
	session_awarded = false
	if model.begin(SettingsManager.values.difficulty):
		_show_question()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	cancel_drag()
	feedback_timer.stop()
	if eat_tween != null:
		eat_tween.kill()
	if is_instance_valid(eating_visual):
		eating_visual.queue_free()
	eating_visual = null
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	drop_zone = null
	fox = null

func _show_question() -> void:
	_clear_body()
	state = State.QUESTION
	selected_id = model.target
	var heading := UiKit.row(16)
	body.add_child(heading)
	heading.add_child(UiKit.label("FEED_TITLE", 30, UiKit.GREEN))
	heading.add_child(UiKit.spacer())
	heading.add_child(UiKit.label("FEED_HINT", 25))
	var prompt := UiKit.row(12)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	message = UiKit.label("", 30)
	message.text = LocalizationManager.text(_entry(model.target).prompt_key)
	prompt.add_child(message)
	var repeat := UiKit.button("", repeat_prompt, UiKit.MINT, "speaker")
	repeat.name = "RepeatPrompt"
	repeat.custom_minimum_size.x = 76
	prompt.add_child(repeat)
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	drop_zone = UiKit.card(UiKit.CREAM)
	drop_zone.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 28, 12))
	drop_zone.name = "FeedingTarget"
	drop_zone.custom_minimum_size = Vector2(360, 230)
	center.add_child(drop_zone)
	var target_content := UiKit.column(0)
	target_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drop_zone.add_child(target_content)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(240, 170)
	fox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_content.add_child(fox)
	fox.set_state("thinking")
	var target_hint := UiKit.label("FEED_DROP", 23, UiKit.GREEN)
	target_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_content.add_child(target_hint)
	var tray := UiKit.row(14)
	tray.name = "FoodTray"
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(tray)
	for id: String in model.options:
		tray.add_child(_food_card(_entry(id)))
	var footer := UiKit.row(16)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(footer)
	for index: int in range(FeedingRound.ROUND_COUNT):
		var star := TextureRect.new()
		star.texture = preload("res://assets/ui/star.svg")
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.custom_minimum_size = Vector2(30, 30)
		star.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		star.modulate.a = 1.0 if index < model.solved else 0.24
		footer.add_child(star)
	word_button = UiKit.button("", repeat_word, UiKit.MINT, "speaker")
	word_button.name = "RepeatWord"
	word_button.text = LocalizationManager.object_name(_entry(selected_id))
	word_button.tooltip_text = LocalizationManager.text("FEED_REPEAT_WORD")
	footer.add_child(word_button)
	repeat_prompt()

func _food_card(entry: Dictionary) -> FoodCard:
	var card := FoodCard.new()
	card.name = "Food_" + entry.id
	card.food_id = entry.id
	card.custom_minimum_size = Vector2(200, 172)
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 24, 10))
	card.grabbed.connect(begin_drag)
	card.word_requested.connect(select_word)
	var column := UiKit.column(0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(column)
	var picture := TextureRect.new()
	picture.texture = load(entry.illustration)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size.y = 120
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(picture)
	var label := UiKit.label("", 24)
	label.text = LocalizationManager.object_name(entry)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(label)
	return card

func select_word(id: String) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused or id not in model.options:
		return
	selected_id = id
	word_button.text = LocalizationManager.object_name(_entry(id))
	repeat_word()

func repeat_word() -> void:
	if state == State.QUESTION:
		AudioManager.say(_entry(selected_id).word_key)

func repeat_prompt() -> void:
	if state == State.QUESTION:
		AudioManager.say(_entry(model.target).prompt_key)

func begin_drag(id: String, pointer: int, position: Vector2) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused or pointer_owner != -2 or id not in model.options:
		return
	select_word(id)
	drag_id = id
	pointer_owner = pointer
	drag_origin = position
	drag_position = position
	drag_moved = false
	preview = TextureRect.new()
	preview.texture = load(_entry(id).illustration)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(110, 110)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.z_index = 20
	add_child(preview)
	preview.global_position = position - preview.size * 0.5
	_set_highlight(true)
	var card := body.find_child("Food_" + id, true, false) as Control
	card.modulate.a = 0.45

func _input(event: InputEvent) -> void:
	if pointer_owner == -2:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_drag()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == pointer_owner:
		move_drag(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.index == pointer_owner and not event.pressed:
		if event.canceled:
			cancel_drag()
		else:
			end_drag(event.position)
		get_viewport().set_input_as_handled()
	elif pointer_owner == -1 and event is InputEventMouseMotion:
		move_drag(event.position)
		get_viewport().set_input_as_handled()
	elif pointer_owner == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		end_drag(event.position)
		get_viewport().set_input_as_handled()

func move_drag(position: Vector2) -> void:
	if pointer_owner == -2:
		return
	drag_position = position
	drag_moved = drag_moved or drag_origin.distance_to(position) > 12.0
	preview.global_position = position - preview.size * 0.5
	_set_highlight(true, drop_zone.get_global_rect().has_point(position))

func end_drag(position: Vector2) -> void:
	if pointer_owner == -2:
		return
	var id := drag_id
	var inside := drop_zone.get_global_rect().has_point(position)
	var moved := drag_moved or drag_origin.distance_to(position) > 12.0
	cancel_drag()
	if moved and inside:
		_offer(id)

func cancel_drag() -> void:
	if not drag_id.is_empty():
		var card := body.find_child("Food_" + drag_id, true, false) as Control
		if is_instance_valid(card):
			card.modulate.a = 1.0
	pointer_owner = -2
	drag_id = ""
	if is_instance_valid(preview):
		preview.queue_free()
	preview = null
	_set_highlight(false)

func _set_highlight(active: bool, inside: bool = false) -> void:
	if not is_instance_valid(drop_zone):
		return
	var style := UiKit.panel(UiKit.MINT if inside else UiKit.CREAM, 28, 12)
	style.set_border_width_all(4 if active else 0)
	style.border_color = UiKit.GREEN if inside else Color("d7ab5e")
	drop_zone.add_theme_stylebox_override("panel", style)

func _offer(id: String) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused:
		return
	var result := model.submit(id)
	if result == "ignored":
		return
	state = State.FEEDBACK
	ProgressManager.record_answer("feeding", model.target, result == "correct", result == "correct")
	message.text = LocalizationManager.text("FEED_CORRECT" if result == "correct" else "FEED_TRY_AGAIN")
	AudioManager.say("FEED_CORRECT" if result == "correct" else "FEED_TRY_AGAIN")
	fox.set_state("happy" if result == "correct" else "encouraging")
	if result == "correct":
		AudioManager.play_sfx("sparkle")
		_eat(id)
	var duration := 1.1
	if AudioManager.voice.playing:
		duration = maxf(duration, AudioManager.voice.stream.get_length() + 0.15)
	feedback_timer.start(duration)

func _eat(id: String) -> void:
	var bite := TextureRect.new()
	eating_visual = bite
	bite.texture = load(_entry(id).illustration)
	bite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bite.size = Vector2(100, 100)
	bite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bite.z_index = 10
	add_child(bite)
	bite.global_position = drop_zone.get_global_rect().get_center() - Vector2(50, 20)
	if SettingsManager.values.reduced_motion:
		bite.modulate.a = 0.6
		return
	bite.pivot_offset = bite.size * 0.5
	eat_tween = create_tween()
	for index: int in range(3):
		eat_tween.tween_property(bite, "scale", Vector2.ONE * (0.72 - index * 0.22), 0.2)
		eat_tween.tween_interval(0.08)
	eat_tween.tween_callback(bite.queue_free)

func _finish_feedback() -> void:
	if state != State.FEEDBACK:
		return
	if is_instance_valid(eating_visual):
		eating_visual.queue_free()
	eating_visual = null
	if model.round_solved:
		if model.advance():
			_show_question()
		else:
			_show_complete()
	else:
		state = State.QUESTION
		fox.set_state("thinking")
		message.text = LocalizationManager.text(_entry(model.target).prompt_key)

func _show_complete() -> void:
	if state == State.COMPLETE and session_awarded: return
	_clear_body()
	state = State.COMPLETE
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed("feeding")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var card := UiKit.card()
	card.custom_minimum_size = Vector2(650, 420)
	center.add_child(card)
	var summary := UiKit.column(20)
	card.add_child(summary)
	var title := UiKit.label("FEED_COMPLETE", 35, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_child(title)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(280, 260)
	fox.set_state("celebrating")
	summary.add_child(fox)
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.MINT, "replay")
	replay.name = "Replay"
	summary.add_child(replay)
	AudioManager.say("FEED_COMPLETE")
	CompletionCelebration.mount(self)

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	if value:
		cancel_drag()
	_update_pause()

func _update_pause() -> void:
	var paused := overlay_paused or focus_paused
	feedback_timer.paused = paused
	if eat_tween != null and eat_tween.is_valid():
		if paused:
			eat_tween.pause()
		else:
			eat_tween.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		cancel_drag()
		_update_pause()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		_update_pause()

func _exit_tree() -> void:
	cancel_drag()
	feedback_timer.stop()
	if eat_tween != null:
		eat_tween.kill()
	AudioManager.stop_voice()
