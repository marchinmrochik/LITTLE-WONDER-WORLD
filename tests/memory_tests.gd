extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	get_tree().create_timer(45).timeout.connect(func() -> void:
		push_error("Memory test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/memory-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("reduced_motion", true)
	_expect(ContentManager.memory.size() == 12, "Twelve familiar pictures available")
	_expect(AnimalCatalog.validate(ContentManager.memory).is_empty(), "Memory original art/audio resources validate")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.memory:
		ids.append(entry.id)
	var inactive := MemoryRound.new(ids)
	_expect(inactive.reveal(0) == "ignored" and not inactive.resolve(), "Unstarted board cannot reveal/resolve")
	_expect(not inactive.face_up(-1) and not inactive.face_up(0), "Invalid/unstarted card is never face up")
	var duplicate := MemoryRound.new(["cat", "cat", "dog", "bear"])
	_expect(not duplicate.begin("easy"), "Duplicate picture IDs rejected")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 31):
			var round_model := MemoryRound.new(ids)
			_expect(round_model.begin(difficulty, seed_value), "Memory board starts")
			_expect(round_model.deck.size() == MemoryRound.PAIRS[difficulty] * 2, "Difficulty selects 2/3/4 pairs")
			var counts := {}
			for id: String in round_model.deck:
				counts[id] = counts.get(id, 0) + 1
			_expect(counts.size() == round_model.pair_count, "Exactly the requested distinct pairs")
			for value: int in counts.values():
				_expect(value == 2, "Every picture has exactly two copies")
			_expect(round_model.reveal(-1) == "ignored" and round_model.reveal(99) == "ignored", "Invalid positions ignored")
			for pair_index: int in range(round_model.pair_count):
				var first := _unmatched(round_model)[0]
				var partner := _partner(round_model, first)
				var wrong := _different(round_model, first)
				if wrong >= 0:
					_expect(round_model.reveal(first) == "first", "First card revealed")
					_expect(round_model.reveal(first) == "ignored", "Same card cannot pair with itself")
					_expect(round_model.reveal(wrong) == "mismatch", "Different pictures do not match")
					_expect(round_model.reveal(partner) == "ignored", "Third card blocked while resolving")
					_expect(round_model.resolve() and round_model.first == -1 and round_model.second == -1, "Mismatch closes both selections")
				_expect(round_model.reveal(first) == "first" and round_model.reveal(partner) == "match", "Matching pair recognized")
				_expect(not round_model.completed, "Completion waits for resolution")
				_expect(round_model.resolve() and not round_model.resolve(), "Each pair resolves once")
				_expect(first in round_model.matched and partner in round_model.matched, "Matched cards stay open")
				_expect(round_model.reveal(first) == "ignored", "Matched card cannot score again")
			_expect(round_model.completed and round_model.matched.size() == round_model.deck.size(), "All pairs required for completion")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		var menu: Variant = app.current_view
		menu.ensure_activity("memory")
		await _frames()
		_expect(menu.find_child("NextActivities",true,false) == null, "Virtual list has no pagination controls")
		_expect(menu.find_child("MemoryButton",true,false) != null, "Scrolling exposes memory card")
		_expect(menu.find_child("MemoryButton", true, false) != null and menu.find_child("MeadowButton", true, false) != null, "Memory and persistent companion are reachable")
		menu.find_child("MemoryButton", true, false).pressed.emit()
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		_expect(game.model.pair_count == 2 and game.word_button.disabled, "Easy board starts closed with no revealed vocabulary")
		SettingsManager.set_value("reduced_motion", false)
		var before := _attempts()
		await _touch_card(game.cards[0])
		var wrong := _different(game.model, 0)
		game.choose(wrong)
		_expect(game.state == game.State.REVEALING and game.model.first == 0 and game.model.second == -1, "Rapid second tap blocked during first flip")
		game.set_overlay_paused(true)
		_expect(not game.cards[0].flip_tween.is_running(), "Parent overlay pauses card flip")
		await get_tree().create_timer(0.05).timeout
		_expect(game.cards[0].flipping, "Paused flip cannot finish in background")
		game.set_overlay_paused(false)
		await _wait_state(game, game.State.CHOOSING)
		_expect(game.cards[0].face_up and _attempts() == before, "First reveal speaks without counting a pair attempt")
		game.find_child("RepeatWord", true, false).pressed.emit()
		_expect(AudioManager.voice.stream.resource_path == ContentManager.voice_path(game._entry(game.model.deck[0]).word_key, locale), "Selected picture repeats local English word")
		game.choose(wrong)
		await _wait_state(game, game.State.HOLDING)
		_expect(_attempts() == before + 1 and game.model.locked, "Mismatch records one actual pair attempt")
		game.choose(_partner(game.model, 0))
		_expect(game.model.second == wrong, "Third card blocked while pair visible")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		await get_tree().create_timer(0.06).timeout
		_expect(game.feedback_timer.paused and game.state == game.State.HOLDING, "Focus loss pauses pair hold")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		game.feedback_timer.stop()
		game._resolve_pair()
		game.choose(_partner(game.model, 0))
		_expect(game.state == game.State.HIDING, "Third tap cannot interrupt hide animation")
		await _wait_state(game, game.State.CHOOSING)
		_expect(not game.cards[0].face_up and not game.cards[wrong].face_up and not game.model.locked, "Different pictures finish face down")
		SettingsManager.set_value("reduced_motion", true)
		for pair_index: int in range(2):
			var first := _unmatched(game.model)[0]
			var second := _partner(game.model, first)
			game.choose(first)
			game.choose(first)
			game.choose(second)
			var attempts := _attempts()
			game._on_flip_finished(second, game.generation)
			_expect(_attempts() == attempts, "Duplicate flip callback cannot count pair twice")
			game.feedback_timer.stop()
			game._resolve_pair()
			if pair_index == 0:
				_expect(game.cards[first].face_up and game.cards[second].face_up and first in game.model.matched, "Matched cards remain visibly open")
		_expect(game.state == game.State.COMPLETE, "All pairs reach celebration")
		game._show_complete()
		_expect(ProgressManager.document.games.memory.completed_sessions == (1 if locale == "en" else 2), "Completion awarded once")
		game.find_child("Replay", true, false).pressed.emit()
		_expect(game.model.matched.is_empty() and game.state == game.State.CHOOSING, "Replay starts a fresh closed deck")
		SettingsManager.set_value("reduced_motion", false)
		game.choose(0)
		var old_generation: int = game.generation
		game.start_session()
		game._on_flip_finished(0, old_generation)
		_expect(game.state == game.State.CHOOSING and game.model.first == -1, "Restart invalidates stale flip callbacks")
		SettingsManager.set_value("reduced_motion", true)
		game.choose(0)
		game.choose(_different(game.model, 0))
		_expect(game.state == game.State.HOLDING, "A new mismatch is holding before exit")
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Leaving during hold stops speech and pending work")
		GameManager.start_game("memory")
		await _frames()
		game = app.current_view
		game.focus_paused = false
		game.choose(0)
		game.choose(_different(game.model, 0))
		game.feedback_timer.stop()
		SettingsManager.set_value("reduced_motion", false)
		game._resolve_pair()
		_expect(game.state == game.State.HIDING, "Animated hide active before navigation")
		GameManager.return_home()
		await _frames()
		SettingsManager.set_value("reduced_motion", true)
	ProgressManager.reload()
	_expect(ProgressManager.document.games.memory.attempts == 10 and ProgressManager.document.games.memory.completed_tasks == 4 and ProgressManager.document.games.memory.completed_sessions == 2, "Actual pair attempts, solved pairs and sessions persist")
	_expect(not ProgressManager.document.games.has("puzzles"), "Memory counts isolated")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("MEMORY TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _unmatched(model: MemoryRound) -> Array[int]:
	var result: Array[int] = []
	for index: int in range(model.deck.size()):
		if index not in model.matched:
			result.append(index)
	return result

func _partner(model: MemoryRound, first: int) -> int:
	for index: int in range(model.deck.size()):
		if index != first and model.deck[index] == model.deck[first]:
			return index
	return -1

func _different(model: MemoryRound, first: int) -> int:
	for index: int in _unmatched(model):
		if model.deck[index] != model.deck[first]:
			return index
	return -1

func _wait_state(game: Variant, expected: int) -> void:
	var deadline := Time.get_ticks_msec() + 1800
	while game.state != expected and Time.get_ticks_msec() < deadline:
		await get_tree().create_timer(0.02).timeout
	_expect(game.state == expected, "Animation reaches expected state before deadline")

func _touch_card(card: Control) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = card.get_global_rect().get_center()
		event.pressed = pressed
		get_viewport().push_input(event, true)
		await _frames()

func _attempts() -> int:
	return ProgressManager.document.games.get("memory", {}).get("attempts", 0)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
