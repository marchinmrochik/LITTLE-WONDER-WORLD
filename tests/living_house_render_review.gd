extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/living-yard"
func _ready() -> void:call_deferred("_run")
func frames() -> void:
	for i: int in range(5):await get_tree().process_frame
func capture(label: String) -> void:
	await frames();await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(output+"/"+label+".png"))!=OK:issues.append("Capture failed: "+label)
	check(app,label,false);captures+=1
func check(node: Node,label: String,scrolling: bool) -> void:
	if node is ScrollContainer:scrolling=true
	if node is BaseButton and node.is_visible_in_tree() and not scrolling:
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):issues.append(label+":"+str(node.name))
	for child: Node in node.get_children():check(child,label,scrolling)
func seed_history(locale: String,perfect: bool) -> void:
	var items: Array[String]=["eye","nose","arm","leg","foot"]
	var id: String=AssessmentHistory.begin_check("body",1,locale,"advanced",items)
	for i: int in range(5):AssessmentHistory.record(id,items[i],true,not perfect and i<2,1,true)
	AssessmentHistory.finish(id,true)
func open_topic(id: String) -> void:
	GameManager.world_topic=id;GameManager.navigate("world_topic");await frames()
	app.current_view.focus_paused=false
func _run() -> void:
	get_window().title="Little Wonder World - Living House QA"
	var fixture := "user://test-runs/living-house-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true);SettingsManager.set_value("difficulty","advanced")
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size=resolution
		for locale: String in ["en","uk"]:
			SettingsManager.set_value("locale",locale);GameManager.return_home();await frames()
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			GameManager.navigate("activities");await frames();app.current_view.ensure_activity("living_drawing");await capture("menu_"+suffix)
			GameManager.navigate("living_gallery");await capture("gallery_"+suffix)
			GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false;game.restart()
			for i: int in range(10):
				await capture("part_%d_ready_" % i+suffix)
				game.zoom_part();await get_tree().create_timer(.14).timeout;await capture("part_%d_zoom_" % i+suffix)
				var strokes: int=game.part().strokes.size()
				for line: int in range(strokes):
					var path: PackedVector2Array=game.trace.points.duplicate();game.trace.begin(path[0],game.board.tolerance())
					if i==3 and line==0:game.trace.move(path[0].lerp(path[1],.6),game.board.tolerance());await capture("window_partial_"+suffix)
					for point: int in range(1,path.size()):game.trace.move(path[point],game.board.tolerance())
					game.finish_stroke()
				await get_tree().create_timer(.27).timeout;await frames()
			await capture("house_play_"+suffix)
			for id: String in ["door","left_window","chimney","roof","sun","dog","cloud","flowers"]:
				game.board.effects.clear();game.board.play_object(id);await get_tree().create_timer(.55).timeout;await capture("play_"+id+"_"+suffix)
			GameManager.return_home();await frames()
	GameManager.return_home();await frames();app.queue_free();await frames();await AudioManager.shutdown()
	print("LIVING HOUSE RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues:print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
