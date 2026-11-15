extends Node

var checks := 0
var failures: PackedStringArray = []
var app: Variant
const ENTRIES := ["AnimalsButton","ColorsButton","FeedingButton","ShapesButton","PuzzlesButton","MemoryButton","CountingButton","DrawingButton","ColoringButton","XylophoneButton"]
const ROUTES := ["animals","colors","feeding","shapes","puzzles","memory","counting","drawing","coloring","xylophone"]

func _ready() -> void:
	get_tree().create_timer(100).timeout.connect(func() -> void: get_tree().quit(1))
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		print("FAIL: "+message)

func frames() -> void:
	for index: int in range(3):
		await get_tree().process_frame

func cancel_button() -> Button:
	for node: Node in app.modal.find_children("*","Button",true,false):
		if node.text == LocalizationManager.text("CANCEL"):
			return node
	return null

func _run() -> void:
	var fixture := "user://test-runs/release-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture+"/settings.json"
	ProgressManager.storage_path = fixture+"/progress.json"
	ArtworkManager.directory = fixture+"/artwork"
	SettingsManager.reload()
	ProgressManager.reload()
	ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("reduced_motion",true)
	SettingsManager.set_value("system_voice_enabled",false)
	expect(ContentManager.validate().is_empty(),"Foundation resource validation")
	for key: String in ContentManager.manifest.voice:
		for locale: String in ["en","uk"]:
			expect(LocalizationManager.messages[locale].has(key),"Speech text exists: "+key+":"+locale)
			expect(AudioManager.local_voice_available(key,locale),"Local speech exists: "+key+":"+locale)
	expect(GameManager.games.size()==14,"Fourteen registered working games")
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await frames()
	var baseline_nodes := 0
	for locale: String in ["en","uk"]:
		for difficulty: String in ["easy","normal","advanced"]:
			GameManager.return_home()
			SettingsManager.set_value("locale",locale)
			SettingsManager.set_value("difficulty",difficulty)
			await frames()
			for index: int in range(10):
				GameManager.navigate("activities")
				await frames()
				app.current_view.set_page(index/4)
				await frames()
				var button := app.current_view.find_child(ENTRIES[index],true,false) as Button
				expect(button != null,"Reachable menu entry: "+ROUTES[index])
				button.pressed.emit()
				await frames()
				var game: Variant = app.current_view
				expect(GameManager.current_route==ROUTES[index],"Correct actual route "+ROUTES[index])
				if game.has_method("_notification"):
					game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
				app.open_parent_gate()
				await frames()
				expect(is_instance_valid(app.modal) and not GameManager.parents_unlocked,"Barrier stays locked")
				if game.has_method("set_overlay_paused"):
					expect(game.overlay_paused,"Game pauses under parent barrier")
				var cancel := cancel_button()
				expect(cancel != null,"Visible parent Cancel exists")
				cancel.pressed.emit()
				await frames()
				expect(not is_instance_valid(app.modal),"Cancel removes parent barrier")
				if game.has_method("set_overlay_paused"):
					expect(not game.overlay_paused,"Cancel resumes game: "+ROUTES[index]+":"+locale+":"+difficulty)
				GameManager.return_home()
				await frames()
				expect(not AudioManager.instrument_active,"No leftover instrument mute after navigation")
				expect(not GameManager.parents_unlocked and not GameManager.navigate("gallery"),"Child cannot directly enter adult gallery")
			var node_count := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
			if baseline_nodes == 0:
				baseline_nodes = node_count
			expect(node_count <= baseline_nodes+2,"Repeated navigation does not retain scene nodes")
	# Parent volume changes must flush even when leaving before debounce fires.
	app.open_parent_gate()
	await frames()
	app.modal.choose(app.modal.answer)
	await frames()
	expect(GameManager.current_route=="settings","Correct barrier answer opens settings")
	var slider := app.current_view.find_child("sfx_volume",true,false) as HSlider
	slider.value = 23
	GameManager.return_home()
	await frames()
	SettingsManager.reload()
	expect(is_equal_approx(float(SettingsManager.values.sfx_volume),0.23),"Immediate departure flushes pending volume to disk")
	expect(ProgressManager.document.games.is_empty(),"Navigation alone fabricates no learning progress")
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("RELEASE TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
