extends Control

signal reset_requested

var status: Label
var pending_volumes: Dictionary = {}
var volume_timer := Timer.new()

func _ready() -> void:
	volume_timer.one_shot = true
	volume_timer.wait_time = 0.25
	add_child(volume_timer)
	volume_timer.timeout.connect(_commit_volumes)
	var scroll := TouchScroll.new()
	scroll.name = "SettingsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	scroll.add_child(margin)
	var content := UiKit.column(24)
	margin.add_child(content)
	content.add_child(UiKit.paragraph("SETTINGS_HINT", 25))
	status = UiKit.label("SAVED", 19, UiKit.GREEN)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(status)
	var columns := UiKit.row(24)
	content.add_child(columns)
	var left := _section(columns, "LANGUAGE")
	left.add_child(UiKit.paragraph("LANGUAGE_HINT", 19))
	var languages := UiKit.row(12)
	left.add_child(languages)
	for entry: Array in [["en", "ENGLISH"], ["uk", "UKRAINIAN"]]:
		var locale: String = entry[0]
		var choice := UiKit.button(entry[1], func() -> void: _commit_volumes(); SettingsManager.set_value("locale", locale), UiKit.MINT if SettingsManager.values.locale == locale else UiKit.CREAM)
		choice.name = "Language_" + locale
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		languages.add_child(choice)
	_add_toggle(left,"english_ukrainian_translation","EN_UK_TRANSLATIONS")
	left.add_child(UiKit.paragraph("EN_UK_TRANSLATIONS_HINT",18))
	left.add_child(UiKit.label("DIFFICULTY", 27))
	for entry: Array in [["easy", "EASY"], ["normal", "NORMAL"], ["advanced", "ADVANCED"]]:
		var difficulty: String = entry[0]
		var choice := UiKit.button(entry[1], _choose_difficulty.bind(difficulty), UiKit.MINT if SettingsManager.values.difficulty == difficulty else UiKit.CREAM)
		choice.name = "Difficulty_" + difficulty
		left.add_child(choice)
	left.add_child(UiKit.paragraph("DIFFICULTY_HINT", 18))
	var right := _section(columns, "SOUND")
	for entry: Array in [["music_volume", "MUSIC_VOLUME"], ["voice_volume", "VOICE_VOLUME"], ["sfx_volume", "SFX_VOLUME"]]:
		_add_volume(right, entry[0], entry[1])
	_add_toggle(right, "music_enabled", "MUSIC_ENABLED")
	_add_toggle(right, "reduced_motion", "REDUCED_MOTION")
	_add_toggle(right,"coloring_reference","BOOK_EXAMPLE")
	_add_toggle(right, "system_voice_enabled", "SYSTEM_VOICE")
	right.add_child(UiKit.paragraph("VOICE_NOTE", 18))
	right.add_child(UiKit.paragraph("VOICE_J_CREDIT",16))
	right.add_child(UiKit.paragraph("SYSTEM_VOICE_NOTE", 18))
	var available := AudioManager.voice_available(SettingsManager.values.locale)
	right.add_child(UiKit.paragraph("VOICE_AVAILABLE" if available else "VOICE_MISSING", 18))
	var preview := UiKit.button("VOICE_TEST", func() -> void: AudioManager.say("FOX_HELLO"), UiKit.MINT)
	preview.disabled = not AudioManager.local_voice_available("FOX_HELLO", SettingsManager.values.locale) and (not SettingsManager.values.system_voice_enabled or not available)
	right.add_child(preview)
	var practice := _section(content, "PROGRESS")
	var visits := UiKit.label("", 23)
	visits.text = LocalizationManager.text("COMPANION_VISITS").format({"count": ProgressManager.document.companion_visits})
	practice.add_child(visits)
	var sessions := UiKit.label("", 23)
	sessions.text = LocalizationManager.text("COMPLETED_ANIMAL_SESSIONS").format({"count": ProgressManager.document.games.get("animals", {}).get("completed_sessions", 0)})
	practice.add_child(sessions)
	var attempts := 0
	var correct := 0
	for game: Dictionary in ProgressManager.document.games.values():
		attempts += int(game.attempts)
		correct += int(game.correct)
	var learning := UiKit.paragraph("NO_LEARNING_YET" if attempts == 0 else "LEARNING_SUMMARY")
	if attempts > 0:
		learning.text = learning.text.format({"correct": correct, "attempts": attempts})
	practice.add_child(learning)
	practice.add_child(UiKit.paragraph("PROGRESS_HINT", 18))
	var history := UiKit.button("HISTORY_OPEN",func() -> void:GameManager.navigate("assessment_history"),UiKit.MINT,"search")
	history.name="OpenAssessmentHistory"
	practice.add_child(history)
	var reset := UiKit.button("RESET_PROGRESS", func() -> void: reset_requested.emit(), UiKit.CORAL)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	practice.add_child(reset)
	var gallery := _section(content, "GALLERY")
	gallery.add_child(UiKit.paragraph("DRAW_GALLERY_COUNT"))
	gallery.get_child(gallery.get_child_count() - 1).text = LocalizationManager.text("DRAW_GALLERY_COUNT").format({"count":ArtworkManager.entries.size(),"limit":ArtworkManager.MAX_ENTRIES})
	gallery.add_child(UiKit.button("DRAW_OPEN_GALLERY", func() -> void: GameManager.navigate("gallery"), UiKit.MINT))
	var privacy := _section(content, "PRIVACY")
	privacy.add_child(UiKit.paragraph("PRIVACY_HINT", 20))
	SettingsManager.changed.connect(_update_status.unbind(1))
	SettingsManager.storage_failed.connect(_update_status)
	ProgressManager.storage_failed.connect(_update_status)
	AssessmentHistory.storage_failed.connect(_update_status)
	_update_status()

func _section(parent: Container, title: String) -> VBoxContainer:
	var card := UiKit.card()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)
	var content := UiKit.column(16)
	card.add_child(content)
	content.add_child(UiKit.label(title, 29))
	return content

func _add_volume(parent: VBoxContainer, key: String, title: String) -> void:
	var row := UiKit.row()
	parent.add_child(row)
	row.add_child(UiKit.label(title, 21))
	row.add_child(UiKit.spacer())
	var amount := UiKit.label("", 21, UiKit.MUTED)
	amount.text = "%d%%" % int(SettingsManager.values[key] * 100)
	row.add_child(amount)
	var slider := HSlider.new()
	slider.name = key
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = SettingsManager.values[key] * 100
	slider.custom_minimum_size.y = 42
	parent.add_child(slider)
	slider.value_changed.connect(func(value: float) -> void:
		amount.text = "%d%%" % int(value)
		pending_volumes[key] = value / 100.0
		var bus: String = {"music_volume": "Music", "voice_volume": "Voice", "sfx_volume": "SFX"}[key]
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(maxf(value / 100.0, 0.0001)))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), value == 0)
		volume_timer.start()
	)
	slider.drag_ended.connect(func(_changed: bool) -> void: _commit_volumes())

func _add_toggle(parent: VBoxContainer, key: String, title: String) -> void:
	var row := UiKit.row(14)
	parent.add_child(row)
	var caption := UiKit.paragraph(title, 20)
	caption.add_theme_color_override("font_color", UiKit.INK)
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(caption)
	var active: bool = SettingsManager.values[key]
	var toggle := UiKit.button("ON" if active else "OFF", func() -> void:
		_commit_volumes()
		SettingsManager.set_value(key, not SettingsManager.values[key])
		get_tree().get_first_node_in_group("app_root").call_deferred("_show_route", "settings")
	, UiKit.MINT if active else UiKit.CREAM)
	toggle.name = key
	toggle.custom_minimum_size = Vector2(86, 60)
	row.add_child(toggle)

func _choose_difficulty(value: String) -> void:
	_commit_volumes()
	SettingsManager.set_value("difficulty", value)
	get_tree().get_first_node_in_group("app_root").call_deferred("_show_route", "settings")

func _commit_volumes() -> void:
	volume_timer.stop()
	var changes := pending_volumes.duplicate()
	pending_volumes.clear()
	for key: String in changes:
		SettingsManager.set_value(key, changes[key])

func _update_status() -> void:
	if not is_instance_valid(status):
		return
	var key := "SAVED"
	if SettingsManager.last_save_error != OK or ProgressManager.last_save_error != OK or AssessmentHistory.last_save_error != OK:
		key = "SAVE_ERROR"
	else:
		for state: String in [SettingsManager.load_status, ProgressManager.load_status, AssessmentHistory.load_status]:
			if state in ["incompatible", "unreadable", "recovered"]:
				key = state.to_upper()
	status.text = LocalizationManager.text(key)
	status.add_theme_color_override("font_color", Color("a74f40") if key in ["SAVE_ERROR", "INCOMPATIBLE", "UNREADABLE"] else UiKit.GREEN)

func _exit_tree() -> void:
	_commit_volumes()
