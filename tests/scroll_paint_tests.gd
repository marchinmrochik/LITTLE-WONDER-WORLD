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
func touch(point: Vector2,pressed: bool,index: int=5,canceled: bool=false) -> void:
	var event := InputEventScreenTouch.new();event.position=point;event.pressed=pressed;event.index=index;event.canceled=canceled;get_viewport().push_input(event,true)
func tap(point: Vector2) -> void:touch(point,true);touch(point,false)
func swipe(from: Vector2,to: Vector2) -> void:
	touch(from,true)
	for i: int in range(1,6):
		var event := InputEventScreenDrag.new();event.index=5;event.position=from.lerp(to,i/5.0);event.relative=(to-from)/5.0;event.velocity=(to-from)*4;get_viewport().push_input(event,true);await frames()
	touch(to,false);await frames()
func run() -> void:
	var folder := "user://test-runs/scroll-paint-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=folder+"/settings.json";ProgressManager.storage_path=folder+"/progress.json";ArtworkManager.directory=folder+"/artwork";AssessmentHistory.storage_path=folder+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
	get_window().size=Vector2i(1280,800)
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);GameManager.return_home();await frames()
		var home: Variant=app.current_view;var scroll: TouchScroll=home.find_child("PetScroll",true,false)
		var origin: Vector2=scroll.get_global_rect().get_center()
		var selected: String=SettingsManager.values.companion
		await swipe(origin,origin-Vector2(220,0))
		expect(GameManager.current_route=="home" and scroll.scroll_horizontal>0 and SettingsManager.values.companion==selected,"Pet row swipes horizontally without selecting a friend")
		scroll.cancel_gesture();scroll.scroll_horizontal=0;await frames()
		scroll.cancel_gesture();var cat: Button=home.pet_buttons.cat
		tap(cat.get_global_rect().get_center());await frames()
		expect(SettingsManager.values.companion=="cat","A stationary touch still selects a pet after scrolling")
		home.find_child("NextPet",true,false).pressed.emit();await frames()
		expect(SettingsManager.values.companion=="dog" and home.fox.portrait.texture.resource_path==CompanionCatalog.illustration("dog"),"Right portrait arrow chooses and shows the next pet")
		home.find_child("PreviousPet",true,false).pressed.emit();await frames();expect(SettingsManager.values.companion=="cat","Left portrait arrow chooses the previous pet")
		home.choose_pet("fox");home.step_pet(-1);await frames();expect(SettingsManager.values.companion=="horse","Portrait arrows wrap through all eleven pets")
		expect(scroll.get_global_rect().grow(1).encloses(home.pet_buttons.horse.get_global_rect()),"Arrow selection reveals its thumbnail in the strip")
		GameManager.navigate("activities");await frames()
		var menu: Variant=app.current_view;origin=menu.scroll.get_global_rect().get_center()
		await swipe(origin,origin-Vector2(0,170));expect(GameManager.current_route=="activities" and menu.scroll.scroll_vertical>0,"Unified catalogue pan does not open cards")
		var after: int=menu.scroll.scroll_vertical;menu.scroll._process(.08);expect(menu.scroll.scroll_vertical>=after,"A released swipe keeps moving in its direction")
		menu.scroll.velocity=500.0;tap(menu.scroll.get_global_rect().get_center());await frames()
		expect(GameManager.current_route=="activities" and menu.scroll.velocity==0.0,"Touching a moving list stops inertia without opening a game")
		menu.scroll.cancel_gesture();menu.scroll.scroll_vertical=0;await frames()
		var card: Button=menu.find_child("AnimalsButton",true,false)
		touch(card.get_global_rect().get_center(),true);touch(card.get_global_rect().get_center(),false,5,true);await frames();expect(GameManager.current_route=="activities","Canceled touch never opens a game")
		for pressed: bool in [true,false]:
			var duplicate := InputEventMouseButton.new();duplicate.device=InputEvent.DEVICE_ID_EMULATION;duplicate.position=card.get_global_rect().get_center();duplicate.button_index=MOUSE_BUTTON_LEFT;duplicate.pressed=pressed;get_viewport().push_input(duplicate,true)
		expect(GameManager.current_route=="activities","Engine-emulated mouse duplicates cannot open a touch card")
		touch(card.get_global_rect().get_center(),true,5);touch(card.get_global_rect().get_center(),true,6);touch(card.get_global_rect().get_center(),false,5);touch(card.get_global_rect().get_center(),false,6);await frames()
		expect(GameManager.current_route=="activities","An extra finger never produces an accidental selection")
		tap(card.get_global_rect().get_center());await frames();expect(GameManager.current_route=="animals","A stationary touch opens a game once")
		GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames()
		scroll=app.current_view.find_child("SettingsScroll",true,false);var slider: HSlider=app.current_view.find_child("music_volume",true,false)
		var wheel := InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN;wheel.pressed=true;wheel.factor=1.0;wheel.position=scroll.get_global_rect().get_center();get_viewport().push_input(wheel,true)
		expect(scroll.scroll_vertical>0,"Mouse wheel scrolls the whole settings content")
		scroll.scroll_vertical=0;await frames()
		var old_value := slider.value;origin=slider.get_global_rect().get_center()
		await swipe(origin,origin-Vector2(0,180));expect(scroll.scroll_vertical>0 and slider.value==old_value,"Vertical swipe over volume changes scroll without changing volume")
		scroll.cancel_gesture();scroll.scroll_vertical=0;await frames();origin=slider.get_global_rect().get_center()
		await swipe(origin-Vector2(90,0),origin+Vector2(90,0));expect(slider.value>50 and scroll.scroll_vertical==0,"Horizontal slider drag still changes volume without panning")
		GameManager.return_home();await frames();GameManager.start_game("drawing");await frames()
		var drawing: Variant=app.current_view;drawing.focus_paused=false;drawing._update_pause()
		expect(drawing.find_child("DrawingTools",true,false).size.x<=80,"Drawing side tools are compact")
		print("CANVAS ",locale," ",drawing.canvas.image_rect()," viewport=",get_viewport().get_visible_rect()," top=",drawing.column.get_child(0).size)
		expect(drawing.canvas.image_rect().size.x>900 and drawing.canvas.image_rect().size.y>550,"Visible drawing paper grows in both dimensions at1280x800")
		var available := PaintPalette.available_paints();expect(available.size()>130,"Expanded palette offers over130paint choices")
		drawing.palette.open_picker();await frames();scroll=app.modal.find_child("PaletteScroll",true,false)
		origin=scroll.get_global_rect().get_center();await swipe(origin,origin-Vector2(0,180))
		expect(is_instance_valid(app.modal) and scroll.scroll_vertical>0 and drawing.overlay_paused,"Palette pans without choosing a color or drawing through the modal")
		scroll.cancel_gesture();scroll.scroll_vertical=0;await frames()
		var swatch: Button=app.modal.find_child("Paint_ffffff",true,false);tap(swatch.get_global_rect().get_center());await frames()
		expect(not is_instance_valid(app.modal) and drawing.canvas.document.color==Color.WHITE and not drawing.overlay_paused,"A deliberate swatch tap applies color and resumes drawing")
		drawing.select_paint("d95b59")
		var point: Vector2=drawing.canvas.global_position+drawing.canvas.image_rect().get_center();touch(point,true);touch(point,false);await frames()
		expect(not drawing.canvas.document.is_blank(),"Larger fitted canvas still records actual touch ink")
		GameManager.return_home();await frames()
	app.queue_free();await frames();await AudioManager.shutdown()
	print("SCROLL PAINT TESTS: %d checks, %d failures" % [checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
