extends Node

var app: Variant
var output := "res://.local/qa/drawing"
var screenshots := 0
var issues: PackedStringArray = []
var fixture := ""

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Drawing QA"
	fixture = "user://test-runs/drawing-render-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("voice_volume", 0.0)
	ArtworkManager.directory = fixture + "/initial"
	ArtworkManager.reload()
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280, 800), Vector2i(1440, 810), Vector2i(1024, 768)]:
		get_window().size = resolution
		for locale: String in ["en", "uk"]:
			GameManager.return_home()
			await _frames()
			ArtworkManager.directory = fixture + "/%s-%dx%d" % [locale, resolution.x, resolution.y]
			ArtworkManager.reload()
			SettingsManager.set_value("locale", locale)
			GameManager.navigate("activities")
			await _frames()
			app.current_view.set_page(1)
			await _capture("activities2", locale, resolution)
			GameManager.start_game("drawing")
			await _frames()
			var game: Variant = app.current_view
			game.focus_paused = false
			game._update_pause()
			await _capture("blank", locale, resolution)
			# Verify real scaled mouse coordinates at every rendered ratio.
			var rect: Rect2 = game.canvas.image_rect()
			var origin: Vector2 = game.canvas.global_position + rect.position
			var start := origin + Vector2(100, 120) / Vector2(PaintDocument.SIZE) * rect.size
			var end := origin + Vector2(900, 120) / Vector2(PaintDocument.SIZE) * rect.size
			var down := InputEventMouseButton.new()
			down.button_index = MOUSE_BUTTON_LEFT
			down.button_mask = MOUSE_BUTTON_MASK_LEFT
			down.position = start
			down.pressed = true
			get_viewport().push_input(down, true)
			var motion := InputEventMouseMotion.new()
			motion.position = end
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			get_viewport().push_input(motion, true)
			var up := InputEventMouseButton.new()
			up.button_index = MOUSE_BUTTON_LEFT
			up.position = end
			get_viewport().push_input(up, true)
			if game.canvas.document.image.get_pixel(500, 120) == Color.WHITE:
				issues.append("Scaled mouse input missed the document")
			for tool: String in ["soft", "rainbow", "regular"]:
				game.select_tool(tool)
				game.select_size(20)
				game.select_color(4)
				var y := 240 if tool == "soft" else 360 if tool == "rainbow" else 490
				game.canvas.document.begin(Vector2(80, y))
				game.canvas.document.move(Vector2(900, y))
				game.canvas.document.finish()
			game.select_tool("eraser")
			game.canvas.document.begin(Vector2(500, 490))
			game.canvas.document.finish()
			game.canvas.refresh()
			game._changed()
			await _capture("painted", locale, resolution)
			game.save_picture()
			game.show_gallery()
			await _capture("child_gallery", locale, resolution)
			game.close_gallery()
			game.request_clear()
			await _capture("clear_confirmation", locale, resolution)
			app.close_modal()
			GameManager.parents_unlocked = true
			GameManager.navigate("gallery")
			await _frames()
			await _capture("parent_gallery", locale, resolution)
			app.current_view.gallery.delete_requested.emit(ArtworkManager.entries[0].id)
			await _capture("delete_confirmation", locale, resolution)
			app.close_modal()
	print("DRAWING RENDER: %d screenshots; %d layout issues" % [screenshots, issues.size()])
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
	_check(app, label + ":" + locale + ":" + str(resolution))
	screenshots += 1

func _check(node: Node, context: String) -> void:
	if node is BaseButton and node.is_visible_in_tree():
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(context + ": button outside viewport: " + str(node.name))
	for child: Node in node.get_children():
		_check(child, context)

func _frames() -> void:
	for i: int in range(5):
		await get_tree().process_frame
