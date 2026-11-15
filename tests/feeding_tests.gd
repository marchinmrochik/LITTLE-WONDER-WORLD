extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/feeding-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	_expect(ContentManager.foods.size() == 12, "All twelve requested foods loaded")
	_expect(AnimalCatalog.validate(ContentManager.foods).is_empty(), "Food IDs, safe paths and required resources validate")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.foods:
		ids.append(entry.id)
		for locale: String in ["en", "uk"]:
			_expect(AudioManager.local_voice_available(entry.word_key, locale), "Offline English food vocabulary available")
			_expect(AudioManager.local_voice_available(entry.prompt_key, locale), "Offline English food request available")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 21):
			var round_model := FeedingRound.new(ids)
			_expect(round_model.begin(difficulty, seed_value), "Feeding session starts")
			var seen := {}
			for index: int in range(5):
				_expect(round_model.options.size() == FeedingRound.FOOD_CHOICES[difficulty], "Three/four/five foods by difficulty")
				var unique := {}
				for id: String in round_model.options:
					unique[id] = true
				_expect(unique.size() == round_model.options.size() and round_model.target in unique, "Unique valid choices include requested food")
				_expect(not seen.has(round_model.target), "Five distinct requests")
				seen[round_model.target] = true
				_expect(round_model.submit("unknown") == "ignored", "Unknown food ignored")
				var wrong: String = round_model.options.filter(func(id: String) -> bool: return id != round_model.target)[0]
				_expect(round_model.submit(wrong) == "incorrect" and round_model.solved == index, "Wrong food preserves request")
				_expect(not round_model.advance(), "Wrong food cannot advance")
				_expect(round_model.submit(round_model.target) == "correct", "Requested food accepted")
				_expect(round_model.submit(round_model.target) == "ignored", "No duplicate completion")
				_expect(round_model.advance() == (index < 4), "Five-task session ends")
			_expect(round_model.completed and round_model.solved == 5, "Session complete")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		_expect(app.current_view.find_child("FeedingButton", true, false) != null, "Playable feeding card exposed")
		GameManager.start_game("feeding")
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		_expect(game.state == game.State.QUESTION, "Game opens with request")
		_expect(game.message.text == LocalizationManager.text(game._entry(game.model.target).prompt_key), "English request under either UI locale")
		game.find_child("RepeatPrompt", true, false).pressed.emit()
		_expect(AudioManager.voice.stream.resource_path.ends_with("food_give_" + game.model.target + ".wav"), "Prompt repeat speaks requested food")
		var target: String = game.model.target
		var card := game.body.find_child("Food_" + target, true, false) as Control
		var start := card.get_global_rect().get_center()
		var destination: Vector2 = game.drop_zone.get_global_rect().get_center()
		var before := _attempts()
		await _mouse_drag(start, start)
		_expect(_attempts() == before and game.pointer_owner == -2, "Tap selects word without submitting food")
		_expect(game.word_button.text == LocalizationManager.object_name(game._entry(target)), "Tapped word shown by repeat control")
		await _mouse_drag(start, Vector2(5, 5))
		_expect(_attempts() == before and game.drag_id.is_empty(), "Outside drop returns without attempt")
		game.begin_drag(target, 0, start)
		game.set_overlay_paused(true)
		_expect(game.pointer_owner == -2 and is_equal_approx(card.modulate.a, 1.0), "Overlay cancels drag and restores card")
		game.set_overlay_paused(false)
		game.begin_drag(target, 0, start)
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.pointer_owner == -2 and game.feedback_timer.paused, "Focus loss cancels and pauses")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		game.begin_drag(target, 0, start)
		var canceled := InputEventScreenTouch.new()
		canceled.index = 0
		canceled.position = destination
		canceled.pressed = false
		canceled.canceled = true
		get_viewport().push_input(canceled, true)
		await _frames()
		_expect(_attempts() == before and game.pointer_owner == -2, "OS-canceled touch cannot feed")
		var wrong: String = game.model.options.filter(func(id: String) -> bool: return id != target)[0]
		var wrong_card := game.body.find_child("Food_" + wrong, true, false) as Control
		await _mouse_drag(wrong_card.get_global_rect().get_center(), destination)
		_expect(_attempts() == before + 1 and game.state == game.State.FEEDBACK, "Wrong mouse drag produces one gentle retry")
		game.end_drag(destination)
		_expect(_attempts() == before + 1, "Duplicate pointer release ignored")
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(game.model.target == target and game.state == game.State.QUESTION, "Retry restores same request")
		# Viewport-delivered touch verifies owner tracking, not physical Android input.
		var down := InputEventScreenTouch.new()
		down.index = 0
		down.pressed = true
		down.position = start
		get_viewport().push_input(down, true)
		await _frames()
		_expect(game.pointer_owner == 0, "Touch card captures the pointer")
		var other := InputEventScreenTouch.new()
		other.index = 1
		other.position = destination
		other.pressed = false
		get_viewport().push_input(other, true)
		await _frames()
		_expect(game.pointer_owner == 0 and _attempts() == before + 1, "Other finger cannot release owned drag")
		var motion := InputEventScreenDrag.new()
		motion.index = 0
		motion.position = destination
		get_viewport().push_input(motion, true)
		var up := InputEventScreenTouch.new()
		up.index = 0
		up.position = destination
		up.pressed = false
		get_viewport().push_input(up, true)
		await _frames()
		_expect(_attempts() == before + 2 and game.model.solved == 1, "Owned touch drop feeds exactly once")
		_expect(is_instance_valid(game.eating_visual), "Eating feedback displays offered food")
		game.feedback_timer.stop()
		game._finish_feedback()
		for index: int in range(4):
			await _frames()
			game.focus_paused = false
			var next_card := game.body.find_child("Food_" + game.model.target, true, false) as Control
			await _mouse_drag(next_card.get_global_rect().get_center(), game.drop_zone.get_global_rect().get_center())
			game.feedback_timer.stop()
			game._finish_feedback()
		_expect(game.state == game.State.COMPLETE, "Five successful drops reach picnic completion")
		game._show_complete()
		_expect(ProgressManager.document.games.feeding.completed_sessions == (1 if locale == "en" else 2), "Session awarded only once")
		game.find_child("Replay", true, false).pressed.emit()
		_expect(game.model.solved == 0 and game.state == game.State.QUESTION, "Replay starts clean")
		game.begin_drag(game.model.target, -1, game.drop_zone.get_global_rect().get_center())
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Exit cancels speech and pending drag")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.feeding.completed_tasks == 10 and ProgressManager.document.games.feeding.attempts == 12, "Only actual dropped attempts and solved tasks persisted")
	_expect(not ProgressManager.document.games.has("animals") and not ProgressManager.document.games.has("colors"), "Feeding progress isolated from other games")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("FEEDING TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _mouse_drag(start: Vector2, destination: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.pressed = true
	down.position = start
	get_viewport().push_input(down, true)
	await _frames()
	var motion := InputEventMouseMotion.new()
	motion.position = destination
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(motion, true)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = destination
	up.pressed = false
	get_viewport().push_input(up, true)
	await _frames()

func _attempts() -> int:
	return ProgressManager.document.games.get("feeding", {}).get("attempts", 0)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
