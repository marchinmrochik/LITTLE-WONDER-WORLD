extends Node

var app: Variant
var output := "res://.local/qa/phase1"
var fixture := "user://test-runs/render-" + str(Time.get_ticks_usec())

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	SettingsManager.storage_path = fixture + "/settings.json"
	ProgressManager.storage_path = fixture + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("reduced_motion", true)
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.changed.emit("locale")
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280, 800), Vector2i(1440, 810), Vector2i(1024, 768)]:
		get_window().size = resolution
		for locale: String in ["en", "uk"]:
			SettingsManager.set_value("locale", locale)
			for route: String in ["home", "meadow", "settings"]:
				GameManager.parents_unlocked = true
				GameManager.navigate(route)
				for index: int in range(5):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var path := "%s/%s_%s_%dx%d.png" % [output, route, locale, resolution.x, resolution.y]
				var error := get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
				if error != OK:
					push_error("Screenshot failed: " + path)
					get_tree().quit(1)
					return
	print("RENDER REVIEW: 18 screenshots saved to " + output)
	if "inspect" in OS.get_cmdline_user_args():
		get_window().size = Vector2i(1280, 800)
		SettingsManager.set_value("locale", "en")
		GameManager.return_home()
		for index: int in range(5):
			await get_tree().process_frame
		app.open_parent_gate()
		return
	app.queue_free()
	await get_tree().process_frame
	await AudioManager.shutdown()
	get_tree().quit()
