extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/feedback"
func _ready() -> void: call_deferred("_run")
func frames() -> void:
	for i: int in range(5): await get_tree().process_frame
func capture(label: String) -> void:
	await frames();await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(output+"/"+label+".png"))!=OK:issues.append("Capture failed: "+label)
	check(app,label,false)
	captures+=1
func check(node: Node,label: String,scrolled: bool) -> void:
	if node is ScrollContainer:scrolled=true
	if node is BaseButton and node.is_visible_in_tree() and not scrolled:
		if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):issues.append(label+":"+str(node.name))
	for child: Node in node.get_children():check(child,label,scrolled)
func _run() -> void:
	get_window().title="Little Wonder World - Feedback QA"
	var fixture := "user://test-runs/feedback-render-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
		get_window().size=resolution
		for locale: String in ["en","uk"]:
			GameManager.return_home();SettingsManager.set_value("locale",locale);await frames()
			var suffix := "%s_%dx%d" % [locale,resolution.x,resolution.y]
			GameManager.navigate("activities");await frames()
			app.current_view.ensure_activity("balloons")
			await capture("catalog_"+suffix)
			GameManager.start_game("letters");await frames()
			app.current_view.focus_paused=false
			await capture("letters_"+suffix)
			app.current_view.set_picture_mode(true);await capture("letter_picture_"+suffix)
			for card_index: int in [10,30] if locale=="uk" else [8,23]:
				app.current_view.card_index=card_index;app.current_view.build();await capture("letter_example_"+str(card_index)+"_"+suffix)
			if resolution==Vector2i(1280,800):
				var total: int=app.current_view.entries().size()
				var sheet := Image.create(1600,ceili(total/5.0)*200,false,Image.FORMAT_RGBA8);sheet.fill(Color("f3f4e4"))
				for letter_index: int in range(total):
					app.current_view.card_index=letter_index;app.current_view.build()
					await capture("card_%s_%02d" % [locale,letter_index])
					var thumb := get_viewport().get_texture().get_image();thumb.resize(320,200,Image.INTERPOLATE_LANCZOS)
					sheet.blit_rect(thumb,Rect2i(0,0,320,200),Vector2i((letter_index%5)*320,(letter_index/5)*200))
				sheet.save_png(ProjectSettings.globalize_path(output+"/alphabet_sheet_"+locale+".png"))
			GameManager.start_game("syllables");await frames()
			app.current_view.focus_paused=false
			await capture("word_"+suffix)
			app.current_view.choose(app.current_view.target().letters[0]);await capture("word_partial_"+suffix)
			var pool: Array=WordCatalog.items(locale);pool.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:return a.letters.size()>b.letters.size())
			app.current_view.targets=[pool[0]];app.current_view.round_index=0;app.current_view.filled=0;app.current_view.prepare_tiles();app.current_view.show_question();await capture("word_long_"+suffix)
			if resolution==Vector2i(1280,800):
				var body_words: Array=pool.filter(func(word: Dictionary) -> bool:return word.id.begins_with("word:world_body:"))
				var sheet := Image.create(1600,800,false,Image.FORMAT_RGBA8);sheet.fill(Color("f3f4e4"))
				for i: int in range(body_words.size()):
					app.current_view.targets=[body_words[i]];app.current_view.filled=0;app.current_view.prepare_tiles();app.current_view.show_question()
					await capture("body_word_"+str(i)+"_"+suffix)
					var thumb := get_viewport().get_texture().get_image();thumb.resize(320,200,Image.INTERPOLATE_LANCZOS)
					sheet.blit_rect(thumb,Rect2i(0,0,320,200),Vector2i((i%5)*320,(i/5)*200))
				sheet.save_png(ProjectSettings.globalize_path(output+"/body_words_sheet_"+locale+".png"))
			GameManager.start_game("balloons");await frames()
			await capture("balloons_"+suffix)
			GameManager.start_game("drawing");await frames()
			var drawing: Variant=app.current_view
			drawing.focus_paused=false;drawing._update_pause()
			drawing.select_paint("gradient:d95b59:578dc2")
			drawing.canvas.document.radius=20
			drawing.canvas.document.begin(Vector2(160,160));drawing.canvas.document.move(Vector2(800,400));drawing.canvas.document.finish();drawing.canvas.refresh()
			await capture("gradient_drawing_"+suffix)
			drawing.palette.open_picker()
			await capture("palette_"+suffix)
			app.close_modal()
			GameManager.start_game("coloring");await frames()
			app.current_view.focus_paused=false;app.current_view._update_pause()
			app.current_view.select_paint("gradient:d95b59:578dc2")
			app.current_view.fill_at(app.current_view.document().page.regions[0].tap)
			await capture("gradient_coloring_"+suffix)
	GameManager.return_home();await frames();app.queue_free();await frames();await AudioManager.shutdown()
	print("FEEDBACK RENDER: %d screenshots, %d issues" % [captures,issues.size()])
	for issue: String in issues:print("LAYOUT: "+issue)
	get_tree().quit(0 if issues.is_empty() else 1)
