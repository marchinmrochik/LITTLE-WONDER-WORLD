extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/friends"
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
	get_window().title="Little Wonder World - Friends QA"
	var fixture := "user://test-runs/friends-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true);SettingsManager.set_value("difficulty","advanced")
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size=resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home();SettingsManager.set_value("locale",locale);await frames()
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			await capture("home_"+suffix)
			app.current_view.find_child("PetScroll",true,false).scroll_horizontal=2000;await capture("home_last_pets_"+suffix)
			app.current_view.choose_pet("rabbit");await capture("home_rabbit_"+suffix)
			GameManager.navigate("activities");await capture("travel_"+suffix)
			await open_topic("body")
			for character: String in ["boy","girl"]:
				app.current_view.select_character(character);await capture(character+"_body_"+suffix)
				app.current_view.choose("head");await capture(character+"_face_"+suffix)
				app.current_view.choose("hand");await capture(character+"_hand_"+suffix)
				app.current_view.explore_face=false;app.current_view.explore_hand=false;app.current_view.show_explore();await frames()
				app.current_view.start_check();await capture(character+"_check_"+suffix)
				app.current_view.show_explore();await frames()
			GameManager.start_game("syllables");await frames()
			var hand_words: Array=WordCatalog.items(locale).filter(func(w: Dictionary) -> bool:return w.id=="word:world_body:hand")
			app.current_view.targets=[hand_words[0]];app.current_view.round_index=0;app.current_view.filled=0;app.current_view.prepare_tiles();app.current_view.show_question();await capture("girl_word_hand_"+suffix)
			GameManager.start_game("balloons");await capture("twelve_balloons_"+suffix)
			GameManager.return_home();await frames()
			if resolution==Vector2i(1280,800):
				for pet: String in CompanionCatalog.IDS:
					app.current_view.choose_pet(pet);await capture("pet_"+pet+"_"+suffix)
	GameManager.return_home();await frames();app.queue_free();await frames();await AudioManager.shutdown()
	print("FRIENDS RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues:print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
