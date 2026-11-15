extends Node
var checks := 0
var failures: PackedStringArray = []
var app: Variant

func _ready() -> void:
	get_tree().create_timer(90).timeout.connect(func() -> void: get_tree().quit(1))
	call_deferred("_run")
func expect(value: bool,message: String) -> void:
	checks+=1
	if not value: failures.append(message);print("FAIL: "+message)
func frames() -> void:
	for i: int in range(4): await get_tree().process_frame

func _run() -> void:
	var fixture := "user://test-runs/feedback-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
	app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	await frames()
	var doc := PaintDocument.new()
	doc.gradient_enabled=true;doc.gradient_to=Color.BLUE
	doc.begin(Vector2(100,100));doc.move(Vector2(340,100));doc.finish()
	expect(doc.image.get_pixel(100,100)!=doc.image.get_pixel(340,100),"Gradient brush creates different real pixels along the stroke")
	var bytes := doc.image.get_data()
	doc.undo();doc.redo()
	expect(bytes==doc.image.get_data(),"Gradient stroke has exact undo/redo")
	var book := ColoringDocument.new("cat")
	var point: Vector2=book.page.regions[0].tap
	expect(book.fill_paint(point,"gradient:d95b59:578dc2"),"One coloring region accepts a gradient")
	var state := book.state()
	expect(ColoringDocument.valid_state(state) and book.render_image()!=null,"Gradient SVG and semantic state render and validate")
	var saved := ArtworkManager.save_artwork(book.render_image(),state)
	ArtworkManager.reload()
	var restored := ColoringDocument.new()
	expect(not saved.is_empty() and restored.restore(ArtworkManager.coloring_state(saved)) and restored.state()==state,"Gradient remains editable after gallery reopen")
	expect(not ColoringDocument.valid_paint("gradient:bad:<svg>"),"Invalid gradient strings cannot inject SVG")
	for route: String in ["drawing","coloring"]:
		GameManager.start_game(route);await frames()
		var game: Variant=app.current_view
		game.palette.open_picker()
		expect(app.modal!=null and game.overlay_paused,"Expanded palette pauses active strokes")
		var swatch := app.modal.find_child("Paint_gradient_d95b59_efce55",true,false) as Button
		expect(swatch!=null,"Six visible preset gradients are selectable")
		swatch.pressed.emit()
		expect(not is_instance_valid(app.modal) and not game.overlay_paused,"Selecting a swatch closes palette and resumes drawing")
		expect(game.canvas.document.gradient_enabled if route=="drawing" else game.selected_paint=="gradient:d95b59:efce55","The UI selection applies the actual gradient")
		GameManager.return_home();await frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale",locale);await frames()
		for difficulty: String in ["easy","normal","advanced"]:
			SettingsManager.set_value("difficulty",difficulty)
			for route: String in ["shapes","puzzles"]:
				GameManager.start_game(route);await frames()
				var game: Variant=app.current_view
				game.focus_paused=false;game._update_pause()
				if route=="shapes":
					var first: String=game.model.sources[0]
					game.begin_drag(first,1,game.source_cards[first].get_global_rect().get_center())
					game.drag.move(game.slots[first].get_global_rect().get_center());game.drag.release(game.slots[first].get_global_rect().get_center())
					expect(game.state==game.State.FEEDBACK,"First shape is still in praise animation")
					var next: String=game.model.sources[1]
					game.begin_drag(next,2,game.source_cards[next].get_global_rect().get_center())
					expect(game.drag.pointer_owner==2 and game.drag_id==next and game.feedback_timer.is_stopped(),"Next shape can be picked up immediately, before speech or animation ends")
				else:
					var first: int=game.model.tray_order[0]
					game.begin_drag(first,1,game.source_cards[first].get_global_rect().get_center())
					game.drag.move(game.slots[first].get_global_rect().get_center());game.drag.release(game.slots[first].get_global_rect().get_center())
					var next: int=game.model.tray_order[1]
					game.begin_drag(next,2,game.source_cards[next].get_global_rect().get_center())
					expect(game.drag.pointer_owner==2 and game.drag_piece==next and game.feedback_timer.is_stopped(),"Next puzzle piece has no artificial feedback lock")
				GameManager.return_home();await frames()
		GameManager.start_game("letters");await frames()
		var letters: Variant=app.current_view
		letters.focus_paused=false
		expect(letters.alphabet==locale and letters.grid.get_child_count()==(26 if locale=="en" else 33),"Alphabet follows app language with all letters")
		expect(letters.find_child("Alphabet_uk",true,false)==null and letters.find_child("Alphabet_en",true,false)==null,"No second alphabet selector in the child screen")
		letters.choose_alphabet("uk" if locale=="en" else "en")
		expect(letters.alphabet==locale,"Foreign alphabet cannot override selected app language")
		for entry: Dictionary in LetterCatalog.load_data().alphabets[locale]:
			expect(AudioManager.local_voice_available(entry.word_key,locale) and AudioManager.local_voice_available(entry.example_key,locale),"Each letter and picture have separate local speech")
			expect(entry.example.substr(entry.highlight_index,1).to_lower()==entry.lower and ResourceLoader.exists(entry.illustration),"Every example highlights its actual letter and has an illustration")
			if entry.initial:expect(entry.highlight_index==0,"Initial-letter examples begin with the displayed letter")
			else:expect(locale=="uk" and entry.upper in ["И","Ь"],"Only explicitly marked Ukrainian inside-word examples are noninitial")
		letters.set_picture_mode(true);await frames()
		expect(letters.find_child("CardPicture",true,false)!=null and letters.find_child("CardLetter",true,false)!=null,"Picture tab pairs a large letter with a real image")
		letters.step(1);await frames();expect(letters.card_index==1,"Next arrow advances one card")
		var swipe_start: Vector2=letters.card_area.get_global_rect().get_center()+Vector2(90,0)
		for pressed: bool in [true,false]:
			var event := InputEventScreenTouch.new();event.index=4;event.pressed=pressed;event.position=swipe_start if pressed else swipe_start-Vector2(180,0);get_viewport().push_input(event,true)
		await frames();expect(letters.card_index==2,"Actual touch swipe advances exactly one picture")
		letters.set_overlay_paused(true);letters.step(1);expect(letters.card_index==2,"Paused alphabet cannot advance");letters.set_overlay_paused(false)
		letters.set_picture_mode(false);await frames();expect(letters.grid!=null and letters.card_index==2,"Switching tabs preserves the chosen card")
		GameManager.return_home();await frames()
		GameManager.start_game("syllables");await frames()
		var game: Variant=app.current_view;game.focus_paused=false
		expect(game.alphabet==locale and game.find_child("Alphabet_en",true,false)==null,"Word builder uses only the app language")
		var pool := WordCatalog.items(locale)
		expect(pool.size()>50,"Random word pool reuses broad existing picture vocabulary")
		var seen: Dictionary={}
		for word: Dictionary in pool:
			expect(not seen.has(word.text.to_lower()) and ResourceLoader.exists(word.illustration) and AudioManager.local_voice_available(word.word_key,locale),"Every unique word has an existing picture and local pronunciation")
			seen[word.text.to_lower()]=true
		expect(seen.has("метелик" if locale=="uk" else "butterfly") and seen.has("брова" if locale=="uk" else "eyebrow"),"Word pool includes coloring vocabulary and detailed body parts")
		var round_ids: Dictionary={}
		for round_number: int in range(5):
			expect(game.next_button.disabled and game.filled==0 and game.find_child("WordPicture",true,false)!=null,"A word starts empty alongside its picture")
			expect(not round_ids.has(game.target().id),"A five-word round has no duplicate targets");round_ids[game.target().id]=true
			var expected: Array=game.target().letters.duplicate();expected.sort();var actual: Array=game.choices.duplicate();actual.sort()
			expect(expected==actual,"Shuffled tiles retain all duplicate letter occurrences")
			var wrong := ""
			for choice: String in game.choices:
				if choice!=game.target().letters[0]:wrong=choice;break
			game.choose(wrong);expect(game.filled==0,"Wrong letter cannot fill a slot")
			game.set_overlay_paused(true);game.choose(game.target().letters[0]);expect(game.filled==0,"Paused word input is ignored");game.set_overlay_paused(false)
			for glyph: String in game.target().letters:game.choose(glyph)
			expect(game.filled==game.target().letters.size() and game.used.size()==game.filled and not game.next_button.disabled,"Every letter including repeats is consumed once to complete a real word")
			var saved_count: int=game.filled;game.choose_tile(game.used[0]);expect(game.filled==saved_count,"Used tile cannot be consumed again")
			game.advance();await frames()
		expect(game.state==game.State.COMPLETE and game.has_node("CompletionParty"),"Five completed pictured words earn the common party")
		GameManager.return_home();await frames()
		GameManager.start_game("balloons");await frames()
		var free: Variant=app.current_view
		free.focus_paused=false
		var generation: int=free.generation
		free.set_overlay_paused(true);free.pop(0)
		expect(free.popped==0,"Paused free play cannot pop")
		free.set_overlay_paused(false)
		for i: int in range(12): free.pop(i);free.pop(i)
		expect(free.popped==12,"Repeated touches pop each balloon only once")
		free._process(1.0)
		expect(not free.balloons[0].popped and free.balloons[0].position.y>free.area.size.y,"Popped balloons independently respawn below the field")
		var before: float=free.flights[0].y
		free._process(0.5)
		expect(free.flights[0].y<before,"Balloons travel upward")
		before=free.flights[0].y
		free.set_overlay_paused(true);free._process(1.0)
		expect(free.flights[0].y==before,"Pause freezes flight")
		free.set_overlay_paused(false)
		free.flights[0].y=-500.0;free._process(0.1)
		expect(free.flights[0].y>free.area.size.y,"Missed balloons recycle below the field")
		free.new_set()
		expect(free.generation==generation+1 and free.balloons.size()==12 and free.popped==0,"Free play reuses twelve nodes instead of growing objects")
		expect(not ProgressManager.document.games.has("balloons"),"Free balloons have no fake learning score")
		GameManager.return_home();await frames()
	app.queue_free();await frames();await AudioManager.shutdown()
	print("FEEDBACK TESTS: %d checks, %d failures" % [checks,failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

