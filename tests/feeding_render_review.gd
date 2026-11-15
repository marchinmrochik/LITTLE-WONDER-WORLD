extends Node

var app: Variant
var output := "res://.local/qa/feeding"
var screenshots := 0
var issues: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Feeding QA"
	var fixture := "user://test-runs/feeding-render-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("voice_volume", 0.0)
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280, 800), Vector2i(1440, 810), Vector2i(1024, 768)]:
		get_window().size = resolution
		for locale: String in ["en", "uk"]:
			SettingsManager.set_value("locale", locale)
			GameManager.navigate("activities")
			await _capture("activities", locale, resolution)
			GameManager.start_game("feeding")
			await _frames()
			var game: Variant = app.current_view
			for difficulty: String in ["easy", "normal", "advanced"]:
				game.model.begin(difficulty, 42)
				game._show_question()
				await _capture("request_" + difficulty, locale, resolution)
			game.focus_paused = false
			var card := game.body.find_child("Food_" + game.model.target, true, false) as Control
			game.begin_drag(game.model.target, -1, card.get_global_rect().get_center())
			game.move_drag(game.drop_zone.get_global_rect().get_center())
			await _capture("drag_highlight", locale, resolution)
			game.cancel_drag()
			var wrong: String = game.model.options.filter(func(id: String) -> bool: return id != game.model.target)[0]
			game._offer(wrong)
			game.feedback_timer.stop()
			await _capture("retry", locale, resolution)
			game._finish_feedback()
			game._offer(game.model.target)
			game.feedback_timer.stop()
			await _capture("eating", locale, resolution)
			game._finish_feedback()
			for index: int in range(4):
				game.focus_paused = false
				game._offer(game.model.target)
				game.feedback_timer.stop()
				game._finish_feedback()
			await _capture("complete", locale, resolution)
	print("FEEDING RENDER: %d screenshots; %d layout issues" % [screenshots, issues.size()])
	for issue: String in issues:
		print("LAYOUT: " + issue)
	if "inspect" in OS.get_cmdline_user_args():
		get_window().size = Vector2i(1280, 800)
		SettingsManager.set_value("locale", "en")
		SettingsManager.set_value("difficulty", "easy")
		SettingsManager.set_value("voice_volume", 0.8)
		await _frames()
		app.current_view.start_session()
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
	if node is Label and node.is_visible_in_tree():
		var ancestor := node.get_parent()
		while ancestor != null and ancestor != app:
			if ancestor is BaseButton or ancestor is FoodCard:
				if not ancestor.get_global_rect().grow(1).encloses(node.get_global_rect()):
					issues.append(context + ": label outside card: " + str(ancestor.name))
				break
			ancestor = ancestor.get_parent()
	if (node is BaseButton or node is FoodCard or node.name == "FeedingTarget") and node.is_visible_in_tree():
		var rect: Rect2 = node.get_global_rect()
		if not get_viewport().get_visible_rect().grow(1).encloses(rect):
			issues.append(context + ": control outside viewport: " + str(node.name) + " " + str(rect))
	for child: Node in node.get_children():
		_check_controls(child, context)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame
