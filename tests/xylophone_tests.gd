extends Node

var checks := 0
var failures: PackedStringArray = []
var app: Variant

func _ready() -> void:
	get_tree().create_timer(40).timeout.connect(func() -> void: get_tree().quit(1))
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		print("FAIL: "+message)

func frames() -> void:
	for index: int in range(4):
		await get_tree().process_frame

func touch(id: int, point: Vector2, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = point
	event.pressed = pressed
	event.canceled = canceled
	get_viewport().push_input(event,true)

func playing(game: Variant) -> int:
	var count := 0
	for player: AudioStreamPlayer in game.players:
		if player.playing:
			count += 1
	return count

func _run() -> void:
	var fixture := "user://test-runs/xylophone-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path = fixture+"/settings.json"
	ProgressManager.storage_path = fixture+"/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled",false)
	SettingsManager.set_value("reduced_motion",true)
	app = preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await frames()
	for locale: String in ["en","uk"]:
		GameManager.return_home()
		SettingsManager.set_value("locale",locale)
		await frames()
		GameManager.navigate("activities")
		await frames()
		app.current_view.set_page(2)
		await frames()
		var entry := app.current_view.find_child("XylophoneButton",true,false) as Button
		expect(entry != null,"Menu page3 offers instrument in "+locale)
		entry.pressed.emit()
		await frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		game._update_pause()
		expect(GameManager.current_route == "xylophone","Actual menu routes to instrument")
		expect(game.players.size()==16 and game.streams.size()==8,"Bounded sixteen voices and eight preloaded notes")
		expect(AudioManager.instrument_active and AudioManager.music.volume_db <= -80,"Background pitches silent during play")
		var keyboard: XylophoneKeyboard = game.keyboard
		for index: int in range(8):
			var point := keyboard.global_position+keyboard.key_rect(index).get_center()
			expect(keyboard.key_at(keyboard.key_rect(index).get_center())==index,"Key geometry identity")
			touch(index,point,true)
			expect(game.strikes==index+1,"Each independent touch strikes exactly once")
			expect(game.players[index].stream == game.streams[index],"Touch produces correct pitch stream")
		expect(keyboard.pointers.size()==8 and playing(game)==8,"Eight simultaneous touches retain eight voices")
		expect(keyboard.pulses.count(0)==8,"Reduced motion avoids pulse animation")
		touch(0,Vector2(-100,-100),false)
		expect(keyboard.pointers.size()==7 and keyboard.pointers.has(1),"Outside release removes only its pointer")
		touch(1,Vector2.ZERO,false,true)
		expect(keyboard.pointers.size()==6,"Canceled touch clears its pointer")
		var before: int = game.strikes
		var mouse := InputEventMouseButton.new()
		mouse.device = InputEvent.DEVICE_ID_EMULATION
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.pressed = true
		mouse.position = keyboard.global_position+keyboard.key_rect(0).get_center()
		get_viewport().push_input(mouse,true)
		expect(game.strikes==before,"Touch-emulated mouse never doubles a note")
		game.set_overlay_paused(true)
		expect(playing(game)==0 and keyboard.pointers.is_empty(),"Parent overlay clears touches and all note tails")
		touch(23,keyboard.global_position+keyboard.key_rect(0).get_center(),true)
		expect(game.strikes==before,"Overlay blocks new notes")
		game.set_overlay_paused(false)
		# Two fingers on the same key remain independently owned.
		var point := keyboard.global_position+keyboard.key_rect(2).get_center()
		touch(40,point,true)
		touch(41,point,true)
		touch(40,point,false)
		expect(keyboard.pointers.size()==1 and keyboard.pointers.has(41),"Same-key fingers release independently")
		var drag := InputEventScreenDrag.new()
		drag.index = 41
		drag.position = keyboard.global_position+keyboard.key_rect(3).get_center()
		before = game.strikes
		get_viewport().push_input(drag,true)
		expect(game.strikes==before+1,"Sliding to another key strikes it")
		get_viewport().push_input(drag,true)
		expect(game.strikes==before+1,"Moving within one key does not retrigger")
		drag.position = Vector2(-100,-100)
		get_viewport().push_input(drag,true)
		drag.position = point
		get_viewport().push_input(drag,true)
		expect(game.strikes==before+2,"Leaving and reentering a key restrikes")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		expect(playing(game)==0 and keyboard.pointers.is_empty(),"Focus loss silences notes and releases owners")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		SettingsManager.set_value("sfx_volume",0.0)
		before = game.strikes
		touch(60,point,true)
		expect(game.strikes==before and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),"Parent SFX mute controls instrument")
		touch(60,point,false)
		SettingsManager.set_value("sfx_volume",0.55)
		game.stop_notes()
		for index: int in range(100):
			game.play_note(index%8)
		expect(playing(game)==16 and game.players.size()==16,"Rapid repeated strikes remain bounded and polyphonic")
		GameManager.return_home()
		await frames()
		expect(not AudioManager.instrument_active and AudioManager.music.volume_db > -80,"Leaving restores background music level")
	app.queue_free()
	await frames()
	await AudioManager.shutdown()
	print("XYLOPHONE TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)
