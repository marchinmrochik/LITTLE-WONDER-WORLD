extends Node

var app: Variant
var count := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/xylophone"

func _ready() -> void:
	call_deferred("_run")

func frames() -> void:
	for index: int in range(5):
		await get_tree().process_frame

func capture(label: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path(output+"/"+label+".png")
	if get_viewport().get_texture().get_image().save_png(path) != OK:
		issues.append("Capture failed: "+label)
	check_bounds(app,label)
	count += 1

func check_bounds(node: Node, label: String) -> void:
	if node is Control and node.is_visible_in_tree() and (node is BaseButton or node is Label or node is XylophoneKeyboard):
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):
			issues.append(label+": outside viewport: "+str(node.name))
	for child: Node in node.get_children():
		check_bounds(child,label)

func _run() -> void:
	get_window().title = "Little Wonder World - Xylophone QA"
	var fixture := "user://test-runs/xylo-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture+"/settings.json"
	ProgressManager.storage_path = fixture+"/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("reduced_motion",true)
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size = resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home()
			SettingsManager.set_value("locale",locale)
			await frames()
			GameManager.navigate("activities")
			await frames()
			app.current_view.set_page(2)
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			await capture("menu_"+suffix)
			GameManager.start_game("xylophone")
			await frames()
			var game: Variant = app.current_view
			game.focus_paused = false
			game._update_pause()
			await capture("free_"+suffix)
			for index: int in range(8):
				var event := InputEventScreenTouch.new()
				event.index = index
				event.position = game.keyboard.global_position+game.keyboard.key_rect(index).get_center()
				event.pressed = true
				get_viewport().push_input(event,true)
			if game.strikes != 8:
				issues.append("Scaled eight-key input failed: "+suffix)
			await capture("chord_"+suffix)
			app.open_parent_gate()
			await capture("parent_gate_"+suffix)
			app.close_modal()
	GameManager.return_home()
	await frames()
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("XYLOPHONE RENDER: %d screenshots, %d issues" % [count,issues.size()])
	for issue: String in issues:
		print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
