extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var fixture := "user://test-runs/colors-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	_expect(ContentManager.colors.size() == 8, "Eight colors loaded")
	_expect(AnimalCatalog.validate(ContentManager.colors, true, 8).is_empty(), "Color catalog resource paths validate")
	var broken := ContentManager.colors.duplicate(true)
	broken[1].id = broken[0].id
	_expect(not AnimalCatalog.validate(broken, true, 8).is_empty(), "Duplicate colors rejected")
	var ids: Array[String] = []
	for entry: Dictionary in ContentManager.colors:
		_expect(not entry.id in ids, "Unique color ID")
		ids.append(entry.id)
		_expect(ResourceLoader.exists(entry.illustration), "Color illustration exists")
		for locale: String in ["en", "uk"]:
			_expect(AudioManager.local_voice_available(entry.word_key, locale), "Word available offline")
			_expect(AudioManager.local_voice_available(entry.prompt_key, locale), "Prompt available offline")
	for difficulty: String in ["easy", "normal", "advanced"]:
		for seed_value: int in range(1, 11):
			var model := AnimalRound.new(ids)
			_expect(model.begin(difficulty, seed_value), "Color session begins")
			var seen := {}
			for index: int in range(5):
				_expect(model.options.size() == AnimalRound.CHOICES[difficulty], "Difficulty controls choices")
				_expect(model.target in model.options and not seen.has(model.target), "Unique answerable task")
				seen[model.target] = true
				_expect(model.submit(model.target) == "correct", "Target accepted")
				_expect(model.advance() == (index < 4), "Five-task session ends")
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		_expect(app.current_view.find_child("ColorsButton", true, false) != null, "Real Colors activity exposed")
		GameManager.start_game("colors")
		await _frames()
		var game: Variant = app.current_view
		_expect(game.game_id == "colors", "Shared activity uses the colors catalog")
		game._explore_animal("red")
		_expect(AudioManager.voice.stream.resource_path.ends_with("color_word_red.wav"), "Explore speaks English color")
		game.find_child("RepeatWord", true, false).pressed.emit()
		_expect(AudioManager.voice.stream.resource_path.ends_with("color_word_red.wav"), "Speaker repeats selected color")
		game._change_page(1)
		_expect(game.page == 1 and game.body.find_child("Animal_orange", true, false) != null, "Second page exposes remaining colors")
		game.start_quiz()
		await _frames()
		game.focus_paused = false
		var target: String = game.model.target
		var wrong: String = game.model.options.filter(func(id: String) -> bool: return id != target)[0]
		var before: int = ProgressManager.document.games.get("colors", {}).get("attempts", 0)
		game.choose(wrong)
		game.choose(target)
		_expect(ProgressManager.document.games.colors.attempts == before + 1, "Rapid second tap ignored")
		game.feedback_timer.stop()
		game._finish_feedback()
		_expect(game.model.target == target, "Wrong answer retains task")
		game.repeat_prompt()
		_expect(AudioManager.voice.stream.resource_path.ends_with("color_find_" + target + ".wav"), "English prompt repeats")
		for index: int in range(5):
			game.choose(game.model.target)
			game.feedback_timer.stop()
			game._finish_feedback()
		_expect(game.state == game.State.COMPLETE, "Completion reached")
		game._show_complete()
		_expect(ProgressManager.document.games.colors.completed_sessions == (1 if locale == "en" else 2), "Completion awards once")
		game.find_child("Replay", true, false).pressed.emit()
		_expect(game.model.solved == 0, "Replay resets session")
		GameManager.return_home()
		await _frames()
		_expect(not AudioManager.voice.playing, "Leaving stops speech")
	ProgressManager.reload()
	_expect(ProgressManager.document.games.colors.completed_tasks == 10, "Color task counts persist")
	_expect(not ProgressManager.document.games.has("animals"), "Color progress does not alter Animals")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("COLORS TESTS: %d checks, %d failures" % [checks, failures.size()])
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
