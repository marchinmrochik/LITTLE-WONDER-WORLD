extends Node
var checks := 0
var failures: Array[String]=[]
var captures := 0
func _ready() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(6):await get_tree().process_frame
func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path("res://.local/qa/gallery-reference")
	DirAccess.make_dir_recursive_absolute(folder)
	expect(get_viewport().get_texture().get_image().save_png(folder+"/"+file+".png")==OK,"Native screenshot saved");captures+=1
func run() -> void:
	var fixture := "user://test-runs/gallery-reference-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();SettingsManager.set_value("music_enabled",false)
	expect(not SettingsManager.values.coloring_reference,"Examples default off")
	var old := SettingsManager.values.duplicate();old.erase("coloring_reference");expect(SettingsManager.is_valid_document(old),"Older settings migrate without losing values")
	expect(not SettingsManager.set_value("coloring_reference","yes"),"Example preference requires boolean")
	for page: Dictionary in ColoringDocument.catalog():
		var image := ColoringDocument.reference_image(page.id)
		expect(image!=null and image.get_size()==PaintDocument.SIZE,"Complete authored example: "+page.id)
		for region: Dictionary in page.regions:expect(image.get_pixelv(Vector2i(region.tap))!=Color.WHITE,"Visible example color: "+page.id+":"+region.id)
	var paint := PaintDocument.new();paint.begin(Vector2(100,100));paint.move(Vector2(700,400));paint.finish()
	var id := ArtworkManager.save_artwork(paint.image)
	var original := FileAccess.get_file_as_bytes(ArtworkManager.directory+"/gallery/"+id+".png")
	var destination := fixture+"/exports/test.png"
	expect(ArtworkManager.export_artwork(id,destination)==OK,"Export creates PNG in chosen location")
	expect(FileAccess.get_file_as_bytes(destination)==original,"PNG export retains exact saved pixels")
	expect(ArtworkManager.export_artwork(id,destination)==OK,"Explicit overwrite replaces one export")
	expect(ArtworkManager.export_artwork("../bad",destination)!=OK,"Unknown source rejected")
	expect(ArtworkManager.export_artwork(id,ArtworkManager.directory+"/gallery/"+id+".png")!=OK,"Export cannot overwrite gallery source")
	expect(ArtworkManager.export_artwork(id,fixture+"/not-png.txt")!=OK,"Only PNG export is accepted")
	expect(ArtworkManager.export_artwork(id,"res://project.godot")!=OK,"Export cannot write project resources")
	var blocked := FileAccess.open(fixture+"/blocked",FileAccess.WRITE);blocked.store_string("keep");blocked.close()
	expect(ArtworkManager.export_artwork(id,fixture+"/blocked/fail.png")!=OK,"Failed destination reports error")
	expect(ArtworkManager.entries.size()==1 and ArtworkManager.load_artwork(id).get_data()==paint.image.get_data(),"Exports and errors preserve original gallery")
	# Populate a realistic large gallery without forcing costly duplicate PNG encoding.
	for i: int in range(1,ArtworkManager.MAX_ENTRIES):
		var copy_id := "123_"+str(i)
		DirAccess.copy_absolute(ArtworkManager.directory+"/gallery/"+id+".png",ArtworkManager.directory+"/gallery/"+copy_id+".png")
		ArtworkManager.entries.append({"id":copy_id,"created":i})
	expect(ArtworkManager._write_index()==OK,"Expanded index persists")
	ArtworkManager.reload();expect(ArtworkManager.entries.size()==200,"All 200 drawings survive reload")
	expect(ArtworkManager.save_artwork(paint.image).is_empty(),"Full gallery never silently evicts art")
	ArtworkManager.last_error=OK
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale)
		for viewport_size: Vector2i in [Vector2i(1280,800),Vector2i(1024,768)]:
			get_window().size=viewport_size;await frames()
			GameManager.parents_unlocked=true;GameManager.navigate("gallery");await frames()
			var gallery: ArtworkGallery=app.current_view.gallery
			expect(gallery.allow_export and gallery.find_child("Export_"+id,true,false)!=null,"Export is available in adult gallery")
			expect(gallery.cards.size()<=24 and gallery.thumbnails.size()<=24,"Large gallery uses bounded cards and thumbnails")
			await capture(locale+"_"+str(viewport_size.x)+"_gallery")
			gallery.scroll.scroll_vertical=int(gallery.scroll.get_v_scroll_bar().max_value);await frames()
			expect(gallery.find_child("Open_123_199",true,false)!=null,"Last drawing is reachable by scrolling")
			var chosen := [""]
			gallery.opened.connect(func(value: String) -> void:chosen[0]=value)
			gallery.find_child("Open_123_199",true,false).pressed.emit()
			expect(chosen[0]=="123_199","Recycled card opens its current drawing")
			expect(gallery.cards.size()<=24 and gallery.thumbnails.size()<=24,"Scrolling keeps memory bounded")
			await frames()
			GameManager.start_game("coloring");await frames()
			var game: Variant=app.current_view
			game.page_index=0;game._show_page()
			SettingsManager.set_value("coloring_reference",false);game._update_reference();await frames()
			var state: Dictionary=game.document().state();var paper_width: float=game.canvas.size.x
			expect(not game.reference_panel.visible,"Example hidden on request")
			await capture(locale+"_"+str(viewport_size.x)+"_off")
			game.toggle_reference();await frames()
			expect(game.reference_panel.visible and game.reference_picture.texture!=null,"Toggle reveals example")
			expect(game.document().state()==state and game.document().cursor==0,"Example never recolors or changes undo history")
			expect(game.canvas.size.x<paper_width and game.canvas.size.x>450,"Example leaves usable coloring area")
			game.change_page(1);await frames()
			expect(game.reference_picture.texture.get_image().get_data()==ColoringDocument.reference_image("dog").get_data(),"Reference follows selected picture")
			await capture(locale+"_"+str(viewport_size.x)+"_on")
			game.show_gallery();await frames()
			expect(not game.gallery.allow_export and game.gallery.find_child("Export_*",true,false)==null,"Filesystem controls stay out of child gallery")
			GameManager.navigate("activities");await frames()
	SettingsManager.reload();expect(SettingsManager.values.coloring_reference,"Example choice persists")
	app.queue_free();await frames();await AudioManager.shutdown()
	print("GALLERY/REFERENCE TESTS: %d checks, %d failures, %d captures"%[checks,failures.size(),captures]);get_tree().quit(0 if failures.is_empty() else 1)
