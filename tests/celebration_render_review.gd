extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/celebration"

func _ready() -> void: call_deferred("_run")
func frames() -> void:
	for i: int in range(4): await get_tree().process_frame

func capture(label: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(output+"/"+label+".png"))
	var party := app.current_view.get_node_or_null("CompletionParty") as CompletionCelebration
	if party != null:
		for balloon: PartyBalloon in party.balloons:
			var point := balloon.global_position+balloon.balloon_rect().get_center()
			if not get_viewport().get_visible_rect().has_point(point): issues.append("Off-screen balloon: "+label)
		if not get_viewport().get_visible_rect().grow(1).encloses(party.counter.get_global_rect()): issues.append("Off-screen counter: "+label)
	captures += 1

func _run() -> void:
	get_window().title="Little Wonder World - Celebration QA"
	var fixture := "user://test-runs/party-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json"
	ProgressManager.storage_path=fixture+"/progress.json"
	ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("voice_volume",0.0)
	app=preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size=resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home()
			SettingsManager.set_value("locale",locale)
			await frames()
			GameManager.start_game("animals")
			await frames()
			app.current_view.focus_paused=false
			app.current_view._show_complete()
			await frames()
			var party := app.current_view.get_node("CompletionParty") as CompletionCelebration
			party.elapsed=0.7
			party.get_child(1).queue_redraw()
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			await capture("fireworks_"+suffix)
			SettingsManager.set_value("reduced_motion",true)
			party.get_child(1).queue_redraw()
			await capture("calm_"+suffix)
			SettingsManager.set_value("reduced_motion",false)
			for index: int in range(5): party.pop_balloon(index)
			app.idle_guide.reset()
			app.idle_guide._process(10.1)
			await capture("last_balloon_"+suffix)
			party.pop_balloon(5)
			await capture("result_"+suffix)
	GameManager.return_home()
	await frames()
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("CELEBRATION RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues: print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
