extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/animals-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.changed.emit("locale")
	var entries := ContentManager.animals
	_expect(entries.size() >= 12, "At least twelve animal entries loaded")
	_expect(AnimalCatalog.validate(entries).is_empty(), "Catalog paths, IDs and local word/prompt audio validate")
	var broken := entries.duplicate(true)
	broken[1].id = broken[0].id
	_expect(not AnimalCatalog.validate(broken).is_empty(), "Duplicate IDs rejected")
	broken = entries.duplicate(true)
	broken[0].illustration = "res://assets/../missing.svg"
	_expect(not AnimalCatalog.validate(broken).is_empty(), "Unsafe/missing illustration rejected")
	SettingsManager.set_value("music_enabled", true)
	var spoken := AudioManager.say("WORD_CAT", "en")
	_expect(spoken, "Bundled learning speech works with the system-voice fallback disabled")
	if spoken:
		_expect(is_equal_approx(AudioManager.music.volume_db, -8.0), "Music is ducked while a local voice plays")
		for wait_step: int in range(60):
			await get_tree().create_timer(0.05).timeout
			if not AudioManager.voice.playing:
				break
		await _frames()
		_expect(not AudioManager.voice.playing and is_zero_approx(AudioManager.music.volume_db), "Music returns to its normal level after speech ends")
		if AudioManager.voice.playing or not is_zero_approx(AudioManager.music.volume_db):
			print("VOICE FINISH DEBUG: playing=", AudioManager.voice.playing, " music_db=", AudioManager.music.volume_db, " length=", AudioManager.voice.stream.get_length(), " position=", AudioManager.voice.get_playback_position())
	SettingsManager.set_value("music_enabled", false)
	var ids: Array[String] = []
	for entry: Dictionary in entries:
		ids.append(entry.id)
		for locale: String in ["en", "uk"]:
			_expect(LocalizationManager.messages[locale][entry.word_key] == entry.get("ukrainian" if locale == "uk" else "english"), "Learning word stays English: " + entry.id + ":" + locale)
			_expect(AudioManager.local_voice_available(entry.prompt_key, locale), "Local prompt available: " + entry.id + ":" + locale)
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 31):
			var round_model := AnimalRound.new(ids)
			_expect(round_model.begin(difficulty, seed_value), "Session starts with supported difficulty")
			var target_set := {}
			for index: int in range(5):
				_expect(round_model.target in round_model.options, "Target is among choices")
				_expect(round_model.options.size() == AnimalRound.CHOICES[difficulty], "Choice count matches difficulty")
				var unique := {}
				for id: String in round_model.options:
					unique[id] = true
				_expect(unique.size() == round_model.options.size(), "Choices are unique")
				_expect(not target_set.has(round_model.target), "Targets do not repeat within a short session")
				target_set[round_model.target] = true
				_expect(round_model.submit("invalid") == "ignored", "Unknown choice ignored")
				var incorrect: String = round_model.options.filter(func(id: String) -> bool: return id != round_model.target)[0]
				_expect(round_model.submit(incorrect) == "incorrect" and round_model.solved == index, "Incorrect answer does not advance or punish")
				_expect(not round_model.advance(), "Unsolved round cannot advance")
				_expect(round_model.submit(round_model.target) == "correct", "Target answer succeeds")
				_expect(round_model.submit(round_model.target) == "ignored", "Double correct submission ignored")
				var moved := round_model.advance()
				_expect(moved == (index < 4), "Only five rounds before completion")
			_expect(round_model.completed and round_model.solved == 5, "Session completes after five solved rounds")
	var app: Variant = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	GameManager.navigate("activities")
	await _frames()
	_expect(app.current_view.find_child("AnimalsButton", true, false) != null, "Only real Animals activity is exposed")
	app.current_view.find_child("AnimalsButton", true, false).pressed.emit()
	await _frames()
	var game: Variant = app.current_view
	_expect(game.state == game.State.EXPLORE, "Animals opens in exploration mode")
	game._explore_animal("cat")
	_expect(AudioManager.voice.playing and AudioManager.voice.stream.resource_path.ends_with("word_cat.wav"), "Exploration plays the English word from a local file")
	game.find_child("RepeatWord", true, false).pressed.emit()
	_expect(AudioManager.voice.stream.resource_path.ends_with("word_cat.wav"), "Dedicated speaker repeats the selected English word")
	game._change_page(1)
	_expect(game.page == 1 and game.body.find_child("Animal_sheep", true, false) != null, "Exploration pages expose additional animals")
	game.start_quiz()
	await _frames()
	var correct_id: String = game.model.target
	var wrong_id: String = game.model.options.filter(func(id: String) -> bool: return id != correct_id)[0]
	game.choose(wrong_id)
	game.choose(correct_id)
	_expect(ProgressManager.document.games.animals.attempts == 1, "Feedback guard ignores rapid second input")
	game.feedback_timer.stop()
	game._finish_feedback()
	_expect(game.model.target == correct_id and game.state == game.State.QUESTION, "Wrong answer retains the same task")
	game.repeat_prompt()
	_expect(AudioManager.voice.stream.resource_path.ends_with("find_" + correct_id + ".wav"), "Repeat button replays the current English prompt")
	for index: int in range(5):
		game.choose(game.model.target)
		var attempts: int = ProgressManager.document.games.animals.attempts
		game.choose(game.model.target)
		_expect(ProgressManager.document.games.animals.attempts == attempts, "Correct feedback cannot double-record an answer")
		game.feedback_timer.stop()
		game._finish_feedback()
	_expect(game.state == game.State.COMPLETE, "UI reaches the completion screen")
	_expect(ProgressManager.document.games.animals.completed_tasks == 5 and ProgressManager.document.games.animals.completed_sessions == 1, "Task and session completion recorded separately")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.animals.attempts == 6 and ProgressManager.document.games.animals.correct == 5, "Practice survives reload with actual wrong/correct attempts")
	game.find_child("Replay", true, false).pressed.emit()
	_expect(game.state == game.State.QUESTION and game.model.solved == 0, "Replay starts a fresh session")
	game.choose(game.model.target)
	app.open_parent_gate()
	_expect(game.feedback_timer.paused, "Parent overlay pauses pending task transitions")
	app.close_modal()
	_expect(not game.feedback_timer.paused, "Closing overlay resumes pending feedback")
	game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_expect(game.feedback_timer.paused, "Focus loss pauses feedback")
	game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	game.start_quiz()
	await _frames()
	var touch_id: String = game.model.target
	var touch_card := game.body.find_child("Animal_" + touch_id, true, false) as Control
	var touch_position := touch_card.get_global_rect().get_center()
	var before_touch: int = ProgressManager.document.games.animals.attempts
	for pressed: bool in [true, false]:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = touch_position
		touch.pressed = pressed
		get_viewport().push_input(touch, true)
		await _frames()
	_expect(ProgressManager.document.games.animals.attempts == before_touch + 1, "Viewport-injected touch selects an animal exactly once")
	GameManager.return_home()
	await _frames()
	_expect(not AudioManager.voice.playing, "Leaving the game cancels prompt/feedback speech")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("ANIMALS TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
