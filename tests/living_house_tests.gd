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
func touch(point: Vector2,pressed: bool,index: int=9) -> void:
	var e := InputEventScreenTouch.new();e.index=index;e.position=point;e.pressed=pressed;get_viewport().push_input(e,true)
func drag(point: Vector2,index: int=9) -> void:
	var e := InputEventScreenDrag.new();e.index=index;e.position=point;get_viewport().push_input(e,true)
func global_point(game: Variant,point: Vector2) -> Vector2:return game.board.global_position+game.board.from_world(point)
func trace_line(game: Variant) -> void:
	var path: PackedVector2Array=game.trace.points.duplicate();var edge: int=game.trace.edge
	touch(global_point(game,game.trace.current_point()),true)
	for i: int in range(edge+1,path.size()):drag(global_point(game,path[i]))
	touch(global_point(game,path[-1]),false)
func run() -> void:
	var model := GuidedTrace.new();model.configure([[0,0],[100,0],[100,100],[0,100],[0,0]])
	expect(not model.begin(Vector2(80,80),12),"Tracing cannot start away from the next point")
	expect(model.begin(Vector2.ZERO,12),"Tracing starts near the current point")
	model.move(Vector2(100,100),12);expect(not model.complete,"Diagonal shortcut cannot complete a rectangular contour")
	model.end();var previous: int=model.edge;model.move(Vector2(0,100),12);expect(model.edge==previous,"Released trace cannot progress")
	model.configure([[0,0],[100,0]]);model.begin(Vector2.ZERO,12);model.move(Vector2(100,0),12);expect(model.complete,"A fast straight drag completes the actual line")
	model.configure([[0,0],[100,0]]);model.begin(Vector2.ZERO,12);model.move(Vector2(0,80),12);model.move(Vector2(100,0),12)
	expect(not model.complete,"Leaving the path and jumping to its end cannot skip the missing line")
	model.end();expect(model.begin(model.current_point(),12),"A lifted finger can resume at the accepted green point");model.move(Vector2(100,0),12);expect(model.complete,"Resumed drawing can finish normally")
	var folder := "user://test-runs/living-house-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=folder+"/settings.json";ProgressManager.storage_path=folder+"/progress.json";ArtworkManager.directory=folder+"/artwork";AssessmentHistory.storage_path=folder+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);await frames()
		for level: String in ["easy","normal","advanced"]:
			SettingsManager.set_value("difficulty",level);GameManager.return_home();await frames();GameManager.navigate("activities");await frames();app.current_view.ensure_activity("living_drawing");await frames()
			app.current_view.find_child("LivingDrawingButton",true,false).pressed.emit();await frames()
			expect(GameManager.current_route=="living_gallery","Activity opens the story gallery")
			app.current_view.find_child("HouseStory",true,false).pressed.emit();await frames()
			var game: Variant=app.current_view;game.focus_paused=false
			expect(GameManager.current_route=="living_drawing" and game.parts.size()==10,"Gallery opens one ten-element yard")
			for i: int in range(10):
				expect(game.state==game.State.READY and game.part_index==i,"The scene offers the next undrawn element")
				expect(game.available_parts().size()==(1 if i<6 else 10-i),"House is guided; yard offers every remaining dot")
				var pair: Array=game.part().marker;var at := global_point(game,Vector2(pair[0],pair[1]));touch(at,true);touch(at,false)
				expect(game.state==game.State.ZOOMING,"Touching its dot starts a camera zoom")
				await get_tree().create_timer(.13).timeout;await frames()
				expect(game.state==game.State.TRACE and game.board.view!=game.full_view,"Zoom completes into a large tracing view")
				expect(AudioManager.local_voice_available(game.part_prompt(),locale),"Every part instruction has local language speech")
				var strokes: int=game.part().strokes.size()
				for stroke: int in range(strokes):
					expect(game.stroke_index==stroke and game.get_idle_action().has("to"),"One ordered stroke and one drag hint at a time")
					game.set_overlay_paused(true);var old: int=game.trace.edge;trace_line(game);expect(game.trace.edge==old,"Paused tracing cannot progress");game.set_overlay_paused(false)
					trace_line(game);await frames()
					expect(game.stroke_index==stroke+1 if stroke+1<strokes else game.state in [game.State.REVEAL,game.State.RETURNING],"Real pointer trace completes only its stroke")
				expect(game.completed[i],"Traced part fills into the house")
				await get_tree().create_timer(.25).timeout;await frames()
				expect(game.board.view==game.full_view,"Finished part returns to the whole picture")
			expect(game.state==game.State.PLAY and not game.has_node("CompletionParty"),"Full yard stays in free play without an ending overlay")
			var count: int=game.board.effect_count
			for point: Vector2 in [Vector2(503,480),Vector2(375,400),Vector2(616,100),Vector2(500,170)]:
				touch(global_point(game,point),true);touch(global_point(game,point),false)
			expect(game.board.effect_count==count+4 and game.board.lit.get("left_window",false),"Actual taps animate door,window,chimney and roof")
			var color: int=game.board.smoke_color;game.board.play_object("chimney");expect(game.board.smoke_color!=color,"Chimney changes the continuously emitted smoke color")
			touch(global_point(game,Vector2(135,35)),true);touch(global_point(game,Vector2(135,35)),false);expect(game.board.night,"Touching sun switches to night");touch(global_point(game,Vector2(135,35)),true);touch(global_point(game,Vector2(135,35)),false);expect(not game.board.night,"Touching moon switches back to day")
			touch(global_point(game,game.board.dog_position()),true);touch(global_point(game,game.board.dog_position()),false);expect(game.board.effects.has("dog") and game.board.bark.playing,"Puppy barks and begins its yard run")
			game.board.play_object("cloud");game.board.play_object("flowers");expect(game.board.effects.has("cloud") and game.board.effects.has("flowers"),"Rain and butterflies remain interactive")
			expect(game.counter.text.is_empty(),"Free play has no task completion counter")
			game.restart();await frames();expect(game.state==game.State.READY and not game.completed.has(true),"Replay starts a fresh single picture")
		GameManager.return_home();await frames()
	expect(not ProgressManager.document.games.has("living_drawing") or ProgressManager.document.games.living_drawing.completed_sessions==0,"Open-ended drawing creates no scored or completed session")
	GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false
	for i: int in range(6):game.completed[i]=true
	game.advance_part();expect(game.available_parts()==[6,7,8,9],"Four independent story markers appear after the house")
	game.board.play_object("door");expect(game.board.effects.has("door"),"Finished house remains playable while more drawing is offered")
	game.zoom_part(9);expect(game.part_index==9,"A child can choose flowers before sun or dog")
	await get_tree().create_timer(.13).timeout;await frames()
	var path: PackedVector2Array=game.trace.points
	expect(game.board.guide_dot_count(path)<=ceili(2*PI*40*game.board.camera_scale()/36.0)+20,"Guide uses approximately half the previous dot density")
	game.restart()
	app.find_child("BackButton",true,false).pressed.emit();await frames();expect(GameManager.current_route=="living_gallery","Back button returns to story gallery")
	app.current_view.find_child("HouseStory",true,false).pressed.emit();await frames();game=app.current_view;game.focus_paused=false
	SettingsManager.set_value("reduced_motion",false);game.zoom_part();game.set_overlay_paused(true);var frozen: Rect2=game.board.view
	await get_tree().create_timer(.5).timeout;expect(game.state==game.State.ZOOMING and game.board.view==frozen,"A parent overlay freezes the active zoom tween")
	game.set_overlay_paused(false);await get_tree().create_timer(.5).timeout;expect(game.state==game.State.TRACE,"Closing the overlay resumes the zoom")
	var first: Vector2=game.trace.current_point();touch(global_point(game,first),true);drag(global_point(game,first.lerp(game.trace.points[1],.4)))
	var fraction: float=game.trace.fraction;game.set_overlay_paused(true);drag(global_point(game,game.trace.points[1]));expect(game.trace.fraction==fraction and game.board.pointer_owner==-2,"Pausing releases a held finger without losing accepted ink")
	game.set_overlay_paused(false);touch(global_point(game,first),false);trace_line(game);await frames();expect(game.state==game.State.REVEAL,"Tracing resumes from the saved green point after interruption")
	game.restart();game.zoom_part();await get_tree().create_timer(.5).timeout;await frames()
	var start: Vector2=game.trace.current_point();touch(global_point(game,start),true);drag(global_point(game,start.lerp(game.trace.points[1],.4)));touch(global_point(game,start),false)
	var saved_fraction: float=game.trace.fraction;game.handle_back();await frames();app.current_view.find_child("HouseStory",true,false).pressed.emit();await frames();game=app.current_view;game.focus_paused=false
	expect(game.state==game.State.TRACE and is_equal_approx(game.trace.fraction,saved_fraction),"Returning from story gallery keeps accepted drawing in this app session")
	game.restart()
	for i: int in range(10):game.completed[i]=true
	game.finish_house();SettingsManager.set_value("reduced_motion",false);game.board.play_object("dog");var dog_start: Vector2=game.board.dog_position()
	await get_tree().create_timer(.3).timeout;expect(game.board.dog_position().distance_to(dog_start)>20,"Puppy actually moves through the yard after tapping")
	game.set_overlay_paused(true);var frozen_age: float=game.board.age;var dog_frozen: Vector2=game.board.dog_position();await get_tree().create_timer(.2).timeout
	expect(game.board.age==frozen_age and game.board.dog_position()==dog_frozen and game.board.bark.stream_paused,"Pausing freezes dog movement and its sound")
	game.set_overlay_paused(false)
	app.queue_free();await frames();await AudioManager.shutdown();print("LIVING HOUSE TESTS: %d checks, %d failures" % [checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
