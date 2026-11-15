extends Node

var app: Variant
var output := "res://.local/qa/animals"
var screenshots := 0
var issues: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Animals QA"
	var fixture := "user://test-runs/animals-render-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("voice_volume", 0.0)
	SettingsManager.changed.emit("locale")
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280, 800), Vector2i(1440, 810), Vector2i(1024, 768)]:
		get_window().size = resolution
		for locale: String in ["en", "uk"]:
			SettingsManager.set_value("locale", locale)
			GameManager.navigate("activities")
			await _capture("activities", locale, resolution)
			GameManager.start_game("animals")
			await _frames()
			var game: Variant = app.current_view
			for page: int in range(3):
				game.page = page
				game.show_explore()
				await _capture("explore" + str(page + 1), locale, resolution)
			for difficulty: String in ["easy", "normal", "advanced"]:
				SettingsManager.set_value("difficulty", difficulty)
				game.model.begin(difficulty, 42)
				game._show_question()
				await _capture("find_" + difficulty, locale, resolution)
			for index: int in range(5):
				game.focus_paused = false
				game.choose(game.model.target)
				game.feedback_timer.stop()
				game._finish_feedback()
			await _capture("complete", locale, resolution)
	print("ANIMALS RENDER: %d screenshots; %d layout issues" % [screenshots, issues.size()])
	for issue: String in issues:
		print("LAYOUT: " + issue)
	if "inspect" in OS.get_cmdline_user_args():
		get_window().size = Vector2i(1280, 800)
		SettingsManager.set_value("locale", "en")
		SettingsManager.set_value("difficulty", "easy")
		SettingsManager.set_value("voice_volume", 0.8)
		await _frames()
		app.current_view.page = 0
		app.current_view.show_explore()
		return
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	get_tree().quit(0 if issues.is_empty() else 1)

func _capture(label: String, locale: String, resolution: Vector2i) -> void:
	await _frames()
	await RenderingServer.frame_post_draw
	var filename := "%s/%s_%s_%dx%d.png" % [output, label, locale, resolution.x, resolution.y]
	var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(filename))
	if error != OK:
		issues.append("Screenshot failed: " + filename)
	_check_controls(app, label + ":" + locale + ":" + str(resolution))
	screenshots += 1

func _check_controls(node: Node, context: String) -> void:
	if node is BaseButton and node.is_visible_in_tree():
		var rect: Rect2 = node.get_global_rect()
		var available := get_viewport().get_visible_rect().grow(1)
		if not available.encloses(rect):
			issues.append(context + ": button outside viewport: " + str(node.name) + " " + str(rect))
	for child: Node in node.get_children():
		_check_controls(child, context)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame
