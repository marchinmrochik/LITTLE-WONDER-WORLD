extends Control

enum State { QUESTION, FEEDBACK, COMPLETE }
var state := State.QUESTION
var model: CountingRound
var drag := PointerDrag.new()
var body := UiKit.column(12)
var feedback_timer := Timer.new()
var message: Label
var fox: FoxieView
var drop_zone: PanelContainer
var basket_grid: GridContainer
var basket_count: Label
var source_cards: Dictionary = {}
var preview: TextureRect
var drag_instance := -1
var overlay_paused := false
var focus_paused := false
var session_awarded := false
var tracing_mode := false
var tracing: SymbolTracing

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.counting:
		ids.append(entry.id)
	model = CountingRound.new(ids)
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(drag)
	drag.moved.connect(_move_preview)
	drag.released.connect(_release_object)
	drag.canceled.connect(_restore_drag)
	feedback_timer.one_shot = true
	add_child(feedback_timer)
	feedback_timer.timeout.connect(_finish_feedback)
	start_session("choice")

func _entry() -> Dictionary:
	for entry: Dictionary in ContentManager.counting:
		if entry.id == model.theme:
			return entry
	return {}

func start_session(mode: String = "") -> void:
	AudioManager.stop_voice()
	tracing_mode=false
	session_awarded = false
	if model.begin(SettingsManager.values.difficulty, model.mode if mode.is_empty() else mode):
		_show_question()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	drag.cancel()
	_restore_drag()
	feedback_timer.stop()
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	source_cards.clear()
	drop_zone = null
	basket_grid = null
	tracing=null

func _build_modes() -> void:
	var modes := UiKit.row(14)
	body.add_child(modes)
	var choice := UiKit.button("COUNT_CHOICE", start_session.bind("choice"), UiKit.MINT if not tracing_mode and model.mode == "choice" else UiKit.CREAM, "search")
	choice.name = "ChoiceMode"
	modes.add_child(choice)
	var basket := UiKit.button("COUNT_BASKET", start_session.bind("basket"), UiKit.MINT if not tracing_mode and model.mode == "basket" else UiKit.CREAM)
	basket.name = "BasketMode"
	modes.add_child(basket)
	var trace_tab := UiKit.button("COUNT_TRACE",show_tracing,UiKit.MINT if tracing_mode else UiKit.CREAM,"drawing");trace_tab.name="TraceDigitsTab";modes.add_child(trace_tab)
	modes.add_child(UiKit.spacer())
	var range_label := UiKit.label("", 23, UiKit.GREEN)
	range_label.text = "" if tracing_mode else LocalizationManager.text("COUNT_RANGE").format({"limit":model.limit})
	range_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	modes.add_child(range_label)
	modes.add_child(UiKit.label("COUNT_TITLE", 30, UiKit.GREEN))
func show_tracing() -> void:
	if overlay_paused or focus_paused:return
	AudioManager.stop_voice();_clear_body();tracing_mode=true;_build_modes()
	tracing=SymbolTracing.new();tracing.name="DigitTracing";tracing.mode="digits";tracing.fixed_mode="digits";tracing.show_mode_switch=false;tracing.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(tracing)
	tracing.set_overlay_paused(overlay_paused);tracing.set_focus_paused(focus_paused)
func _show_question() -> void:
	_clear_body();state=State.QUESTION;_build_modes()
	var prompt := UiKit.row(14)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(100, 78)
	prompt.add_child(fox)
	fox.set_state("thinking")
	message = UiKit.label("", 29)
	message.text = _question_text()
	message.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(message)
	var repeat := UiKit.button("", repeat_prompt, UiKit.MINT, "speaker")
	repeat.name = "RepeatPrompt"
	repeat.custom_minimum_size.x = 76
	repeat.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(repeat)
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	if model.mode == "choice":
		_build_choice(center)
	else:
		_build_basket(center)
	var footer := UiKit.row(14)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(footer)
	for index: int in range(CountingRound.ROUND_COUNT):
		var star := TextureRect.new()
		star.texture = preload("res://assets/ui/star.svg")
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(30, 30)
		star.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		star.modulate.a = 1.0 if index < model.solved else 0.24
		footer.add_child(star)
	if model.mode == "basket":
		var check := UiKit.button("COUNT_CHECK", check_basket, UiKit.MINT, "star")
		check.name = "CheckBasket"
		footer.add_child(check)
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.CREAM, "replay")
	replay.name = "RestartCounting"
	footer.add_child(replay)
	repeat_prompt()

func _prompt_key() -> String:
	return _entry().question_key if model.mode == "choice" else "COUNT_PUT_%s_%d" % [model.theme.to_upper(), model.target]

func _question_text() -> String:
	if model.mode == "choice":
		return LocalizationManager.text(_prompt_key())
	return LocalizationManager.text(_prompt_key())

func _picture(minimum: Vector2) -> TextureRect:
	var image := TextureRect.new()
	image.texture = load(_entry().illustration)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = minimum
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image

func _grid(columns: int, gap: int = 10) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", gap)
	grid.add_theme_constant_override("v_separation", gap)
	return grid

func _build_choice(center: Control) -> void:
	var column := UiKit.column(22)
	center.add_child(column)
	var object_center := CenterContainer.new()
	column.add_child(object_center)
	var objects := _grid(mini(5, model.target), 12)
	objects.name = "CountedObjects"
	object_center.add_child(objects)
	for index: int in range(model.target):
		var picture := _picture(Vector2(92, 92))
		picture.name = "Object_" + str(index)
		objects.add_child(picture)
	var answers := UiKit.row(18)
	answers.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(answers)
	for value: int in model.options:
		var answer := UiKit.button("", choose_number.bind(value), UiKit.CREAM)
		answer.name = "Number_" + str(value)
		answer.text = str(value)
		answer.custom_minimum_size = Vector2(120, 90)
		answer.add_theme_font_size_override("font_size", 42)
		answers.add_child(answer)

func _build_basket(center: Control) -> void:
	var row := UiKit.row(28)
	center.add_child(row)
	var supplies_center := CenterContainer.new()
	row.add_child(supplies_center)
	var supplies := _grid(5, 10)
	supplies.name = "Supplies"
	supplies_center.add_child(supplies)
	for instance: int in range(model.limit):
		var card := DragCard.new()
		card.name = "Supply_" + str(instance)
		card.item_id = str(instance)
		card.custom_minimum_size = Vector2(108, 108)
		card.add_theme_stylebox_override("panel", UiKit.panel(UiKit.CREAM, 20, 8))
		card.grabbed.connect(func(id: String, pointer: int, point: Vector2) -> void: begin_drag(int(id), pointer, point))
		supplies.add_child(card)
		card.add_child(_picture(Vector2(90, 90)))
		source_cards[instance] = card
	drop_zone = UiKit.card(UiKit.CREAM)
	drop_zone.name = "CountingBasket"
	drop_zone.custom_minimum_size = Vector2(432, 310)
	row.add_child(drop_zone)
	var column := UiKit.column(6)
	drop_zone.add_child(column)
	basket_count = UiKit.label("", 30, UiKit.GREEN)
	basket_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(basket_count)
	basket_grid = _grid(5, 6)
	basket_grid.custom_minimum_size = Vector2(374, 146)
	column.add_child(basket_grid)
	var basket_art := TextureRect.new()
	basket_art.texture = preload("res://assets/objects/counting/basket.svg")
	basket_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	basket_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	basket_art.custom_minimum_size.y = 42
	basket_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(basket_art)
	_update_basket()
	var hint := UiKit.label("COUNT_REMOVE", 19, UiKit.MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)

func _update_basket() -> void:
	for child: Node in basket_grid.get_children():
		basket_grid.remove_child(child)
		child.queue_free()
	for instance: int in source_cards:
		var stored: bool = instance in model.in_basket
		source_cards[instance].modulate.a = 0.16 if stored else 1.0
		source_cards[instance].mouse_filter = Control.MOUSE_FILTER_IGNORE if stored else Control.MOUSE_FILTER_STOP
	for instance: int in model.in_basket:
		var button := UiKit.button("", remove_object.bind(instance), UiKit.MINT)
		button.name = "Stored_" + str(instance)
		button.custom_minimum_size = Vector2(70, 70)
		basket_grid.add_child(button)
		var image := _picture(Vector2.ZERO)
		button.add_child(image)
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.offset_left = 5
		image.offset_right = -5
		image.offset_top = 5
		image.offset_bottom = -5
	basket_count.text = str(model.in_basket.size())
	_highlight(false)

func choose_number(number: int) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused:
		return
	var result := model.answer(number)
	if result != "ignored":
		_feedback(result, number)

func check_basket() -> void:
	if state != State.QUESTION or overlay_paused or focus_paused:
		return
	var result := model.check_basket()
	if result != "ignored":
		_feedback(result)

func _feedback(result: String, spoken_number: int = -1) -> void:
	state = State.FEEDBACK
	var correct := result == "correct"
	ProgressManager.record_answer("counting", "%s_%d" % [model.mode, model.target], correct, correct)
	message.text = LocalizationManager.text("COUNT_CORRECT" if correct else "COUNT_RETRY")
	fox.set_state("happy" if correct else "encouraging")
	if spoken_number > 0:
		AudioManager.say("COUNT_NUMBER_" + str(spoken_number))
	else:
		AudioManager.say("COUNT_CORRECT" if correct else "COUNT_RETRY")
	if correct:
		AudioManager.play_sfx("sparkle")
	var duration := 1.0
	if AudioManager.voice.playing:
		duration = maxf(duration, AudioManager.voice.stream.get_length() + 0.15)
	feedback_timer.start(duration)

func _finish_feedback() -> void:
	if tracing_mode or state != State.FEEDBACK:
		return
	if model.round_solved:
		if model.advance():
			_show_question()
		else:
			_show_complete()
	else:
		state = State.QUESTION
		message.text = _question_text()
		fox.set_state("thinking")

func repeat_prompt() -> void:
	if state == State.QUESTION:
		AudioManager.say(_prompt_key())

func begin_drag(instance: int, pointer: int, point: Vector2) -> void:
	if state != State.QUESTION or model.mode != "basket" or overlay_paused or focus_paused or not source_cards.has(instance) or instance in model.in_basket:
		return
	if not drag.begin(pointer, point):
		return
	drag_instance = instance
	preview = _picture(Vector2.ZERO)
	preview.size = Vector2(90, 90)
	preview.z_index = 20
	add_child(preview)
	preview.global_position = point - preview.size * 0.5
	source_cards[instance].modulate.a = 0.35
	_highlight(true)

func _move_preview(point: Vector2) -> void:
	if is_instance_valid(preview):
		preview.global_position = point - preview.size * 0.5
	_highlight(true, drop_zone.get_global_rect().has_point(point))

func _release_object(point: Vector2, traveled: bool) -> void:
	var instance := drag_instance
	var inside := drop_zone.get_global_rect().has_point(point)
	_restore_drag()
	if traveled and inside and state == State.QUESTION and model.add_object(instance):
		_update_basket()
		AudioManager.say("COUNT_NUMBER_" + str(model.in_basket.size()))

func _restore_drag() -> void:
	if source_cards.has(drag_instance) and drag_instance not in model.in_basket:
		source_cards[drag_instance].modulate.a = 1.0
	drag_instance = -1
	if is_instance_valid(preview):
		preview.queue_free()
	preview = null
	_highlight(false)

func remove_object(instance: int) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused:
		return
	if model.remove_object(instance):
		_update_basket()
		if not model.in_basket.is_empty():
			AudioManager.say("COUNT_NUMBER_" + str(model.in_basket.size()))
		else:
			AudioManager.stop_voice()

func _highlight(active: bool, inside: bool = false) -> void:
	if not is_instance_valid(drop_zone):
		return
	var style := UiKit.panel(UiKit.MINT if inside else UiKit.CREAM, 24, 12)
	style.set_border_width_all(3 if active else 0)
	style.border_color = UiKit.GREEN if inside else Color("baa46d")
	drop_zone.add_theme_stylebox_override("panel", style)

func _show_complete() -> void:
	if state == State.COMPLETE and session_awarded: return
	_clear_body()
	state = State.COMPLETE
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed("counting")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var panel := UiKit.card()
	panel.custom_minimum_size = Vector2(720, 430)
	center.add_child(panel)
	var column := UiKit.column(18)
	panel.add_child(column)
	var title := UiKit.label("COUNT_COMPLETE", 35, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(280, 250)
	column.add_child(fox)
	fox.set_state("celebrating")
	var actions := UiKit.row(16)
	column.add_child(actions)
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.MINT, "replay")
	replay.name = "Replay"
	actions.add_child(replay)
	actions.add_child(UiKit.button("COUNT_CHOICE", start_session.bind("choice"), UiKit.CREAM))
	actions.add_child(UiKit.button("COUNT_BASKET", start_session.bind("basket"), UiKit.CREAM))
	AudioManager.say("COUNT_COMPLETE")
	CompletionCelebration.mount(self)

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	if value:
		drag.cancel()
	feedback_timer.paused = overlay_paused or focus_paused
	if is_instance_valid(tracing):tracing.set_overlay_paused(value)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		drag.cancel()
		feedback_timer.paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		feedback_timer.paused = overlay_paused

	else:return
	if is_instance_valid(tracing):tracing.set_focus_paused(focus_paused)

func _exit_tree() -> void:
	drag.cancel()
	_restore_drag()
	feedback_timer.stop()
	AudioManager.stop_voice()

func tracing_idle_action() -> Dictionary:
	if tracing_mode and is_instance_valid(tracing):return tracing.get_idle_action()
	return {}
