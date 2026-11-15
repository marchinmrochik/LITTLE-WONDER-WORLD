extends Node

var checks := 0
var failures: PackedStringArray = []
var expected_attempts := 0

func _ready() -> void:
	get_tree().create_timer(45).timeout.connect(func() -> void:
		push_error("Counting test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/counting-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	_expect(ContentManager.counting.size() == 4, "Four counting themes loaded")
	_expect(AnimalCatalog.validate(ContentManager.counting, true, 4).is_empty(), "Reused picture/audio resources validate")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.counting:
		ids.append(entry.id)
		_expect(AudioManager.local_voice_available(entry.question_key, "en"), "Offline theme question available")
		for number: int in range(1, 11):
			_expect(AudioManager.local_voice_available("COUNT_PUT_%s_%d" % [entry.id.to_upper(), number], "en"), "Offline basket instruction available")
	for number: int in range(1, 11):
		_expect(AudioManager.local_voice_available("COUNT_NUMBER_" + str(number), "en"), "All ten English numbers bundled")
	var inactive := CountingRound.new(ids)
	_expect(inactive.answer(1) == "ignored" and not inactive.add_object(0) and inactive.check_basket() == "ignored", "Unstarted model cannot count or complete")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for mode: String in ["choice", "basket"]:
			for seed_value: int in range(1, 21):
				var round_model := CountingRound.new(ids)
				_expect(round_model.begin(difficulty, mode, seed_value), "Counting session begins")
				var seen := {}
				var themes := {}
				for task: int in range(5):
					_expect(round_model.limit == (5 if difficulty == "easy" else 10), "Difficulty selects 1-5 or 1-10")
					_expect(round_model.target >= 1 and round_model.target <= round_model.limit and not seen.has(round_model.target), "Five distinct in-range quantities")
					seen[round_model.target] = true
					themes[round_model.theme] = true
					_expect(not round_model.advance(), "Unsolved task cannot advance")
					if mode == "choice":
						_expect(round_model.options.size() == CountingRound.CHOICES[difficulty] and round_model.target in round_model.options, "Choices include true quantity")
						var unique := {}
						for option: int in round_model.options:
							unique[option] = true
							_expect(option >= 1 and option <= round_model.limit, "Distractors remain in learning range")
						_expect(unique.size() == round_model.options.size(), "Number options unique")
						var wrong: int = round_model.options.filter(func(value: int) -> bool: return value != round_model.target)[0]
						_expect(round_model.answer(wrong) == "incorrect" and not round_model.round_solved, "Wrong number retains task")
						_expect(round_model.answer(99) == "ignored" and not round_model.add_object(0), "Invalid answer and wrong-mode mutation rejected")
						_expect(round_model.answer(round_model.target) == "correct", "Exact quantity accepted")
						_expect(round_model.answer(round_model.target) == "ignored", "Duplicate answer cannot score")
					else:
						_expect(round_model.check_basket() == "incorrect", "Empty basket cannot complete a positive quantity")
						_expect(not round_model.add_object(-1) and not round_model.add_object(round_model.limit), "Invalid instance IDs rejected")
						for instance: int in range(round_model.target):
							_expect(round_model.add_object(instance), "Unique object enters basket")
							_expect(not round_model.add_object(instance) and round_model.in_basket.size() == instance + 1, "Same object cannot be counted twice")
						_expect(not round_model.round_solved, "Reaching target does not bypass confirmation")
						if round_model.target < round_model.limit:
							_expect(round_model.add_object(round_model.target) and round_model.check_basket() == "incorrect", "Too many objects cannot complete")
							_expect(round_model.remove_object(round_model.target), "Overfilled basket can be corrected")
						_expect(round_model.remove_object(0) and not round_model.remove_object(0), "Removal is idempotent")
						_expect(round_model.check_basket() == "incorrect" and round_model.add_object(0), "Too few objects rejected, returned object reusable")
						_expect(round_model.check_basket() == "correct", "Only exact live basket quantity accepted")
						_expect(round_model.check_basket() == "ignored" and not round_model.remove_object(0), "Solved basket locks mutations and duplicate completion")
					_expect(round_model.solved == task + 1 and round_model.advance() == (task < 4), "Five correctly solved tasks complete session")
				_expect(round_model.completed and themes.size() == 4, "Session completes across all four themes")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		app.current_view.ensure_activity("counting")
		await _frames()
		_expect(app.current_view.find_child("CountingButton", true, false) != null, "Counting reachable on second menu page")
		app.current_view.find_child("CountingButton", true, false).pressed.emit()
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		_expect(game.body.find_child("CountedObjects", true, false).get_child_count() == game.model.target, "Rendered object count equals real target")
		game.repeat_prompt()
		_expect(AudioManager.voice.stream.resource_path == ContentManager.voice_path(game._entry().question_key, locale), "English count question under both UI locales")
		var wrong: int = game.model.options.filter(func(value: int) -> bool: return value != game.model.target)[0]
		game.body.find_child("Number_" + str(wrong), true, false).pressed.emit()
		expected_attempts += 1
		game.choose_number(game.model.target)
		_expect(_attempts() == expected_attempts, "Rapid second number input ignored during feedback")
		_finish(game)
		for task: int in range(5):
			var number: int = game.model.target
			game.body.find_child("Number_" + str(number), true, false).pressed.emit()
			expected_attempts += 1
			_expect(AudioManager.voice.stream.resource_path == ContentManager.voice_path("COUNT_NUMBER_" + str(number), locale), "Chosen numeral is spoken in English")
			_finish(game)
		_expect(game.state == game.State.COMPLETE, "Choice mode reaches completion")
		game.find_child("Replay", true, false).pressed.emit()
		game.find_child("BasketMode", true, false).pressed.emit()
		await _frames()
		game.focus_paused = false
		_expect(game.model.mode == "basket" and game.model.in_basket.is_empty(), "Mode button starts a clean basket session")
		game.repeat_prompt()
		_expect(AudioManager.voice.stream.resource_path == ContentManager.voice_path(game._prompt_key(), locale), "Basket quantity prompt is local English")
		game.find_child("CheckBasket", true, false).pressed.emit()
		expected_attempts += 1
		game.check_basket()
		_expect(_attempts() == expected_attempts and game.model.solved == 0, "Empty/rapid check cannot bypass target")
		_finish(game)
		var start: Vector2 = game.source_cards[0].get_global_rect().get_center()
		var destination: Vector2 = game.drop_zone.get_global_rect().get_center()
		await _drag(start, Vector2(5, 5))
		_expect(game.model.in_basket.is_empty(), "Outside drop does not create an item")
		game.begin_drag(0, 0, start)
		game.set_overlay_paused(true)
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.preview == null, "Overlay cancels basket drag")
		game.set_overlay_paused(false)
		game.begin_drag(0, 0, start)
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.drag.pointer_owner == PointerDrag.NONE, "Focus loss cancels drag")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		await _drag(start, destination, true)
		_expect(game.model.in_basket.size() == 1 and game.basket_count.text == "1", "Touch drop adds one real item with matching numeral")
		game.begin_drag(0, 0, start)
		game.drag.release(destination)
		_expect(game.model.in_basket.size() == 1, "Dragging already stored instance cannot count it twice")
		game.basket_grid.find_child("Stored_0", true, false).pressed.emit()
		await _frames()
		_expect(game.model.in_basket.is_empty() and is_equal_approx(game.source_cards[0].modulate.a, 1), "Basket tap returns the object to its source")
		for task: int in range(5):
			await _frames()
			game.focus_paused = false
			for instance: int in range(game.model.target):
				await _drag(game.source_cards[instance].get_global_rect().get_center(), game.drop_zone.get_global_rect().get_center())
			_expect(game.basket_grid.get_child_count() == game.model.target and game.model.in_basket.size() == game.model.target, "Visible basket objects match model quantity")
			if task == 0 and game.model.target < game.model.limit:
				var extra: int = game.model.target
				await _drag(game.source_cards[extra].get_global_rect().get_center(), game.drop_zone.get_global_rect().get_center())
				game.check_basket()
				expected_attempts += 1
				_expect(not game.model.round_solved, "UI overfill rejected")
				_finish(game)
				game.remove_object(extra)
			game.find_child("CheckBasket", true, false).pressed.emit()
			expected_attempts += 1
			game.check_basket()
			_expect(_attempts() == expected_attempts, "Duplicate confirmation cannot double-record")
			_finish(game)
		_expect(game.state == game.State.COMPLETE, "Basket mode completes five exact quantities")
		game._show_complete()
		_expect(ProgressManager.document.games.counting.completed_sessions == (2 if locale == "en" else 4), "Each mode/session awarded once")
		game.find_child("Replay", true, false).pressed.emit()
		await _frames()
		game.begin_drag(0, -1, game.source_cards[0].get_global_rect().get_center())
		game.find_child("ChoiceMode", true, false).pressed.emit()
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.preview == null and game.model.mode == "choice", "Mode switch cancels pending object input")
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Leaving stops counting speech")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.counting.completed_tasks == 20 and ProgressManager.document.games.counting.attempts == expected_attempts, "Real answer/check tasks persist; dragging alone does not count attempts")
	_expect(not ProgressManager.document.games.has("memory"), "Counting progress isolated")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("COUNTING TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _finish(game: Variant) -> void:
	game.feedback_timer.stop()
	game._finish_feedback()

func _drag(start: Vector2, destination: Vector2, touch: bool = false) -> void:
	if touch:
		var down := InputEventScreenTouch.new()
		down.index = 0
		down.position = start
		down.pressed = true
		get_viewport().push_input(down, true)
		await _frames()
		var move := InputEventScreenDrag.new()
		move.index = 0
		move.position = destination
		get_viewport().push_input(move, true)
		var up := InputEventScreenTouch.new()
		up.index = 0
		up.position = destination
		get_viewport().push_input(up, true)
	else:
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.button_mask = MOUSE_BUTTON_MASK_LEFT
		down.position = start
		down.pressed = true
		get_viewport().push_input(down, true)
		await _frames()
		var move := InputEventMouseMotion.new()
		move.position = destination
		move.button_mask = MOUSE_BUTTON_MASK_LEFT
		get_viewport().push_input(move, true)
		var up := InputEventMouseButton.new()
		up.button_index = MOUSE_BUTTON_LEFT
		up.position = destination
		get_viewport().push_input(up, true)
	await _frames()

func _attempts() -> int:
	return ProgressManager.document.games.get("counting", {}).get("attempts", 0)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
