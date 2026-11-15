extends Node
var checks := 0
var failures: Array[String]=[]
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(8):await get_tree().process_frame
func _ready() -> void:call_deferred("run")
func run() -> void:
	var fixture := "user://test-runs/coloring-layout-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();SettingsManager.set_value("music_enabled",false)
	for page: Dictionary in ColoringDocument.legacy_catalog():
		var original := ColoringDocument.new(page.id);original.page=page;original.colors[page.regions[0].id]="f08040"
		var old_state := original.state();old_state.erase("art_revision")
		var loaded := ColoringDocument.new(page.id)
		expect(loaded.restore(JSON.parse_string(JSON.stringify(old_state))),"Old JSON state restores: "+page.id)
		expect(loaded.render_image().get_data()==original.render_image().get_data(),"Old colored pixels remain identical: "+page.id)
		expect(loaded.state().art_revision==1,"Old nonblank art keeps original revision")
		var blank := ColoringDocument.new(page.id);blank.page=page
		loaded.restore(blank.state());expect(loaded.state().art_revision==2,"Blank old page upgrades to current artwork")
		var unknown := loaded.state();unknown.art_revision=3;expect(not ColoringDocument.valid_state(unknown),"Unknown artwork revision rejected")
	expect(ColoringDocument.available_catalog().size()==9,"Nine selectable coloring pages")
	expect(not ColoringDocument.available_catalog().any(func(item: Dictionary) -> bool:return item.id=="fox"),"Fox excluded from new picture selection")
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale)
		for viewport_size: Vector2i in [Vector2i(1280,800),Vector2i(1024,768),Vector2i(1280,600),Vector2i(1600,740)]:
			get_window().size=viewport_size;await frames();GameManager.start_game("coloring");await frames()
			var game: Variant=app.current_view
			SettingsManager.set_value("coloring_reference",false);game._update_reference();game.page_index=2;game._show_page();await frames()
			expect(game.canvas.size.y>=game.size.y*.8,"Paper uses at least eighty percent of content height")
			expect(game.canvas.size.x>=game.size.x*.72,"Paper uses available horizontal space")
			for control_name: String in ["PreviousPicture","NextPicture","RepeatWord","ToggleReference","Undo","Redo","SaveColoring","OpenGallery","ResetColoring"]:
				var control: Control=game.find_child(control_name,true,false)
				expect(game.get_global_rect().encloses(control.get_global_rect()),"Tool remains inside game: "+control_name)
			var region: Dictionary=game.document().page.regions[0]
			var paper: Rect2=game.canvas.image_rect()
			var event := InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=paper.position+(region.tap-game.canvas.source_bounds.position)/game.canvas.source_bounds.size*paper.size
			game.canvas._gui_input(event);expect(game.document().colors[region.id]!="ffffff","Zoomed paper routes touch to source region")
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				var folder := ProjectSettings.globalize_path("res://.local/qa/coloring-031");DirAccess.make_dir_recursive_absolute(folder)
				get_viewport().get_texture().get_image().save_png(folder+"/"+locale+"_"+str(viewport_size.x)+"x"+str(viewport_size.y)+".png")
			GameManager.navigate("activities");await frames()
	GameManager.start_game("coloring");await frames()
	var game: Variant=app.current_view
	var fox := ColoringDocument.new("fox");fox.fill_at(fox.page.regions[0].tap,Color.RED)
	var saved := ArtworkManager.save_artwork(fox.render_image(),fox.state())
	game.load_picture(saved);await frames()
	expect(game.document().page.id=="fox" and game.document().colors==fox.colors,"Archived fox artwork still opens with editable colors")
	GameManager.navigate("activities");GameManager.start_game("coloring");await frames()
	expect(app.current_view.book_pages.size()==9 and app.current_view.document().page.id!="fox","Archived draft never restores fox into new selection")
	app.queue_free();await frames();await AudioManager.shutdown()
	print("COLORING LAYOUT TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
