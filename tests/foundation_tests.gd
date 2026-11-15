extends Node

var checks := 0
var failures: PackedStringArray = []
var fixture := "user://test-runs/foundation-" + str(Time.get_ticks_usec())

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var old_settings_path: String = SettingsManager.storage_path
	var old_progress_path: String = ProgressManager.storage_path
	var old_values := SettingsManager.values.duplicate(true)
	var old_document := ProgressManager.document.duplicate(true)
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.changed.emit("locale")
	_expect(SettingsManager.values.locale == "en" and SettingsManager.values.difficulty == "easy", "Fresh install defaults to English/Easy")
	_expect(TranslationServer.get_locale() == "en", "Fresh locale overrides system locale")
	_expect(not SettingsManager.set_value("locale", "ru"), "Unsupported locale rejected")
	_expect(not SettingsManager.set_value("sfx_volume", -0.1), "Out-of-range volume rejected")
	_expect(not SettingsManager.set_value("music_volume", "loud"), "Wrong volume type rejected")
	_expect(SettingsManager.set_value("locale", "uk"), "Ukrainian saved")
	_expect(SettingsManager.set_value("difficulty", "advanced"), "Difficulty saved")
	SettingsManager.reload()
	_expect(SettingsManager.values.locale == "uk" and SettingsManager.values.difficulty == "advanced", "Settings reload round trip")
	_write(SettingsManager.storage_path, "{broken")
	SettingsManager.reload()
	_expect(SettingsManager.load_status == "recovered" and SettingsManager.values.locale == "uk", "Corrupt primary recovers validated backup")
	_expect(SettingsManager.set_value("sfx_volume", 0.42), "Recovered settings can be saved")
	_expect(FileAccess.file_exists(SettingsManager.storage_path + ".invalid"), "Damaged primary retained separately")
	_write(SettingsManager.storage_path, '{"version":99}')
	SettingsManager.reload()
	_expect(SettingsManager.load_status == "incompatible" and not SettingsManager.save(), "Newer schema is protected even with an older valid backup")
	_expect(FileAccess.get_file_as_string(SettingsManager.storage_path) == '{"version":99}', "Newer schema is not overwritten")
	SettingsManager.storage_path = fixture + "/ui-settings.json"
	SettingsManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.changed.emit("locale")
	_expect(ContentManager.validate().is_empty(), "All foundation resources and speech keys resolve")
	var original_manifest := ContentManager.manifest.duplicate(true)
	ContentManager.manifest = {}
	_expect(not ContentManager.validate().is_empty(), "Missing manifest sections are rejected")
	ContentManager.manifest = original_manifest
	ContentManager.validate()
	var en: Dictionary = LocalizationManager.messages.en
	var uk: Dictionary = LocalizationManager.messages.uk
	_expect(en.size() == uk.size(), "Translation catalogs have matching sizes")
	for key: String in en:
		_expect(uk.has(key) and not str(uk.get(key, "")).is_empty(), "Translation exists: " + key)
	var font: Font = UiKit.FONT
	for letter: String in "ҐґЄєІіЇї":
		_expect(font.has_char(letter.unicode_at(0)), "Font contains Ukrainian glyph: " + letter)
	ProgressManager.record_companion_visit()
	ProgressManager.record_answer("animals", "cat", true)
	ProgressManager.record_answer("animals", "cat", false)
	ProgressManager.reload()
	_expect(ProgressManager.document.companion_visits == 1, "Companion visit persisted")
	_expect(ProgressManager.document.games.animals.attempts == 2 and ProgressManager.document.games.animals.correct == 1, "Practice attempt counts persisted without inventing mastery")
	_write(ProgressManager.storage_path, '{"version":1,"companion_visits":-4,"games":{}}')
	ProgressManager.reload()
	_expect(ProgressManager.load_status == "recovered", "Invalid progress counts recover backup")
	_write(fixture + "/drawing-keep.txt", "fixture drawing")
	_expect(ProgressManager.reset_progress(), "Progress reset succeeds")
	_expect(ProgressManager.document.games.is_empty() and FileAccess.file_exists(fixture + "/drawing-keep.txt"), "Progress reset preserves unrelated artwork")
	_expect(not GameManager.navigate("settings"), "Parent route is locked before the barrier")
	_expect(not GameManager.navigate("missing"), "Unknown route rejected")
	_expect(not GameManager.register_game("missing", "res://missing.tscn", "english"), "Missing game scenes cannot be registered")
	var app: Variant = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	app.current_view.find_child("FoxieButton", true, false).pressed.emit()
	_expect(app.current_view.fox.current_state == "waving", "Foxie's home greeting uses the waving state")
	app.open_parent_gate()
	await _frames()
	var gate: ParentGate = app.modal
	gate.choose(gate.answer + 1)
	_expect(GameManager.current_route == "home", "Incorrect parent answer does not unlock settings")
	gate.choose(gate.answer)
	await _frames()
	_expect(GameManager.current_route == "settings", "Correct parent answer opens settings")
	var language_button: Button = app.current_view.find_child("Language_uk", true, false)
	language_button.pressed.emit()
	await _frames()
	_expect(TranslationServer.get_locale() == "uk" and app.current_view.find_child("Language_uk", true, false) != null, "Language changes live while settings remain mounted")
	var advanced: Button = app.current_view.find_child("Difficulty_advanced", true, false)
	advanced.pressed.emit()
	await _frames()
	_expect(SettingsManager.values.difficulty == "advanced", "Rendered difficulty control updates settings")
	SettingsManager.set_value("locale", "en")
	GameManager.return_home()
	await _frames()
	_expect(GameManager.current_route == "home" and app.current_view.name == "Home", "Language refresh cannot restore a stale route after immediate navigation")
	SettingsManager.set_value("sfx_volume", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Zero volume mutes the effects bus")
	SettingsManager.set_value("sfx_volume", 0.55)
	_expect(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Nonzero volume unmutes the effects bus")
	var effect_index: int = AudioManager.effect_cursor
	AudioManager.play_sfx("tap")
	_expect(AudioManager.effects[effect_index].playing, "Local interaction effect starts playback")
	SettingsManager.set_value("music_enabled", false)
	_expect(not AudioManager.music.playing, "Background music can be stopped")
	SettingsManager.set_value("music_enabled", true)
	_expect(AudioManager.music.playing, "Background music can be restarted")
	app._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_expect(AudioManager.music.stream_paused, "Focus loss pauses music")
	app._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	_expect(not AudioManager.music.stream_paused, "Focus return resumes music")
	GameManager.navigate("meadow")
	await _frames()
	app.current_view.interact("FOX_REST")
	_expect(AudioManager.resting and app.current_view.fox.resting, "Companion rest changes audio and character state")
	GameManager.return_home()
	await _frames()
	_expect(not GameManager.parents_unlocked and not AudioManager.resting, "Child navigation clears adult access and rest state")
	app.open_parent_gate()
	await _frames()
	var hold := ParentHoldButton.new()
	add_child(hold)
	var hold_state := {"opened": false}
	hold.hold_completed.connect(func() -> void: hold_state.opened = true)
	hold.button_down.emit()
	hold._process(1.0)
	_expect(not hold_state.opened, "Short hold cannot open the parent barrier")
	hold._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	hold._process(1.1)
	_expect(not hold_state.opened and not hold.holding, "Focus loss cancels an incomplete adult hold")
	hold.button_down.emit()
	hold._process(2.1)
	_expect(hold_state.opened, "Two-second hold opens the parent challenge")
	hold.queue_free()
	app._back()
	_expect(not is_instance_valid(app.modal), "Back dismisses the barrier")
	app.queue_free()
	await _frames()
	SettingsManager.storage_path = old_settings_path
	ProgressManager.storage_path = old_progress_path
	SettingsManager.values = old_values
	ProgressManager.document = old_document
	SettingsManager.changed.emit("locale")
	print("FOUNDATION TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	await AudioManager.shutdown()
	get_tree().quit(0 if failures.is_empty() else 1)

func _frames() -> void:
	for index: int in range(4):
		await get_tree().process_frame

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)

func _write(path: String, value: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()
