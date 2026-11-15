extends Node
var checks := 0
var failures: PackedStringArray = []
var app: Variant
const ROUTES := ["animals","colors","feeding","shapes","puzzles","memory","counting"]

func _ready() -> void:
	get_tree().create_timer(65).timeout.connect(func() -> void: get_tree().quit(1))
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		print("FAIL: "+message)

func frames() -> void:
	for i: int in range(4): await get_tree().process_frame

func touch(index: int, point: Vector2, pressed: bool = true, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.index=index;event.position=point;event.pressed=pressed;event.canceled=canceled
	get_viewport().push_input(event,true)

func _run() -> void:
	var fixture := "user://test-runs/party-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json"
	ProgressManager.storage_path=fixture+"/progress.json"
	ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("voice_volume",0.0)
	app=preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale)
		await frames()
		for difficulty: String in ["easy","normal","advanced"]:
			SettingsManager.set_value("difficulty",difficulty)
			SettingsManager.set_value("reduced_motion",difficulty=="easy")
			for route: String in ROUTES:
				GameManager.start_game(route)
				await frames()
				var game: Variant=app.current_view
				game.focus_paused=false
				if game.has_method("_update_pause"): game._update_pause()
				game._show_complete()
				await frames()
				var party := game.get_node("CompletionParty") as CompletionCelebration
				expect(party.balloons.size()==6 and party.popped.is_empty(),"Six fresh balloons at round end")
				expect(not game.body.is_visible_in_tree(),"Results and replay cannot receive focus behind balloons")
				var sessions: int=ProgressManager.document.games[route].completed_sessions
				game._show_complete()
				expect(game.get_node("CompletionParty")==party and ProgressManager.document.games[route].completed_sessions==sessions,"Duplicate completion cannot restart reward or recount session")
				var first := party.balloons[0]
				var point := first.global_position+first.balloon_rect().get_center()
				touch(1,first.global_position+Vector2(2,2))
				touch(1,first.global_position+Vector2(2,2),false)
				expect(party.popped.is_empty(),"Empty cell corner is not a balloon hit")
				touch(1,point,true,true)
				expect(party.popped.is_empty(),"Canceled touch never pops")
				game.set_overlay_paused(true)
				party.pop_balloon(0)
				expect(party.popped.is_empty(),"Parent overlay blocks balloon actions")
				game.set_overlay_paused(false)
				game.focus_paused=true
				var age: float=party.elapsed
				party._process(1)
				party.pop_balloon(0)
				expect(party.popped.is_empty() and party.elapsed==age,"Focus loss pauses effects and input")
				game.focus_paused=false
				touch(1,point)
				touch(1,point,false)
				expect(party.popped.size()==1 and first.popped,"Actual viewport touch pops one balloon")
				party.pop_balloon(0)
				expect(party.popped.size()==1,"Repeated/emulated hit never counts twice")
				app.idle_guide.reset()
				var hint: Dictionary=app.idle_guide.next_action()
				expect(hint.has("from") and hint.from!=point,"Idle help selects a remaining balloon")
				for index: int in range(1,5):
					var balloon := party.balloons[index]
					touch(index+1,balloon.global_position+balloon.balloon_rect().get_center())
					touch(index+1,balloon.global_position+balloon.balloon_rect().get_center(),false)
				expect(party.popped.size()==5 and not game.body.is_visible_in_tree(),"Five of six is not finished")
				var last := party.balloons[5]
				touch(6,last.global_position+last.balloon_rect().get_center())
				touch(6,last.global_position+last.balloon_rect().get_center(),false)
				await frames()
				expect(not game.has_node("CompletionParty") and game.body.is_visible_in_tree(),"Only the last pop reveals result and replay")
				expect(ProgressManager.document.games[route].completed_sessions==sessions,"Popping adds no fake learning score")
				GameManager.return_home()
				await frames()
	# Leaving mid-celebration never carries balloons into the next game.
	GameManager.start_game("memory")
	await frames()
	app.current_view._show_complete()
	GameManager.return_home()
	await frames()
	expect(not app.current_view.has_node("CompletionParty"),"Home always remains available")
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("CELEBRATION TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
