extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	get_tree().create_timer(75).timeout.connect(func() -> void:
		push_error("Coloring test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var root := "user://test-runs/coloring-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = root + "/settings.json"
	ProgressManager.storage_path = root + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("reduced_motion", true)
	ArtworkManager.directory = root + "/model"
	ArtworkManager.reload()
	_expect(ColoringDocument.catalog().size() == 10, "Ten requested coloring pages")
	var expected := ["cat","dog","fox","butterfly","fish","house","flower","car","dinosaur","rainbow"]
	for page: Dictionary in ColoringDocument.catalog():
		_expect(page.id in expected and ResourceLoader.exists(page.preview), "Requested original preview available")
		_expect(page.regions.size() >= 4 and page.regions.size() <= 64, "Large finite region set")
		var doc := ColoringDocument.new(page.id)
		var region_ids := {}
		for region: Dictionary in page.regions:
			region_ids[region.id] = true
		_expect(region_ids.size() == page.regions.size(), "Region IDs are unique within each picture")
		_expect(ColoringDocument.valid_state(doc.state()) and doc.is_blank(), "Initial editable state validates")
		_expect(not doc.fill_at(Vector2(5, 5), Color.RED), "Background is not a global fill region")
		for region: Dictionary in page.regions:
			var hit := doc.region_at(region.tap)
			_expect(hit == region.id, "Visible tap anchor: %s:%s (got %s)" % [page.id, region.id, hit])
			if hit != region.id:
				continue
			var before := doc.colors.duplicate()
			_expect(doc.fill_at(region.tap, PaintDocument.COLORS[0]), "Region fills from a tap")
			var changes := 0
			for id: String in doc.colors:
				changes += int(doc.colors[id] != before[id])
			_expect(changes == 1 and doc.colors[region.id] != "ffffff", "Only the selected region changes")
			var rendered := doc.render_image()
			_expect(rendered != null and rendered.get_pixelv(Vector2i(region.tap)).is_equal_approx(PaintDocument.COLORS[0]), "Rendered region pixels use selected color: " + page.id + ":" + region.id)
			for neighbor: Dictionary in page.regions:
				if neighbor.id != region.id:
					_expect(rendered.get_pixelv(Vector2i(neighbor.tap)) == Color.WHITE, "Neighboring region pixels remain unchanged: " + page.id + ":" + neighbor.id)
			_expect(rendered.get_pixel(5, 5) == Color.WHITE, "Outside picture remains white")
			_expect(not doc.fill_at(region.tap, PaintDocument.COLORS[0]), "Repeated same-color event adds no history")
			_expect(doc.undo() and doc.colors == before, "Undo restores exact region values")
			_expect(doc.redo() and doc.colors[region.id] != "ffffff", "Redo restores region color")
			doc.reset()
		var first: Dictionary = page.regions[0]
		doc.fill_at(first.tap, PaintDocument.COLORS[1])
		var saved := doc.state()
		var saved_id := ArtworkManager.save_artwork(doc.render_image(), saved)
		_expect(not saved_id.is_empty() and ArtworkManager.artwork_route(saved_id) == "coloring", "Coloring metadata and PNG published together")
		var restored := ColoringDocument.new()
		_expect(restored.restore(ArtworkManager.coloring_state(saved_id)), "Saved region state reopens")
		_expect(restored.colors == doc.colors and restored.render_image().get_data() == ArtworkManager.load_artwork(saved_id).get_data(), "Reopened PNG and editable region state agree")
		restored.fill_at(first.tap, PaintDocument.COLORS[2])
		_expect(ArtworkManager.coloring_state(saved_id) == saved, "Editing never mutates saved metadata")
		var invalid := saved.duplicate(true)
		invalid.colors["unknown"] = "ff0000"
		_expect(not ColoringDocument.valid_state(invalid), "Unknown region IDs rejected")
		invalid = saved.duplicate(true)
		invalid.colors[first.id] = "invalid"
		_expect(not ColoringDocument.valid_state(invalid), "Invalid fill tokens cannot enter SVG")
		_expect(doc.reset() and doc.undo() and doc.colors == saved.colors, "Reset is undoable")
	var history_doc := ColoringDocument.new()
	var tap: Vector2 = history_doc.page.regions[0].tap
	for i: int in range(100):
		history_doc.fill_at(tap, PaintDocument.COLORS[i % PaintDocument.COLORS.size()])
	_expect(history_doc.history.size() <= ColoringDocument.HISTORY_LIMIT, "Undo history bounded without image snapshots")
	history_doc.undo()
	history_doc.fill_at(tap, Color.WHITE)
	_expect(not history_doc.redo(), "New fill replaces redo branch")
	var raster := PaintDocument.new()
	raster.begin(Vector2(100, 100))
	raster.finish()
	var raster_id := ArtworkManager.save_artwork(raster.image)
	_expect(ArtworkManager.artwork_route(raster_id) == "drawing", "Legacy drawing saves retain their original route")
	var source_pixels := ArtworkManager.load_artwork(raster_id).get_data()
	var book_id: String = ArtworkManager.entries[0].id
	_expect(ArtworkManager.remove_artwork(book_id) and ArtworkManager.load_artwork(raster_id).get_data() == source_pixels, "Deleting one coloring does not affect old drawings")
	var states := {}
	for page: Dictionary in ColoringDocument.catalog():
		states[page.id] = ColoringDocument.new(page.id).state()
	states.cat = history_doc.state()
	_expect(ArtworkManager.save_color_draft({"version":1,"last_page":"cat","pages":states}), "All page drafts save within bounded JSON")
	var draft_doc := ColoringDocument.new()
	draft_doc.restore(ArtworkManager.load_color_draft().pages.cat)
	_expect(draft_doc.colors == history_doc.colors, "Editable draft reloads region values")
	var future := FileAccess.open(ArtworkManager.directory + "/coloring-draft.json", FileAccess.WRITE)
	future.store_string('{"version":99,"pages":{}}')
	future.close()
	_expect(not ArtworkManager.save_color_draft({"version":1,"last_page":"cat","pages":states}), "Future coloring draft cannot be overwritten")
	_expect(FileAccess.get_file_as_string(ArtworkManager.directory + "/coloring-draft.json") == '{"version":99,"pages":{}}', "Future draft bytes preserved")
	ArtworkManager.directory = root + "/ui"
	ArtworkManager.reload()
	raster_id = ArtworkManager.save_artwork(raster.image)
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en","uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		app.current_view.ensure_activity("coloring")
		await _frames()
		app.current_view.find_child("ColoringButton", true, false).pressed.emit()
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		game._update_pause()
		game.page_index = 0
		game._show_page()
		for i: int in range(game.book_pages.size()):
			var doc: ColoringDocument = game.document()
			var region: Dictionary = doc.page.regions[0]
			game.select_color(PaintDocument.COLORS[i % 9])
			var before := doc.colors.duplicate()
			await _tap(game.canvas, region.tap)
			_expect(doc.colors[region.id] == PaintDocument.COLORS[i % 9].to_html(false), "Scaled touch fills selected region under either UI locale")
			_expect(game.title.text == LocalizationManager.object_name(doc.page), "Page name stays English")
			game.repeat_word()
			_expect(AudioManager.voice.stream.resource_path == ContentManager.voice_path(doc.page.word_key, locale), "English page name available offline")
			if i == 0:
				game.undo()
				game.redo()
				var filled := doc.colors.duplicate()
				game.request_reset()
				_expect(app.modal != null and doc.colors == filled, "Reset asks before removing colors")
				app.close_modal()
				game.request_reset()
				_confirm(app, "BOOK_RESET_CONFIRM")
				_expect(doc.is_blank(), "Confirmed reset restores original line art")
				game.undo()
				_expect(doc.colors == filled, "Reset can be undone through UI")
			if i < game.book_pages.size()-1:
				game.find_child("NextPicture", true, false).pressed.emit()
		_expect(game.next.disabled and game.page_index == 8, "All nine available pages reachable with final boundary")
		game.save_picture()
		var count: int = ArtworkManager.entries.size()
		game.save_picture()
		_expect(ArtworkManager.entries.size() == count, "Repeated save creates no duplicate copy")
		var saved_id: String = ArtworkManager.entries.back().id
		var saved_state := ArtworkManager.coloring_state(saved_id)
		game.show_gallery()
		_expect(game.canvas.paused and game.gallery.find_child("Delete_*", true, false) == null, "Child gallery is read/open only")
		game.gallery.find_child("Open_" + saved_id, true, false).pressed.emit()
		_expect(game.gallery == null and game.document().state() == saved_state, "Saved coloring reopens with region editability")
		game.select_color(PaintDocument.COLORS[4])
		var region: Dictionary = game.document().page.regions[0]
		await _tap(game.canvas, region.tap)
		_expect(ArtworkManager.coloring_state(saved_id) == saved_state, "Continued coloring preserves original saved copy")
		game.show_gallery()
		game.request_open(saved_id)
		_expect(app.modal != null, "Replacing unpublished page colors is protected")
		app.close_modal()
		_expect(game.handle_back() and game.gallery == null, "Back closes gallery before navigating away")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.canvas.paused and ArtworkManager.load_color_draft().last_page == "rainbow", "Focus loss flushes current editable page")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		game.show_gallery()
		game.gallery.find_child("Open_" + raster_id, true, false).pressed.emit()
		await _frames()
		_expect(GameManager.current_route == "drawing", "Old PNG gallery entry opens original drawing activity")
		if app.modal != null:
			_confirm(app, "DRAW_OPEN")
		app.current_view.show_gallery()
		app.current_view.gallery.find_child("Open_" + saved_id, true, false).pressed.emit()
		await _frames()
		_expect(GameManager.current_route == "coloring", "Drawing gallery routes region-aware saves back to coloring")
		if app.modal != null:
			_confirm(app, "DRAW_OPEN")
		GameManager.return_home()
		await _frames()
	_expect(not ProgressManager.document.games.has("coloring"), "Coloring does not fabricate correct-answer scores")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("COLORING TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _tap(canvas: ColoringCanvas, point: Vector2) -> void:
	var rect := canvas.image_rect()
	var position := canvas.global_position + rect.position + (point-canvas.source_bounds.position) / canvas.source_bounds.size * rect.size
	for pressed: bool in [true,false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = position
		event.pressed = pressed
		get_viewport().push_input(event, true)
	await _frames()

func _confirm(app: Variant, key: String) -> void:
	for button: Node in app.modal.find_children("*", "Button", true, false):
		if button.text == LocalizationManager.text(key):
			button.pressed.emit()
			return
	_expect(false, "Confirmation exists")

func _frames() -> void:
	for i: int in range(5):
		await get_tree().process_frame

func _expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
