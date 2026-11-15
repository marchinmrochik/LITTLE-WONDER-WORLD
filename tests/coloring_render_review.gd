extends Node

var app: Variant
var output := "res://.local/qa/coloring"
var screenshots := 0
var issues: PackedStringArray = []
var fixture := ""

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	get_window().title = "Little Wonder World - Coloring QA"
	fixture = "user://test-runs/coloring-render-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("voice_volume", 0.0)
	ArtworkManager.directory = fixture + "/initial"
	ArtworkManager.reload()
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size = resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home()
			await _frames()
			ArtworkManager.directory = fixture + "/%s-%dx%d" % [locale,resolution.x,resolution.y]
			ArtworkManager.reload()
			SettingsManager.set_value("locale",locale)
			GameManager.navigate("activities")
			await _frames()
			app.current_view.set_page(2)
			await _capture("activities3",locale,resolution)
			GameManager.start_game("coloring")
			await _frames()
			var game: Variant = app.current_view
			game.focus_paused = false
			game._update_pause()
			var sheet := Image.create(1600,800,false,Image.FORMAT_RGBA8)
			sheet.fill(Color.WHITE)
			for index: int in range(10):
				game.page_index = index
				game._show_page()
				await _capture("plain_" + game.document().page.id,locale,resolution)
				var sample: Vector2 = game.document().page.regions[0].tap
				var rect: Rect2 = game.canvas.image_rect()
				var point: Vector2 = game.canvas.global_position + rect.position + sample / Vector2(1024,640) * rect.size
				var down := InputEventMouseButton.new()
				down.button_index = MOUSE_BUTTON_LEFT
				down.pressed = true
				down.position = point
				get_viewport().push_input(down,true)
				var up := InputEventMouseButton.new()
				up.button_index = MOUSE_BUTTON_LEFT
				up.position = point
				get_viewport().push_input(up,true)
				if game.document().colors[game.document().page.regions[0].id] == "ffffff":
					issues.append("Scaled mouse did not fill " + game.document().page.id)
				for region_index: int in range(game.document().page.regions.size()):
					var region: Dictionary = game.document().page.regions[region_index]
					game.document().fill_at(region.tap,PaintDocument.COLORS[(region_index + index) % 9])
				game._changed()
				await _capture("colored_" + game.document().page.id,locale,resolution)
				if resolution == Vector2i(1280,800) and locale == "en":
					var thumbnail: Image = game.canvas.image.duplicate()
					thumbnail.resize(320,200)
					sheet.blit_rect(thumbnail,Rect2i(0,0,320,200),Vector2i(index % 5,index / 5) * Vector2i(320,400))
					var plain := ColoringDocument.new(game.document().page.id).render_image()
					plain.resize(320,200)
					sheet.blit_rect(plain,Rect2i(0,0,320,200),Vector2i(index % 5,index / 5) * Vector2i(320,400) + Vector2i(0,200))
			if resolution == Vector2i(1280,800) and locale == "en":
				sheet.save_png(ProjectSettings.globalize_path(output + "/all_pages.png"))
			game.save_picture()
			game.show_gallery()
			await _capture("gallery",locale,resolution)
			game.close_gallery()
			game.request_reset()
			await _capture("reset_confirmation",locale,resolution)
			app.close_modal()
	print("COLORING RENDER: %d screenshots; %d layout issues" % [screenshots,issues.size()])
	for issue: String in issues:
		print("LAYOUT: " + issue)
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	get_tree().quit(0 if issues.is_empty() else 1)

func _capture(label: String,locale: String,resolution: Vector2i) -> void:
	await _frames()
	await RenderingServer.frame_post_draw
	var filename := "%s/%s_%s_%dx%d.png" % [output,label,locale,resolution.x,resolution.y]
	if get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(filename)) != OK:
		issues.append("Screenshot failed: " + filename)
	_check(app,label+":"+locale+":"+str(resolution))
	screenshots += 1

func _check(node: Node,context: String) -> void:
	if node is BaseButton and node.is_visible_in_tree():
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(context+": button outside viewport: "+str(node.name))
	for child: Node in node.get_children():
		_check(child,context)

func _frames() -> void:
	for i: int in range(5):
		await get_tree().process_frame
