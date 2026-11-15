extends Node

var checks := 0
var failures: PackedStringArray = []
var app: Variant
const ROUTES := ["home","activities","animals","colors","feeding","shapes","puzzles","memory","counting","drawing","coloring","xylophone"]

func _ready() -> void:
	get_tree().create_timer(70).timeout.connect(func() -> void: get_tree().quit(1))
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		print("FAIL: "+message)

func frames() -> void:
	for i: int in range(4): await get_tree().process_frame

func _run() -> void:
	var fixture := "user://test-runs/ux-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json"
	ProgressManager.storage_path=fixture+"/progress.json"
	ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("voice_volume",0.0)
	SettingsManager.set_value("reduced_motion",true)
	app=preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale)
		await frames()
		for difficulty: String in ["easy","normal","advanced"]:
			SettingsManager.set_value("difficulty",difficulty)
			for route: String in ROUTES:
				GameManager.navigate(route)
				await frames()
				var v: Variant=app.current_view
				if v.has_method("_update_pause"):
					v.focus_paused=false;v._update_pause()
				elif v.get("focus_paused") != null: v.focus_paused=false
				var guide: IdleGuide=app.idle_guide
				guide.reset()
				guide._process(9.9)
				expect(guide.action.is_empty(),"No early guide: "+route)
				guide._process(0.2)
				expect(not guide.action.is_empty(),"One concrete idle action: "+route+":"+difficulty)
				if not guide.action.is_empty():
					expect(get_viewport().get_visible_rect().has_point(guide.action.from),"Guide start on screen")
					expect(not guide.action.has("to") or get_viewport().get_visible_rect().has_point(guide.action.to),"Guide destination on screen")
				var click := InputEventMouseButton.new()
				click.button_index=MOUSE_BUTTON_LEFT
				guide._input(click)
				expect(guide.action.is_empty() and guide.idle==0,"User input immediately removes guide")
				app.open_parent_gate()
				guide._process(11)
				expect(guide.action.is_empty(),"No guide through parent modal")
				app.close_modal()
				GameManager.return_home()
				await frames()
	# Large catalog: mounted controls depend on viewport, never on entry count.
	GameManager.navigate("activities")
	await frames()
	var menu: Variant=app.current_view
	menu.scroll.scroll_vertical=0
	await frames()
	var origin: Vector2=menu.scroll.global_position+Vector2(180,180)
	var down := InputEventMouseButton.new()
	down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;down.position=origin
	get_viewport().push_input(down,true)
	var move := InputEventMouseMotion.new()
	move.position=origin-Vector2(0,150);move.relative=Vector2(0,-150)
	get_viewport().push_input(move,true)
	var up := InputEventMouseButton.new()
	up.button_index=MOUSE_BUTTON_LEFT;up.position=move.position
	get_viewport().push_input(up,true)
	await frames()
	expect(GameManager.current_route=="activities" and menu.scroll.scroll_vertical>0,"Mouse pan scrolls without launching the pressed game")
	menu.scroll.scroll_vertical=0
	await frames()
	var touch := InputEventScreenTouch.new()
	touch.index=3;touch.pressed=true;touch.position=origin
	get_viewport().push_input(touch,true)
	for i: int in range(1,5):
		var drag := InputEventScreenDrag.new()
		drag.index=3;drag.position=origin-Vector2(0,i*40);drag.relative=Vector2(0,-40);drag.velocity=Vector2(0,-300)
		get_viewport().push_input(drag,true)
		await frames()
	touch=InputEventScreenTouch.new()
	touch.index=3;touch.position=origin-Vector2(0,160)
	get_viewport().push_input(touch,true)
	await frames()
	expect(GameManager.current_route=="activities" and menu.scroll.scroll_vertical>0,"Touch swipe scrolls and never launches the card")
	app.idle_guide.reset()
	app.idle_guide.contacts[6]=true
	app.idle_guide._process(12)
	expect(app.idle_guide.action.is_empty(),"A held contact never shows a competing guide")
	app.idle_guide.contacts.clear()
	# Fresh menu clears inertial touch scroll before programmatic stress traversal.
	GameManager.return_home()
	await frames()
	GameManager.navigate("activities")
	await frames()
	menu=app.current_view
	menu.scroll.scroll_vertical=250
	await frames()
	var stored_scroll: int=menu.scroll.scroll_vertical
	GameManager.return_home()
	await frames()
	GameManager.navigate("activities")
	await frames()
	menu=app.current_view
	expect(menu.scroll.scroll_vertical==stored_scroll,"Returning to menu restores scroll position")
	for index: int in range(1000):
		menu.entries.append({"node":"Future_"+str(index),"title":"ANIMALS_TITLE","route":"animals","art":"res://assets/objects/animals/cat.svg"})
	menu._sync_cells()
	await frames()
	for offset: int in [0,5000,50000,100000,0]:
		menu.scroll.scroll_vertical=offset
		await frames()
		expect(menu.cells.size()<=28,"A thousand future games retain bounded recycled controls")
	expect(menu.find_child("NextActivities",true,false)==null,"No pagination buttons")
	menu.ensure_activity("drawing")
	await frames()
	menu.find_child("DrawingButton",true,false).pressed.emit()
	await frames()
	for id: String in ["Undo","Redo","SaveDrawing","OpenGallery","ClearDrawing","Tool_regular","Tool_soft","Tool_rainbow","Tool_eraser","Size_4","Size_10","Size_20"]:
		var button := app.current_view.find_child(id,true,false) as Button
		expect(button!=null and button.icon!=null and button.text.is_empty() and not button.tooltip_text.is_empty(),"Readable-independent drawing icon: "+id)
	var stroke := InputEventScreenTouch.new()
	stroke.index=9;stroke.pressed=true;stroke.position=app.current_view.canvas.get_global_rect().get_center()
	get_viewport().push_input(stroke,true)
	stroke=InputEventScreenTouch.new()
	stroke.index=9;stroke.position=app.current_view.canvas.get_global_rect().get_center()
	get_viewport().push_input(stroke,true)
	app.idle_guide._process(10.1)
	expect(not app.idle_guide.action.is_empty(),"A consumed canvas release does not disable later idle help")
	for key: String in ContentManager.manifest.voice:
		var path: String=ContentManager.voice_path(key,"uk")
		var lesson_locale: String=ContentManager.manifest.get("study_locales",{}).get(key,"uk")
		expect(path.begins_with("res://assets/audio/voice/"+lesson_locale+"/") and ResourceLoader.exists(path),"UI speech is Ukrainian; explicit alphabet lessons use their declared study language")
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("UX TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
