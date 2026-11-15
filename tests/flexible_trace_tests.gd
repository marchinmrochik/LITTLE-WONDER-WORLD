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
func sample(path: Array,distance: float) -> Vector2:
	for i: int in range(path.size()-1):
		var a := Vector2(path[i][0],path[i][1]);var b := Vector2(path[i+1][0],path[i+1][1]);var length := a.distance_to(b)
		if distance<=length:return a.lerp(b,distance/maxf(.001,length))
		distance-=length
	return Vector2(path[-1][0],path[-1][1])
func exercise(path: Array,label: String) -> void:
	if path.size()<2:return
	var length := 0.0
	for i: int in range(path.size()-1):length+=Vector2(path[i][0],path[i][1]).distance_to(Vector2(path[i+1][0],path[i+1][1]))
	for tolerance: float in [12.0,28.0,52.0]:
		var model := GuidedTrace.new();model.configure(path)
		var count := maxi(2,ceili(length/maxf(3,tolerance*.45)))
		expect(model.begin(sample(path,0)+Vector2(1,1),tolerance),"Imprecise start: "+label)
		for i: int in range(1,count+1):
			var point := sample(path,length*i/count)
			if i<count:point+=Vector2(sin(i*.4),cos(i*.6))*minf(5,tolerance*.22)
			model.move(point,tolerance)
			if i%17==0 and not model.complete:
				model.end();expect(model.begin(model.current_point()+Vector2(2,-2),tolerance),"Lift resumes near current ink: "+label)
		model.move(sample(path,length),tolerance)
		expect(model.complete,"Rounded corners and jitter finish: "+label+" tol "+str(tolerance))
func run() -> void:
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/symbol_tracing.json"))
	for locale: String in ["en","uk"]:
		for entry: Dictionary in data.letters[locale]:
			for path: Array in entry.strokes:exercise(path,locale+entry.glyph)
	for entry: Dictionary in data.digits:
		for path: Array in entry.strokes:exercise(path,"digit "+entry.glyph)
	for season: String in ["house","spring","autumn","winter"]:
		var story: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/living_"+season+".json"))
		for part: Dictionary in story.parts:
			for path: Array in part.strokes:exercise(path,season+part.id)
	var model := GuidedTrace.new();model.configure([[0,0],[100,0],[100,100],[0,100],[0,0]]);model.begin(Vector2.ZERO,15)
	for i: int in range(50):model.move(Vector2.ZERO,15)
	expect(model.edge==0 and model.fraction==0,"Stationary touch cannot fill a loop")
	model.move(Vector2(100,100),15);expect(not model.complete,"Corner shortcuts cannot complete a rectangle")
	model.configure([[0,0],[0,0],[100,0]]);model.begin(Vector2.ZERO,15);model.move(Vector2(100,0),15);expect(model.complete,"Duplicate vertices cannot divide by zero")
	var fixture := "user://test-runs/flexible-"+str(Time.get_ticks_usec());SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";BalloonRecords.storage_path=fixture+"/balloons.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale)
		for dimensions: Vector2i in [Vector2i(1280,800),Vector2i(1024,768)]:
			get_window().size=dimensions;GameManager.start_game("balloons");await frames()
			var game: Variant=app.current_view;game.focus_paused=false;game.set_process(false);game.start_mode(false);await frames()
			expect(game.area.size.y>=game.size.y*.7,"Balloon flight occupies at least 70 percent of game content")
			for f: Dictionary in game.flights:expect(f.y/f.speed>2.0,"Initial balloons have time to fly")
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				var folder := ProjectSettings.globalize_path("res://.local/qa/flexible-trace");DirAccess.make_dir_recursive_absolute(folder)
				get_viewport().get_texture().get_image().save_png(folder+"/"+locale+str(dimensions.x)+"_balloons.png");captures+=1
			game.start_mode(true);expect(game.counter.text.length()<22,"Timed counter is compact")
	app.queue_free();await frames();await AudioManager.shutdown()
	print("FLEXIBLE TRACE TESTS: %d checks, %d failures, %d captures"%[checks,failures.size(),captures]);get_tree().quit(0 if failures.is_empty() else 1)
