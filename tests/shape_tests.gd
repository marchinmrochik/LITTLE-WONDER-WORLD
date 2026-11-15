extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	get_tree().create_timer(30).timeout.connect(func() -> void:
		push_error("Shape test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/shapes-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	_expect(ContentManager.shapes.size() == 6, "Six required shapes loaded")
	_expect(AnimalCatalog.validate(ContentManager.shapes, true, 6).is_empty(), "Shape data/audio resource references validate")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.shapes:
		ids.append(entry.id)
		_expect(ResourceLoader.exists(entry.slot), "Neutral silhouette exists")
		for locale: String in ["en", "uk"]:
			_expect(AudioManager.local_voice_available(entry.word_key, locale), "English shape word available offline")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 31):
			var board := ShapeBoard.new(ids)
			_expect(board.begin(difficulty, seed_value), "Shape session starts")
			var covered := {}
			for board_index: int in range(3):
				_expect(board.sources.size() == ShapeBoard.COUNTS[difficulty], "Difficulty controls simultaneous pieces")
				_expect(board.sources != board.targets, "Source and target orders differ")
				var unique := {}
				for id: String in board.sources:
					unique[id] = true
					covered[id] = true
				_expect(unique.size() == board.sources.size(), "Unique pieces in a board")
				_expect(not board.advance(), "Unfinished board cannot advance")
				_expect(board.submit("unknown", board.targets[0]) == "ignored", "Unknown source rejected")
				for id: String in board.sources:
					var wrong: String = board.targets.filter(func(value: String) -> bool: return value != id)[0]
					if wrong not in board.placed:
						_expect(board.submit(id, wrong) == "incorrect", "Wrong shape cannot fit another silhouette")
					_expect(board.submit(id, "unknown") == "ignored", "Unknown destination ignored")
					_expect(board.submit(id, id) == "correct", "Shape identity matches regardless of screen order")
					_expect(board.submit(id, id) == "ignored", "Already placed piece cannot score again")
				_expect(board.board_complete(), "All pieces are required for board completion")
				_expect(board.advance() == (board_index < 2), "Exactly three boards")
			_expect(covered.size() == 6, "Every session covers all six forms")
			_expect(board.completed and board.solved == ShapeBoard.COUNTS[difficulty] * 3, "Session requires every match")
	var invalid := ShapeBoard.new(["circle", "circle", "triangle", "star", "heart", "square"])
	_expect(not invalid.begin("easy"), "Duplicate shape IDs rejected")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		_expect(app.current_view.find_child("ShapesButton", true, false) != null, "Working activity exposed")
		GameManager.start_game("shapes")
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		var id: String = game.model.sources[0]
		var other: String = game.model.sources[1]
		var card: Control = game.source_cards[id]
		var start := card.get_global_rect().get_center()
		var destination: Vector2 = game.slots[id].get_global_rect().get_center()
		var before := _attempts()
		await _mouse_drag(start, start)
		_expect(_attempts() == before and game.drag.pointer_owner == PointerDrag.NONE, "Tap speaks without scoring")
		game.find_child("RepeatWord", true, false).pressed.emit()
		_expect(AudioManager.voice.stream.resource_path.ends_with("shape_word_" + id + ".wav"), "Repeat speaks English under both locales")
		await _mouse_drag(start, Vector2(5, 5))
		_expect(_attempts() == before and is_equal_approx(card.modulate.a, 1), "Outside drop restores piece with no attempt")
		game.begin_drag(id, 0, start)
		game.set_overlay_paused(true)
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.preview == null, "Parent overlay cancels active drag")
		game.set_overlay_paused(false)
		game.begin_drag(id, 0, start)
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.feedback_timer.paused, "Focus loss cancels drag and pauses")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		await _mouse_drag(start, game.slots[other].get_global_rect().get_center())
		_expect(_attempts() == before + 1 and game.model.placed.is_empty(), "Wrong silhouette rejects piece")
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(is_equal_approx(card.modulate.a, 1) and game.state == game.State.SORTING, "Incorrect piece returns and can retry")
		# An unrelated finger cannot complete a drag owned by finger zero.
		var down := InputEventScreenTouch.new()
		down.index = 0
		down.position = start
		down.pressed = true
		get_viewport().push_input(down, true)
		await _frames()
		_expect(game.drag.pointer_owner == 0, "Viewport touch grabs piece")
		var other_up := InputEventScreenTouch.new()
		other_up.index = 1
		other_up.position = destination
		get_viewport().push_input(other_up, true)
		await _frames()
		_expect(game.drag.pointer_owner == 0 and _attempts() == before + 1, "Unrelated finger ignored")
		var canceled := InputEventScreenTouch.new()
		canceled.index = 0
		canceled.position = destination
		canceled.canceled = true
		get_viewport().push_input(canceled, true)
		await _frames()
		_expect(game.drag.pointer_owner == PointerDrag.NONE and _attempts() == before + 1, "OS canceled touch never places")
		# The drop tolerance accepts a point just outside the matching card.
		var rect: Rect2 = game.slots[id].get_global_rect()
		await _touch_drag(start, Vector2(rect.end.x + 6, rect.get_center().y))
		_expect(id in game.model.placed and _attempts() == before + 2, "Forgiving snap accepts near-edge matching drop")
		_expect(card.modulate.a == 0.0 and game.slot_pictures[id].texture.resource_path.ends_with(id + ".svg"), "Placed piece stays visible in its target")
		game.drag.release(destination)
		_expect(_attempts() == before + 2, "Duplicate release cannot duplicate task")
		game.feedback_timer.stop()
		game._finish_feedback()
		# Complete every remaining slot through viewport mouse events.
		for step: int in range(20):
			if game.state == game.State.COMPLETE:
				break
			await _frames()
			game.focus_paused = false
			var remaining: Array = game.model.sources.filter(func(value: String) -> bool: return value not in game.model.placed)
			var next_id: String = remaining[0]
			await _mouse_drag(game.source_cards[next_id].get_global_rect().get_center(), game.slots[next_id].get_global_rect().get_center())
			game.feedback_timer.stop()
			game._finish_feedback()
		_expect(game.state == game.State.COMPLETE, "All three layouts lead to completion")
		game._show_complete()
		_expect(ProgressManager.document.games.shapes.completed_sessions == (1 if locale == "en" else 2), "One session award despite repeated complete")
		game.find_child("Replay", true, false).pressed.emit()
		_expect(game.model.solved == 0 and game.model.index == 0, "Replay clears board placements")
		# Check the animated snap and focus pause independently of reduced motion.
		SettingsManager.set_value("reduced_motion", false)
		var animated_id: String = game.model.sources[0]
		await _frames()
		await _mouse_drag(game.source_cards[animated_id].get_global_rect().get_center(), game.slots[animated_id].get_global_rect().get_center())
		game.set_overlay_paused(true)
		_expect(game.feedback_timer.paused and not game.snap_tween.is_running(), "Overlay pauses snap and feedback")
		game.set_overlay_paused(false)
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(game.slot_pictures[animated_id].texture.resource_path.ends_with(animated_id + ".svg"), "Animation settles placed shape")
		SettingsManager.set_value("reduced_motion", true)
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Leaving stops shape speech")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.shapes.completed_tasks == 14 and ProgressManager.document.games.shapes.attempts == 16, "Real attempts/tasks persist across reload")
	_expect(not ProgressManager.document.games.has("feeding"), "Shape progress isolated")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("SHAPES TESTS: %d checks, %d failures" % [checks, failures.size()])
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
	get_viewport().push_input(up, true)
	await _frames()

func _attempts() -> int:
	return ProgressManager.document.games.get("shapes", {}).get("attempts", 0)

func _touch_drag(start: Vector2, destination: Vector2) -> void:
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
	await _frames()

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
