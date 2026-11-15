extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	get_tree().create_timer(40).timeout.connect(func() -> void:
		push_error("Puzzle test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/puzzles-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	_expect(ContentManager.puzzles.size() == 6, "Six puzzle pictures available")
	_expect(AnimalCatalog.validate(ContentManager.puzzles, true, 6).is_empty(), "Original art and reused word resources validate")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.puzzles:
		ids.append(entry.id)
	var inactive := PuzzleRound.new(ids)
	_expect(inactive.submit(0, 0) == "ignored", "Unstarted puzzle cannot accept a piece")
	_expect(not inactive.advance(), "Unstarted puzzle cannot advance")
	var duplicate := PuzzleRound.new(["cat", "cat", "dog"])
	_expect(not duplicate.begin("easy"), "Duplicate picture IDs cannot start a session")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 31):
			var round_model := PuzzleRound.new(ids)
			_expect(round_model.begin(difficulty, seed_value), "Puzzle round starts")
			var seen := {}
			for picture: int in range(3):
				_expect(not seen.has(round_model.picture_id()), "Session pictures do not repeat")
				seen[round_model.picture_id()] = true
				_expect(round_model.piece_count() == {"easy":2,"normal":4,"advanced":6}[difficulty], "Difficulty selects 2/4/6 parts")
				_expect(not round_model.advance(), "Unfinished picture cannot advance")
				var area := 0.0
				var regions: Array[Rect2] = []
				for piece: int in round_model.tray_order:
					var region := round_model.region(piece, Vector2(300, 300))
					_expect(Rect2(0, 0, 300, 300).encloses(region), "Crop stays within source image")
					for previous: Rect2 in regions:
						_expect(not previous.intersects(region), "Puzzle cuts do not overlap")
					regions.append(region)
					area += region.get_area()
				_expect(is_equal_approx(area, 90000), "Cuts tile the whole original picture without gaps")
				_expect(round_model.submit(-1, 0) == "ignored", "Unknown piece cannot place")
				for piece: int in range(round_model.piece_count()):
					if piece == 0:
						_expect(round_model.submit(0, 1) == "incorrect", "A piece cannot fit a different position")
					_expect(round_model.submit(piece, piece) == "correct", "Correct crop position accepted")
					_expect(round_model.submit(piece, piece) == "ignored", "Duplicate placement ignored")
					_expect(round_model.picture_complete() == (piece == round_model.piece_count() - 1), "Picture complete only after every part")
				_expect(round_model.advance() == (picture < 2), "Exactly three completed pictures per round")
			_expect(round_model.completed and seen.size() == 3, "Full round ends")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		app.current_view.ensure_activity("puzzles")
		await _frames()
		_expect(app.current_view.find_child("PuzzlesButton", true, false) != null, "Playable puzzle menu card exposed")
		app.current_view.find_child("PuzzlesButton", true, false).pressed.emit()
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		_expect(game.hint_visible and game.template.visible, "Easy starts with translucent picture hint")
		game.hint_button.pressed.emit()
		_expect(not game.template.visible, "Hint toggles off")
		game.hint_button.pressed.emit()
		_expect(game.template.visible, "Hint toggles back on")
		game.find_child("RepeatWord", true, false).pressed.emit()
		_expect(AudioManager.voice.stream.resource_path.ends_with("word_" + game.model.picture_id() + ".wav"), "Animal word reuses local English audio under both locales")
		# Verify actual AtlasTexture crops as well as the model's rectangle arithmetic.
		for difficulty: String in ["easy", "normal", "advanced"]:
			game.model.begin(difficulty, 42)
			game._show_picture()
			await _frames()
			var original: Image = game.atlas.get_image()
			for piece: int in range(game.model.piece_count()):
				var texture: AtlasTexture = game._piece_texture(piece)
				var cropped := texture.get_image()
				var region: Rect2 = texture.region
				_expect(cropped.get_size() == Vector2i(region.size), "Atlas piece has the expected crop dimensions")
				var middle := cropped.get_size() / 2
				_expect(cropped.get_pixelv(middle).is_equal_approx(original.get_pixelv(Vector2i(region.position) + middle)), "Crop pixels come from the corresponding original region")
		game.model.begin("easy", 42)
		game._show_picture()
		await _frames()
		game.focus_paused = false
		var picture_id: String = game.model.picture_id()
		var before := _attempts()
		var start: Vector2 = game.source_cards[0].get_global_rect().get_center()
		var destination: Vector2 = game.slots[0].get_global_rect().get_center()
		game.next_picture()
		_expect(game.model.index == 0, "Next cannot skip an incomplete puzzle")
		await _mouse_drag(start, Vector2(5, 5))
		_expect(_attempts() == before and game.drag_piece == -1, "Outside drop cancels without attempt")
		game.begin_drag(0, 0, start)
		game.set_overlay_paused(true)
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.preview == null, "Overlay cancels owned puzzle drag")
		game.set_overlay_paused(false)
		game.begin_drag(0, 0, start)
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.drag.pointer_owner == PointerDrag.NONE and game.feedback_timer.paused, "Focus loss cancels and pauses")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		await _mouse_drag(start, game.slots[1].get_global_rect().get_center())
		_expect(_attempts() == before + 1 and game.model.placed.is_empty(), "Wrong region rejects piece")
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(is_equal_approx(game.source_cards[0].modulate.a, 1), "Wrong part returns to tray")
		# Owner touch survives a second finger's release; cancellation never submits.
		game.begin_drag(0, 0, start)
		var other := InputEventScreenTouch.new()
		other.index = 1
		other.position = destination
		get_viewport().push_input(other, true)
		_expect(game.drag.pointer_owner == 0, "Other finger cannot release puzzle piece")
		var cancel := InputEventScreenTouch.new()
		cancel.index = 0
		cancel.position = destination
		cancel.canceled = true
		get_viewport().push_input(cancel, true)
		_expect(_attempts() == before + 1 and game.drag.pointer_owner == PointerDrag.NONE, "Canceled touch never places")
		await _touch_drag(start, destination)
		_expect(0 in game.model.placed and game.slot_pictures[0].visible, "Touch drop reveals exact fragment in board")
		game.drag.release(destination)
		_expect(_attempts() == before + 2, "Duplicate release does not double count")
		game.feedback_timer.stop()
		game._finish_feedback()
		game.find_child("RestartPicture", true, false).pressed.emit()
		await _frames()
		_expect(game.model.placed.is_empty() and game.model.picture_id() == picture_id and game.model.index == 0, "Restart clears current picture without skipping it")
		for step: int in range(24):
			if game.state == game.State.COMPLETE:
				break
			await _frames()
			game.focus_paused = false
			if game.state == game.State.PICTURE_DONE:
				_expect(not game.next_button.disabled, "Next unlocks only after all parts")
				game.next_button.pressed.emit()
				continue
			var piece := 0
			while piece in game.model.placed:
				piece += 1
			await _mouse_drag(game.source_cards[piece].get_global_rect().get_center(), game.slots[piece].get_global_rect().get_center())
			game.feedback_timer.stop()
			game._finish_feedback()
		_expect(game.state == game.State.COMPLETE, "All parts of three pictures required for session completion")
		game._show_complete()
		_expect(ProgressManager.document.games.puzzles.completed_sessions == (1 if locale == "en" else 2), "Session completion awarded once")
		game.find_child("Replay", true, false).pressed.emit()
		_expect(game.model.index == 0 and game.model.placed.is_empty(), "Replay starts a fresh three-picture session")
		SettingsManager.set_value("reduced_motion", false)
		await _frames()
		await _mouse_drag(game.source_cards[0].get_global_rect().get_center(), game.slots[0].get_global_rect().get_center())
		game.set_overlay_paused(true)
		_expect(game.feedback_timer.paused and not game.snap_tween.is_running(), "Overlay pauses animated snap")
		game.set_overlay_paused(false)
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(game.slot_pictures[0].visible, "Animated snap settles to its exact crop")
		SettingsManager.set_value("reduced_motion", true)
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Exit cancels puzzle speech")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.puzzles.completed_tasks == 16 and ProgressManager.document.games.puzzles.attempts == 18, "Actual practice placements and wrong attempts persist, including replay practice")
	_expect(not ProgressManager.document.games.has("shapes"), "Puzzle counters isolated")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("PUZZLES TESTS: %d checks, %d failures" % [checks, failures.size()])
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
	var move := InputEventMouseMotion.new()
	move.position = destination
	move.button_mask = MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(move, true)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = destination
	get_viewport().push_input(up, true)
	await _frames()

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

func _attempts() -> int:
	return ProgressManager.document.games.get("puzzles", {}).get("attempts", 0)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
