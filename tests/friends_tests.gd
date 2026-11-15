extends Node
var app: Variant
var checks := 0
var failures: PackedStringArray=[]
func _ready() -> void:call_deferred("run")
func frames() -> void:
	for i: int in range(4):await get_tree().process_frame
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures.append(message);print("FAIL: "+message)
func touch(point: Vector2) -> void:
	var event := InputEventScreenTouch.new();event.position=point;event.index=3;event.pressed=true;get_viewport().push_input(event,true)
	var up := InputEventScreenTouch.new();up.position=point;up.index=3;get_viewport().push_input(up,true)
func run() -> void:
	var folder := "user://test-runs/friends-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=folder+"/settings.json";ProgressManager.storage_path=folder+"/progress.json";ArtworkManager.directory=folder+"/artwork";AssessmentHistory.storage_path=folder+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
	var legacy := SettingsManager.values.duplicate();legacy.erase("companion");legacy.erase("body_character")
	expect(SettingsManager.is_valid_document(legacy),"Old settings remain valid without new selections")
	expect(not SettingsManager.set_value("companion","missing") and not SettingsManager.set_value("body_character","missing"),"Unknown selection IDs are rejected")
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
	for locale: String in ["uk","en"]:
		SettingsManager.set_value("locale",locale);GameManager.return_home();await frames()
		expect(app.current_view.pet_buttons.size()==11,"Home offers fox plus ten other companions")
		for pet: String in CompanionCatalog.IDS:
			app.current_view.pet_buttons[pet].pressed.emit();await frames()
			expect(SettingsManager.values.companion==pet and app.current_view.fox.portrait.texture.resource_path==(FoxieView.STATES[app.current_view.fox.current_state] if pet=="fox" else CompanionCatalog.illustration(pet)),"Home choice changes the actual large companion")
			expect(app.find_child("TravelCompanion",true,false).portrait.texture.resource_path==CompanionCatalog.illustration(pet),"Header companion updates immediately")
			GameManager.start_game("animals");await frames()
			expect(app.find_child("TravelCompanion",true,false).portrait.texture.resource_path==CompanionCatalog.illustration(pet),"Selected companion travels into a game")
			SettingsManager.reload();expect(SettingsManager.values.companion==pet,"Companion survives saved settings reload")
			GameManager.return_home();await frames()
		GameManager.world_topic="body";GameManager.navigate("world_topic");await frames()
		for character: String in ["boy","girl"]:
			var game: Variant=app.current_view;game.focus_paused=false
			game.find_child("Character_"+character,true,false).pressed.emit();await frames()
			expect(SettingsManager.values.body_character==character and game.board.texture.resource_path==BodyCharacterCatalog.definition(character).texture,"Boy/girl button selects the corresponding approved sprite")
			for entry: Dictionary in game.entries:
				game.explore_face=false;game.explore_hand=false;game.show_explore();await frames()
				var point: Vector2=game.board.anchor(entry.id)
				expect(game.board.part_at(point-game.board.global_position)==entry.id,"Every character part has an unambiguous visible anchor: "+character+":"+entry.id)
				touch(point);await frames();expect(game.selected==entry.id,"Actual touch names the selected character part")
			game.show_explore();await frames();SettingsManager.reload();expect(SettingsManager.values.body_character==character,"Body selection persists")
			var pool := WordCatalog.items(locale)
			for word: Dictionary in pool:
				if word.id.begins_with("word:world_body:"):expect(word.illustration==BodyCharacterCatalog.definition(character).texture and word.art_region.size()==4,"Word builder uses the chosen character's part atlas")
		GameManager.start_game("balloons");await frames()
		var balloons: Variant=app.current_view
		balloons.rng.seed=2026;balloons.new_set()
		var right_half := false
		for flight: Dictionary in balloons.flights:
			if flight.x>balloons.area.size.x*.5:right_half=true
		expect(right_half,"Initial balloons use the laid-out field width, not a narrow pre-layout cluster")
		expect(balloons.balloons.size()==12,"Free play contains twelve balloons, twice the old count")
		for flight: Dictionary in balloons.flights:expect(flight.speed>=58.5 and flight.speed<=99.0,"Flight speed is another1.5times the previous39–66range")
		GameManager.return_home();await frames()
	app.queue_free();await frames();await AudioManager.shutdown()
	print("FRIENDS TESTS: %d checks, %d failures" % [checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
