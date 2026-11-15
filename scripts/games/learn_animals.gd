extends Control

enum State { EXPLORE, QUESTION, FEEDBACK, COMPLETE }

var state := State.EXPLORE
var model: AnimalRound
var page := 0
var content := UiKit.column(16)
var body := UiKit.column(14)
var feedback_timer := Timer.new()
var fox: FoxieView
var message: Label
var last_card: Control
var card_tween: Tween
var session_awarded := false
var overlay_paused := false
var focus_paused := false
var last_explored_id := ""
var repeat_word_button: ChildButton

@export var game_id := "animals"
@export var text_prefix := "ANIMALS"

func _entries() -> Array[Dictionary]:
	return ContentManager.animals if game_id == "animals" else ContentManager.colors

func _entry(id: String) -> Dictionary:
	for entry: Dictionary in _entries():
		if entry.id == id:
			return entry
	return {}

func _key(suffix: String) -> String:
	return text_prefix + "_" + suffix

func _ready() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in _entries():
		ids.append(entry.id)
	model = AnimalRound.new(ids)
	add_child(content)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var modes := UiKit.row(16)
	content.add_child(modes)
	var explore := UiKit.button(_key("EXPLORE"), show_explore, UiKit.CREAM, "wave")
	explore.name = "ExploreMode"
	modes.add_child(explore)
	var find := UiKit.button(_key("FIND"), start_quiz, UiKit.MINT, "search")
	find.name = "FindMode"
	modes.add_child(find)
	modes.add_child(UiKit.spacer())
	var title := UiKit.label(_key("TITLE"), 30, UiKit.GREEN)
	modes.add_child(title)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)
	feedback_timer.one_shot = true
	add_child(feedback_timer)
	feedback_timer.timeout.connect(_finish_feedback)
	show_explore()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	feedback_timer.stop()
	if card_tween != null:
		card_tween.kill()
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	last_card = null
	fox = null
	message = null
	repeat_word_button = null

func show_explore() -> void:
	AudioManager.stop_voice()
	state = State.EXPLORE
	_clear_body()
	var hint := UiKit.label(_key("TAP_HINT"), 28)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(hint)
	var cards := UiKit.row(20)
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(cards)
	var first := page * 4
	for position: int in range(first, mini(first + 4, _entries().size())):
		var entry: Dictionary = _entries()[position]
		var card := _animal_card(entry, _explore_animal.bind(entry.id), 250)
		cards.add_child(card)
	var pages := UiKit.row(18)
	pages.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(pages)
	var previous := UiKit.button("", _change_page.bind(-1), UiKit.CREAM, "previous")
	previous.name = "PreviousPage"
	previous.custom_minimum_size.x = 80
	previous.disabled = page == 0
	pages.add_child(previous)
	var indicator := UiKit.label("", 25, UiKit.MUTED)
	indicator.text = "%d / %d" % [page + 1, ceili(_entries().size() / 4.0)]
	indicator.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pages.add_child(indicator)
	var next := UiKit.button("", _change_page.bind(1), UiKit.CREAM, "next")
	next.name = "NextPage"
	next.custom_minimum_size.x = 80
	next.disabled = (page + 1) * 4 >= _entries().size()
	pages.add_child(next)
	var visible_ids: Array[String] = []
	for position: int in range(first, mini(first + 4, _entries().size())):
		visible_ids.append(_entries()[position].id)
	if last_explored_id not in visible_ids:
		last_explored_id = visible_ids[0]
	repeat_word_button = UiKit.button("", func() -> void: _explore_animal(last_explored_id), UiKit.MINT, "speaker")
	repeat_word_button.name = "RepeatWord"
	repeat_word_button.text = LocalizationManager.object_name(_entry(last_explored_id))
	repeat_word_button.tooltip_text = LocalizationManager.text(_key("REPEAT_WORD"))
	repeat_word_button.custom_minimum_size.x = 150
	pages.add_child(repeat_word_button)
	AudioManager.say(_key("TAP_HINT"))

func _change_page(direction: int) -> void:
	page = clampi(page + direction, 0, ceili(_entries().size() / 4.0) - 1)
	show_explore()

func _explore_animal(id: String) -> void:
	if state != State.EXPLORE:
		return
	var entry := _entry(id)
	last_explored_id = id
	if is_instance_valid(repeat_word_button):
		repeat_word_button.text = LocalizationManager.object_name(entry)
	AudioManager.say(entry.word_key)
	var card := body.find_child("Animal_" + id, true, false) as Control
	_animate_card(card)

func start_quiz() -> void:
	AudioManager.stop_voice()
	session_awarded = false
	if model.begin(SettingsManager.values.difficulty):
		_show_question()

func _show_question() -> void:
	state = State.QUESTION
	_clear_body()
	var entry := _entry(model.target)
	var prompt := UiKit.row(18)
	prompt.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(prompt)
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(100, 96)
	prompt.add_child(fox)
	fox.set_state("thinking")
	message = UiKit.label("", 31)
	message.text = LocalizationManager.text(entry.prompt_key)
	message.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(message)
	var repeat := UiKit.button("", repeat_prompt, UiKit.MINT, "speaker")
	repeat.name = "RepeatPrompt"
	repeat.custom_minimum_size = Vector2(80, 72)
	repeat.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prompt.add_child(repeat)
	var cards := UiKit.row(24)
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(cards)
	for id: String in model.options:
		cards.add_child(_animal_card(_entry(id), choose.bind(id), 280 if model.choice_count == 2 else 220))
	body.add_child(_star_row(model.solved))
	repeat_prompt()

func _star_row(filled: int) -> HBoxContainer:
	var stars := UiKit.row(14)
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	for index: int in range(AnimalRound.ROUND_COUNT):
		var star := TextureRect.new()
		star.texture = preload("res://assets/ui/star.svg")
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.custom_minimum_size = Vector2(34, 34)
		star.modulate.a = 1.0 if index < filled else 0.24
		stars.add_child(star)
	return stars

func repeat_prompt() -> void:
	if state != State.QUESTION:
		return
	AudioManager.say(_entry(model.target).prompt_key)

func choose(id: String) -> void:
	if state != State.QUESTION or overlay_paused or focus_paused:
		return
	var result := model.submit(id)
	if result == "ignored":
		return
	state = State.FEEDBACK
	ProgressManager.record_answer(game_id, model.target, result == "correct", result == "correct")
	last_card = body.find_child("Animal_" + id, true, false) as Control
	if result == "correct":
		last_card.add_theme_stylebox_override("normal", UiKit.panel(UiKit.MINT, 28, 18))
		message.text = LocalizationManager.text(_key("CORRECT"))
		fox.react()
		AudioManager.play_sfx("sparkle")
		AudioManager.say(_key("CORRECT"))
		_animate_card(last_card)
		feedback_timer.start(_feedback_duration(1.0))
	else:
		message.text = LocalizationManager.text(_key("TRY_AGAIN"))
		fox.set_state("encouraging")
		AudioManager.say(_key("TRY_AGAIN"))
		feedback_timer.start(_feedback_duration(0.65))

func _feedback_duration(minimum: float) -> float:
	if AudioManager.voice.playing and AudioManager.voice.stream != null:
		return maxf(minimum, AudioManager.voice.stream.get_length() + 0.15)
	return minimum

func _finish_feedback() -> void:
	if state != State.FEEDBACK:
		return
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
	state = State.COMPLETE
	_clear_body()
	if not session_awarded:
		session_awarded = true
		ProgressManager.record_session_completed(game_id)
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var card := UiKit.card()
	card.custom_minimum_size.x = 650
	center.add_child(card)
	var summary := UiKit.column(18)
	card.add_child(summary)
	var title := UiKit.label(_key("COMPLETE"), 38, UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_child(title)
	summary.add_child(_star_row(AnimalRound.ROUND_COUNT))
	fox = FoxieView.new()
	fox.custom_minimum_size = Vector2(300, 240)
	summary.add_child(fox)
	fox.react()
	fox.set_state("celebrating")
	var actions := UiKit.row(20)
	summary.add_child(actions)
	var replay := UiKit.button(_key("REPLAY"), start_quiz, Color("ffe0a1"), "replay")
	replay.name = "Replay"
	actions.add_child(replay)
	actions.add_child(UiKit.button(_key("EXPLORE"), show_explore, UiKit.MINT, "wave"))
	AudioManager.say(_key("COMPLETE"))
	CompletionCelebration.mount(self)

func _animal_card(entry: Dictionary, action: Callable, width: int) -> ChildButton:
	var card := UiKit.button("", action, UiKit.CREAM)
	card.name = "Animal_" + entry.id
	card.custom_minimum_size = Vector2(width, 330)
	card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var items := UiKit.column(8)
	items.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(items)
	items.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	items.offset_left = 16
	items.offset_right = -16
	items.offset_top = 14
	items.offset_bottom = -14
	var picture := TextureRect.new()
	picture.texture = load(entry.illustration) as Texture2D
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size.y = 240
	picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	items.add_child(picture)
	var label := UiKit.label("", 31)
	label.text = LocalizationManager.object_name(entry)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items.add_child(label)
	return card

func _animate_card(card: Control) -> void:
	if card_tween != null:
		card_tween.kill()
	if is_instance_valid(last_card):
		last_card.scale = Vector2.ONE
	last_card = card
	if card == null or SettingsManager.values.reduced_motion:
		return
	card.pivot_offset = card.size * 0.5
	card_tween = create_tween()
	card_tween.tween_property(card, "scale", Vector2.ONE * 1.04, 0.18).set_trans(Tween.TRANS_SINE)
	card_tween.tween_property(card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_SINE)

func _exit_tree() -> void:
	feedback_timer.stop()
	AudioManager.stop_voice()

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	feedback_timer.paused = overlay_paused or focus_paused
	if not value and not focus_paused:
		repeat_prompt()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		focus_paused = true
		feedback_timer.paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		focus_paused = false
		feedback_timer.paused = overlay_paused
		if is_node_ready() and not overlay_paused:
			repeat_prompt()
