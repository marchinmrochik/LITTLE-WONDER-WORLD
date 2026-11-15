extends Node

var app: Variant
var output := "res://.local/qa/memory"
var screenshots := 0
var issues: PackedStringArray = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Memory QA"
	var fixture := "user://test-runs/memory-render-" + str(Time.get_ticks_usec())
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
			for page: int in range(2):
				app.current_view.set_page(page)
				await _capture("activities" + str(page + 1), locale, resolution)
			GameManager.start_game("memory")
			await _frames()
			var game: Variant = app.current_view
			for difficulty: String in ["easy", "normal", "advanced"]:
				SettingsManager.set_value("difficulty", difficulty)
				game.start_session()
				await _capture("board_" + difficulty, locale, resolution)
			game.focus_paused = false
			game.choose(0)
			await _capture("first", locale, resolution)
			var wrong := 1
			while game.model.deck[wrong] == game.model.deck[0]:
				wrong += 1
			game.choose(wrong)
			game.feedback_timer.stop()
			await _capture("mismatch", locale, resolution)
			game._resolve_pair()
			var partner: int = game.model.deck.rfind(game.model.deck[0])
			game.choose(0)
			game.choose(partner)
			game.feedback_timer.stop()
			game._resolve_pair()
			await _capture("matched", locale, resolution)
			for step: int in range(4):
				if game.state == game.State.COMPLETE:
					break
				game.focus_paused = false
				var first := 0
				while first in game.model.matched:
					first += 1
				var second: int = game.model.deck.rfind(game.model.deck[first])
				game.choose(first)
				game.choose(second)
				game.feedback_timer.stop()
				game._resolve_pair()
			await _capture("complete", locale, resolution)
	print("MEMORY RENDER: %d screenshots; %d layout issues" % [screenshots, issues.size()])
	for issue: String in issues:
		print("LAYOUT: " + issue)
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	get_tree().quit(0 if issues.is_empty() else 1)

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
			if ancestor is BaseButton:
				if not ancestor.get_global_rect().grow(1).encloses(node.get_global_rect()):
					issues.append(context + ": label outside card: " + str(ancestor.name))
				break
			ancestor = ancestor.get_parent()
	if node is BaseButton and node.is_visible_in_tree():
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(context + ": control outside viewport: " + str(node.name))
	for child: Node in node.get_children():
		_check_controls(child, context)

func _frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame
