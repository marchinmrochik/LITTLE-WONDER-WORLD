extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/world"
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
	get_window().title="Little Wonder World - World QA"
	var fixture := "user://test-runs/world-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true);SettingsManager.set_value("difficulty","advanced")
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size=resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home();SettingsManager.set_value("locale",locale);await frames()
			AssessmentHistory.storage_path=fixture+"/%s-%dx%d.json" % [locale,resolution.x,resolution.y];AssessmentHistory.reload()
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			GameManager.navigate("activities");await frames();app.current_view.ensure_activity("world");await capture("catalog_"+suffix)
			GameManager.navigate("world");await capture("topics_"+suffix)
			await open_topic("animals");await capture("animals_"+suffix)
			app.current_view.choose("elephant");await capture("animals_selected_"+suffix)
			app.current_view.start_check();await capture("animals_check_"+suffix)
			GameManager.navigate("world");await frames()
			await open_topic("body");await capture("body_"+suffix)
			app.current_view.choose("hand");await capture("hand_"+suffix)
			app.current_view.choose("finger");await capture("finger_"+suffix)
			app.current_view.choose("head");await capture("face_"+suffix)
			app.current_view.start_check();app.current_view.questions.assign(["nose","arm","eye","leg","foot"]);app.current_view.index=0;app.current_view.show_question();await capture("nose_check_"+suffix)
			app.idle_guide.reset();app.idle_guide._process(10.1);await capture("nose_hint_"+suffix)
			app.idle_guide.reset();app.current_view.index=1;app.current_view.show_question();await capture("arm_check_"+suffix)
			GameManager.navigate("world");await frames()
			await open_topic("plants");await capture("plants_"+suffix)
			app.current_view.start_check();await capture("plants_check_"+suffix)
			GameManager.return_home();await frames()
			seed_history(locale,false);seed_history(locale,true)
			GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames()
			var scroll := app.current_view.find_child("SettingsScroll",true,false) as ScrollContainer
			scroll.scroll_vertical=650;await capture("parent_link_"+suffix)
			GameManager.navigate("assessment_history");await capture("history_"+suffix)
	GameManager.return_home();await frames();app.queue_free();await frames();await AudioManager.shutdown()
	print("WORLD RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues:print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
