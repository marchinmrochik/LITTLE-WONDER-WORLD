extends Node

var app: Variant
var output := "res://.local/qa/counting"
var screenshots := 0
var issues: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Counting QA"
	var fixture := "user://test-runs/counting-render-" + str(Time.get_ticks_usec())
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
			await _frames()
			app.current_view.set_page(1)
			await _capture("activities2", locale, resolution)
			GameManager.start_game("counting")
			await _frames()
			var game: Variant = app.current_view
			for difficulty: String in ["easy", "normal", "advanced"]:
				_prepare(game, difficulty, "choice", 5 if difficulty == "easy" else 10)
				await _capture("choice_" + difficulty, locale, resolution)
			_prepare(game, "easy", "basket", 3)
			await _capture("basket_easy", locale, resolution)
			_prepare(game, "advanced", "basket", 10)
			await _capture("basket_advanced", locale, resolution)
			game.focus_paused = false
			game.begin_drag(0, -1, game.source_cards[0].get_global_rect().get_center())
			game.drag.move(game.drop_zone.get_global_rect().get_center())
			await _capture("basket_drag", locale, resolution)
			game.drag.release(game.drop_zone.get_global_rect().get_center())
			for instance: int in range(1, 10):
				game.model.add_object(instance)
			game._update_basket()
			await _capture("basket_ten", locale, resolution)
			game.remove_object(9)
			game.check_basket()
			game.feedback_timer.stop()
			await _capture("basket_retry", locale, resolution)
			game._finish_feedback()
			game.model.add_object(9)
			game.check_basket()
			game.feedback_timer.stop()
			game._finish_feedback()
			for task: int in range(4):
				game.focus_paused = false
				for instance: int in range(game.model.target):
					game.model.add_object(instance)
				game.check_basket()
				game.feedback_timer.stop()
				game._finish_feedback()
			await _capture("complete", locale, resolution)
	print("COUNTING RENDER: %d screenshots; %d layout issues" % [screenshots, issues.size()])
	for issue: String in issues:
		print("LAYOUT: " + issue)
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	get_tree().quit(0 if issues.is_empty() else 1)

func _prepare(game: Variant, difficulty: String, mode: String, target: int) -> void:
	for seed_value: int in range(1, 101):
		game.model.begin(difficulty, mode, seed_value)
		if game.model.target == target:
			break
	if game.model.target != target:
		issues.append("Boundary fixture target not found")
	game._show_question()

func _capture(label: String, locale: String, resolution: Vector2i) -> void:
	await _frames()
	await RenderingServer.frame_post_draw
	var filename := "%s/%s_%s_%dx%d.png" % [output, label, locale, resolution.x, resolution.y]
	if get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(filename)) != OK:
		issues.append("Screenshot failed: " + filename)
	_check_controls(app, label + ":" + locale + ":" + str(resolution))
	screenshots += 1

func _check_controls(node: Node, context: String) -> void:
	if node is Label and node.is_visible_in_tree():
		var ancestor := node.get_parent()
		while ancestor != null and ancestor != app:
			if ancestor is BaseButton or ancestor is DragCard:
				if not ancestor.get_global_rect().grow(1).encloses(node.get_global_rect()):
					issues.append(context + ": label outside card: " + str(ancestor.name))
				break
			ancestor = ancestor.get_parent()
	if (node is BaseButton or node is DragCard or node.name == "CountingBasket") and node.is_visible_in_tree():
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(context + ": control outside viewport: " + str(node.name))
	for child: Node in node.get_children():
		_check_controls(child, context)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame
