extends Node
var checks := 0
var failures: Array[String]=[]
var captures := 0
func _ready() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(5):await get_tree().process_frame
func run() -> void:
	var assets := {}
	var registry: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/design_visual_overrides.json")).overrides
	for id: String in registry:
		if id.get_slice("/",2) in ["walls","roof","chimney","window","door"]:continue
		assets[registry[id].texture]=true
		for path: String in registry[id].get("variants",{}).values():assets[path]=true
	var animals: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/animals.json"))
	for animal: Dictionary in animals.animals:
		assets[animal.illustration]=true
		expect(not "M67 161c-8-67" in FileAccess.get_file_as_string(animal.illustration),"No decorative background plate: "+animal.id)
	for path: String in assets:
		var texture: Texture2D=load(path);var image := texture.get_image();var transparent := 0;var total := 0
		for y: int in range(0,image.get_height(),8):
			for x: int in range(0,image.get_width(),8):
				total+=1
				if image.get_pixel(x,y).a<.05:transparent+=1
		expect(transparent>total*.05,"Story character/object has transparent surroundings: "+path)
	var fixture := "user://test-runs/difficulty-art-"+str(Time.get_ticks_usec());SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);GameManager.navigate("activities");await frames()
		for level: String in ["easy","normal","advanced"]:
			var strip: DifficultyStrip=app.current_view.find_child("DifficultyStrip",true,false)
			strip.buttons[level].pressed.emit();await frames()
			expect(SettingsManager.values.difficulty==level,"Actual choice persists: "+level)
			for id: String in strip.buttons:
				var button: ChildButton=strip.buttons[id]
				expect(button.button_pressed==(id==level),"Exactly selected button remains pressed")
				for state: String in ["normal","hover","pressed"]:
					var style: StyleBoxFlat=button.get_theme_stylebox(state)
					expect(style.border_width_left==(3 if id==level else 0),"Selection visible even while hovered/pressed")
			strip.buttons[level].pressed.emit();await frames();expect(strip.buttons[level].button_pressed,"Repeated tap cannot deselect the level")
			SettingsManager.reload();GameManager.start_game("animals");await frames();GameManager.navigate("activities");await frames()
			expect(app.current_view.find_child("DifficultyStrip",true,false).buttons[level].button_pressed,"Returning from a game keeps the selection")
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			var output := ProjectSettings.globalize_path("res://.local/qa/difficulty-art");DirAccess.make_dir_recursive_absolute(output);get_viewport().get_texture().get_image().save_png(output+"/"+locale+"_selection.png");captures+=1
		for story: String in ["house","spring"]:
			GameManager.living_story=story;GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false
			for i: int in range(game.parts.size()):game.completed[i]=true
			game.state=game.State.PLAY;game.update_labels()
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				var folder := ProjectSettings.globalize_path("res://.local/qa/difficulty-art");DirAccess.make_dir_recursive_absolute(folder);get_viewport().get_texture().get_image().save_png(folder+"/"+locale+"_"+story+".png");captures+=1
	app.queue_free();await frames();await AudioManager.shutdown()
	print("DIFFICULTY/ART TESTS: %d checks, %d failures, %d captures; %d transparent assets"%[checks,failures.size(),captures,assets.size()]);get_tree().quit(0 if failures.is_empty() else 1)
