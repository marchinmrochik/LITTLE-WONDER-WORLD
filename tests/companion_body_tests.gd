extends Node
var checks := 0
var failures: Array[String]=[]
var captures := 0
func _ready() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(4):await get_tree().process_frame
func normalized(value: String) -> String:return value.strip_edges().trim_suffix(".").to_lower().replace("’","'")
func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://.local/qa/body-030");DirAccess.make_dir_recursive_absolute(folder);get_viewport().get_texture().get_image().save_png(folder+"/"+file+".png");captures+=1
func run() -> void:
	var fixture := "user://test-runs/body030-"+str(Time.get_ticks_usec());SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("sfx_volume",0.0);SettingsManager.set_value("voice_volume",.5)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Voice"),true)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/voice/manifest.json"))
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);GameManager.return_home();await frames()
		for id: String in CompanionCatalog.IDS:
			var home: Variant=app.current_view;home.choose_pet(id);await frames()
			var key := CompanionCatalog.word_key(id);var text: String=home.pet_buttons[id].text
			var matches: Array=manifest.clips.filter(func(c: Dictionary) -> bool:return c.locale==locale and c.key==key)
			expect(home.greeting.text==text,"Large portrait and pet strip show the same word")
			expect(matches.size()==1 and normalized(text)==normalized(matches[0].text),"Displayed pet equals spoken word: "+locale+id)
			expect(AudioManager.voice.stream.resource_path==ContentManager.voice_path(key,locale),"Real selected pet playback uses that same word")
			home.find_child("FoxieButton",true,false).pressed.emit()
			expect(AudioManager.voice.stream.resource_path==ContentManager.voice_path(key,locale),"Large portrait repeats its displayed animal name")
		GameManager.world_topic="body";GameManager.navigate("world_topic");await frames()
		for character: String in ["boy","girl"]:
			var game: Variant=app.current_view;game.focus_paused=false;game.select_character(character);await frames()
			for dimensions: Vector2i in [Vector2i(1280,800),Vector2i(1024,768)]:
				get_window().size=dimensions;await frames()
				for view: String in ["body","face","hand"]:
					game.explore_face=view=="face";game.explore_hand=view=="hand";game.show_explore();await frames()
					var board: WorldBodyBoard=game.board;var layout := board.layout_markers().duplicate()
					expect(board.markers,"Exploration actually displays hit markers")
					expect(layout.size()==board.marker_ids().size(),"Every visible part has a marker")
					for id: String in layout:
						expect(board.part_at(layout[id])==id,"Circle center selects its own part: "+character+view+id)
						for offset: Vector2 in [Vector2(21,0),Vector2(-21,0),Vector2(0,21),Vector2(0,-21)]:
							expect(board.part_at(layout[id]+offset)==id,"Circle edge selects the same part")
						for other: String in layout:
							if other!=id:expect(layout[id].distance_to(layout[other])>=board.MARKER_RADIUS*2+6,"Markers do not overlap")
					if view=="face":
						for landmark: Array in [["nose",Vector2(511,290)],["mouth",Vector2(513,340)],["chin",Vector2(512,391)]]:
							expect(board.part_at(board.from_image(landmark[1]))==landmark[0],"Actual sprite landmark selects correct anatomy: "+str(landmark[0]))
					var chosen: String="belly" if view=="body" else "eye" if view=="face" else "finger"
					var event := InputEventScreenTouch.new();event.index=3;event.pressed=true;event.position=board.global_position+layout[chosen];get_viewport().push_input(event,true);await frames()
					expect(game.selected==chosen and game.board.selected_id==chosen,"Exactly the tapped marker becomes active")
					expect(AudioManager.voice.stream.resource_path==ContentManager.voice_path(WorldCatalog.item("body",chosen).word_key,locale),"Selected body marker speaks the matching word")
					await capture(locale+character+str(dimensions.x)+view)
	GameManager.return_home();await frames();app.queue_free();await frames();await AudioManager.shutdown()
	print("COMPANION/BODY TESTS: %d checks, %d failures, %d captures"%[checks,failures.size(),captures]);get_tree().quit(0 if failures.is_empty() else 1)
