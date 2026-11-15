extends Control

enum State { CHOOSING, REVEALING, HOLDING, HIDING, COMPLETE }
var chosen_ids: Array[String]=[]
var state := State.CHOOSING
var model: MemoryRound
var body := UiKit.column(14)
var feedback_timer := Timer.new()
var cards: Array[MemoryCard] = []
var message: Label
var progress: Label
var word_button: ChildButton
var fox: FoxieView
var active_card := -1
var pending_result := ""
var hiding: Array[int] = []
var selected_id := ""
var generation := 0
var overlay_paused := false
var focus_paused := false
var session_awarded := false

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.memory:
		ids.append(entry.id)
	model = MemoryRound.new(ids)
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_timer.one_shot = true
	add_child(feedback_timer)
	feedback_timer.timeout.connect(_resolve_pair)
	start_session()

func _entry(id: String) -> Dictionary:
	for entry: Dictionary in ContentManager.memory:
		if entry.id == id:
			return entry
	return {}

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	generation += 1
	feedback_timer.stop()
	for card: MemoryCard in cards:
		if card.flip_tween != null:
			card.flip_tween.kill()
	cards.clear()
	hiding.clear()
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()

func start_session() -> void:
	AudioManager.stop_voice()
	if not model.begin(SettingsManager.values.difficulty,0,chosen_ids):
		return
	_clear_body()
	session_awarded = false
	selected_id = ""
	state = State.CHOOSING
	var title := UiKit.label("MEMORY_TITLE", 32, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var top := UiKit.row(10);body.add_child(top);top.add_child(title);top.add_child(UiKit.spacer());top.add_child(UiKit.button("MATERIAL_CHOOSE",choose_material,UiKit.MINT))
	var prompt := UiKit.row(14)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(100, 80)
	prompt.add_child(fox)
	fox.set_state("thinking")
	message = UiKit.label("MEMORY_INTRO", 29)
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
	var board := GridContainer.new()
	board.columns = 3 if model.pair_count == 3 else 2 if model.pair_count == 2 else 4
	board.add_theme_constant_override("h_separation", 18)
	board.add_theme_constant_override("v_separation", 18)
	center.add_child(board)
	for index: int in range(model.deck.size()):
		var card := MemoryCard.new()
		card.name = "Memory_" + str(index)
		card.front_texture = load(_entry(model.deck[index]).illustration)
		card.custom_minimum_size = Vector2(214, 178)
		card.add_theme_stylebox_override("normal", UiKit.panel(UiKit.CREAM, 24, 12))
		card.pressed.connect(choose.bind(index))
		card.flip_finished.connect(_on_flip_finished.bind(index, generation))
		board.add_child(card)
		cards.append(card)
	var footer := UiKit.row(18)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(footer)
	progress = UiKit.label("", 25, UiKit.GREEN)
	footer.add_child(progress)
	_update_progress()
	word_button = UiKit.button("", repeat_word, UiKit.MINT, "speaker")
	word_button.name = "RepeatWord"
	word_button.text = LocalizationManager.text("ANIMALS_REPEAT_WORD")
	word_button.disabled = true
	footer.add_child(word_button)
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.CREAM, "replay")
	replay.name = "RestartMemory"
	footer.add_child(replay)
	_update_pause()
	AudioManager.say("MEMORY_INTRO")

func choose(index: int) -> void:
	if state != State.CHOOSING or overlay_paused or focus_paused:
		return
	var result := model.reveal(index)
	if result == "ignored":
		return
	state = State.REVEALING
	active_card = index
	pending_result = result
	selected_id = model.deck[index]
	word_button.text = LocalizationManager.object_name(_entry(selected_id))
	word_button.disabled = false
	AudioManager.say(_entry(selected_id).word_key)
	cards[index].show_face(true)

func _on_flip_finished(index: int, token: int) -> void:
	if token != generation:
		return
	if state == State.REVEALING and index == active_card:
		if pending_result == "first":
			state = State.CHOOSING
		else:
			state = State.HOLDING
			var matched := pending_result == "match"
			ProgressManager.record_answer("memory", model.deck[model.first], matched, matched)
			message.text = LocalizationManager.text("MEMORY_MATCH" if matched else "MEMORY_RETRY")
			fox.set_state("happy" if matched else "encouraging")
			var duration := 1.1
			if AudioManager.voice.playing:
				duration = maxf(duration, AudioManager.voice.stream.get_length() + 0.15)
			feedback_timer.start(duration)
	elif state == State.HIDING and index in hiding:
		hiding.erase(index)
		if hiding.is_empty():
			model.resolve()
			state = State.CHOOSING
			message.text = LocalizationManager.text("MEMORY_INTRO")
			fox.set_state("thinking")

func _resolve_pair() -> void:
	if state != State.HOLDING:
		return
	if pending_result == "match":
		model.resolve()
		AudioManager.play_sfx("sparkle")
		_update_progress()
		if model.completed:
			_show_complete()
		else:
			state = State.CHOOSING
			AudioManager.say("MEMORY_MATCH")
	else:
		state = State.HIDING
		hiding.assign([model.first, model.second])
		var to_hide := hiding.duplicate()
		AudioManager.say("MEMORY_RETRY")
		for index: int in to_hide:
			cards[index].show_face(false)

func _update_progress() -> void:
	progress.text = LocalizationManager.text("MEMORY_PROGRESS").format({"found": model.matched.size() / 2, "total": model.pair_count})

func repeat_instruction() -> void:
	if state == State.CHOOSING:
		AudioManager.say("MEMORY_INTRO")

func repeat_word() -> void:
	if not selected_id.is_empty() and state != State.COMPLETE:
		AudioManager.say(_entry(selected_id).word_key)

func _show_complete() -> void:
	if state == State.COMPLETE and session_awarded: return
	_clear_body()
	state = State.COMPLETE
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed("memory")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var panel := UiKit.card()
	panel.custom_minimum_size = Vector2(740, 440)
	center.add_child(panel)
	var column := UiKit.column(20)
	panel.add_child(column)
	var title := UiKit.label("MEMORY_COMPLETE", 35, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(280, 260)
	column.add_child(fox)
	fox.set_state("celebrating")
	var replay := UiKit.button("ANIMALS_REPLAY", start_session, UiKit.MINT, "replay")
	replay.name = "Replay"
	var actions := UiKit.row(12);column.add_child(actions);actions.add_child(replay);actions.add_child(UiKit.button("MATERIAL_CHOOSE",choose_material,UiKit.CREAM))
	AudioManager.say("MEMORY_COMPLETE")
	CompletionCelebration.mount(self)

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	_update_pause()

func _update_pause() -> void:
	var paused := overlay_paused or focus_paused
	feedback_timer.paused = paused
	for card: MemoryCard in cards:
		card.set_flip_paused(paused)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		_update_pause()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		_update_pause()

func _exit_tree() -> void:
	generation += 1
	feedback_timer.stop()
	for card: MemoryCard in cards:
		if card.flip_tween != null:
			card.flip_tween.kill()
	AudioManager.stop_voice()

func choose_material() -> void:
	MaterialPicker.show_for(self,ContentManager.memory,func(ids: Array) -> void:
		chosen_ids.assign(ids);start_session()
	,MemoryRound.PAIRS[SettingsManager.values.difficulty])
