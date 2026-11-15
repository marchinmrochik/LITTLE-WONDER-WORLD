extends Node

var checks := 0
var failures: PackedStringArray = []

func _ready() -> void:
	get_tree().create_timer(90).timeout.connect(func() -> void:
		push_error("Drawing test timeout")
		get_tree().quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var root := "user://test-runs/drawing-" + str(Time.get_ticks_usec())
	SettingsManager.storage_path = root + "/settings.json"
	ProgressManager.storage_path = root + "/progress.json"
	SettingsManager.reload()
	ProgressManager.reload()
	SettingsManager.set_value("music_enabled", false)
	SettingsManager.set_value("reduced_motion", true)
	var paint := PaintDocument.new()
	_expect(paint.is_blank() and PaintDocument.COLORS.size() >= 8, "White page and at least eight colors")
	_expect(not paint.begin(Vector2(-1, 0)), "Stroke cannot start outside image")
	paint.radius = 4
	paint.begin(Vector2(20, 100))
	paint.move(Vector2(1000, 100))
	paint.finish()
	for x: int in range(20, 1001, 3):
		_expect(paint.image.get_pixel(x, 100) != Color.WHITE, "Sparse input still produces a continuous line")
	var painted := paint.image.get_data()
	_expect(paint.undo() and paint.is_blank(), "Undo restores original pixels")
	_expect(paint.redo() and paint.image.get_data() == painted, "Redo restores exact pixels")
	paint.tool = "eraser"
	paint.radius = 20
	paint.begin(Vector2(500, 100))
	paint.finish()
	_expect(paint.image.get_pixel(500, 100) == Color.WHITE and paint.image.get_pixel(400, 100) != Color.WHITE, "Eraser changes only its region")
	paint.undo()
	_expect(paint.image.get_data() == painted, "Erase can be undone exactly")
	paint.tool = "soft"
	paint.radius = 20
	paint.begin(Vector2(200, 250))
	paint.finish()
	_expect(paint.image.get_pixel(200, 250) != Color.WHITE and paint.image.get_pixel(219, 250).is_equal_approx(Color.WHITE), "Soft brush fades at its edge")
	paint.tool = "rainbow"
	paint.begin(Vector2(30, 350))
	paint.move(Vector2(950, 350))
	paint.finish()
	_expect(not paint.image.get_pixel(50, 350).is_equal_approx(paint.image.get_pixel(250, 350)), "Rainbow changes color through a stroke")
	paint.begin(Vector2(900, 620))
	paint.move(Vector2(1e20, -1e20))
	paint.move(Vector2(20, 20))
	paint.finish()
	_expect(paint.history_bytes <= paint.byte_limit and paint.stamps.size() <= 64, "Clipping and brush cache remain bounded")
	var snapshot := paint.image.get_data()
	paint.begin(Vector2(50, 500))
	paint.move(Vector2(950, 500))
	paint.finish(false)
	_expect(paint.image.get_data() == snapshot, "Canceled transaction restores exact prior image")
	paint.clear()
	_expect(paint.is_blank() and paint.undo() and paint.image.get_data() == snapshot, "Guarded clear is undoable")
	paint.history_limit = 3
	paint.byte_limit = 32768
	paint.tool = "regular"
	paint.radius = 4
	for i: int in range(12):
		paint.begin(Vector2(30 + i * 25, 500))
		paint.finish()
	_expect(paint.history.size() <= 3 and paint.history_bytes <= 32768, "History obeys count and byte budgets")
	paint.undo()
	paint.begin(Vector2(500, 550))
	paint.finish()
	_expect(not paint.redo(), "New stroke invalidates redo branch")
	ArtworkManager.directory = root + "/art"
	ArtworkManager.reload()
	var id := ArtworkManager.save_artwork(paint.image)
	_expect(not id.is_empty(), "PNG and versioned gallery index save")
	ArtworkManager.reload()
	var reopened := ArtworkManager.load_artwork(id)
	_expect(reopened != null and reopened.get_data() == paint.image.get_data(), "Saved gallery pixels survive reload")
	var edited := PaintDocument.new()
	edited.load_image(reopened)
	edited.tool = "eraser"
	edited.radius = 20
	edited.begin(Vector2(50, 100))
	edited.finish()
	_expect(edited.image.get_pixel(50, 100) == Color.WHITE, "Reopened raster artwork remains editable")
	_expect(ArtworkManager.load_artwork("../draft") == null and not ArtworkManager.remove_artwork("../../1_2"), "Gallery IDs cannot escape storage")
	ArtworkManager.save_draft(paint.image)
	ArtworkManager.save_draft(edited.image)
	var broken_draft := FileAccess.open(ArtworkManager.directory + "/draft.png", FileAccess.WRITE)
	broken_draft.store_string("broken")
	broken_draft.close()
	_expect(ArtworkManager.load_draft().get_data() == paint.image.get_data(), "Damaged draft falls back to valid previous pixels")
	var bad_png := paint.image.save_png_to_buffer()
	bad_png[16] = 127
	var broken_file := FileAccess.open(ArtworkManager.directory + "/bad.png", FileAccess.WRITE)
	broken_file.store_buffer(bad_png)
	broken_file.close()
	_expect(ArtworkManager._read_png(ArtworkManager.directory + "/bad.png") == null, "PNG dimensions bounded before decode")
	for i: int in range(ArtworkManager.MAX_ENTRIES - 1):
		_expect(not ArtworkManager.save_artwork(paint.image).is_empty(), "Gallery within its capacity saves")
	_expect(ArtworkManager.save_artwork(paint.image).is_empty() and ArtworkManager.entries.size() == ArtworkManager.MAX_ENTRIES, "Gallery cap never evicts earlier pictures")
	_expect(ArtworkManager.remove_artwork(id) and ArtworkManager.load_artwork(id) == null, "Adult-confirmed deletion removes only selected saved copy")
	ArtworkManager.directory = root + "/quota"
	ArtworkManager.reload()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ArtworkManager.directory + "/gallery"))
	var quota_file := FileAccess.open(ArtworkManager.directory + "/gallery/quota.png", FileAccess.WRITE)
	quota_file.seek(ArtworkManager.MAX_GALLERY_BYTES)
	quota_file.store_8(0)
	quota_file.close()
	_expect(ArtworkManager.save_artwork(paint.image).is_empty(), "Byte quota counts even unindexed PNG storage")
	DirAccess.remove_absolute(ArtworkManager.directory + "/gallery/quota.png")
	var orphan := ArtworkManager.save_artwork(paint.image)
	var index := FileAccess.open(ArtworkManager.directory + "/index.json", FileAccess.WRITE)
	index.store_string('{"version":1,"entries":[]}')
	index.close()
	ArtworkManager.reload()
	_expect(ArtworkManager.load_artwork(orphan) != null and ArtworkManager.status == "recovered", "Interrupted index publication can recover orphan art")
	index = FileAccess.open(ArtworkManager.directory + "/index.json", FileAccess.WRITE)
	index.store_string('{"version":99,"entries":[]}')
	index.close()
	ArtworkManager.reload()
	_expect(ArtworkManager.save_artwork(paint.image).is_empty() and not ArtworkManager.save_draft(paint.image), "Future metadata blocks writes")
	_expect(FileAccess.get_file_as_string(ArtworkManager.directory + "/index.json").contains("99"), "Future metadata preserved byte content")
	ArtworkManager.directory = root + "/ui"
	ArtworkManager.reload()
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	await _frames()
	for locale: String in ["en", "uk"]:
		SettingsManager.set_value("locale", locale)
		GameManager.navigate("activities")
		await _frames()
		app.current_view.ensure_activity("drawing")
		await _frames()
		_expect(app.current_view.find_child("DrawingButton", true, false) != null, "Drawing card reachable on actual second menu page")
		app.current_view.find_child("DrawingButton", true, false).pressed.emit()
		await _frames()
		var game: Variant = app.current_view
		game.focus_paused = false
		game._update_pause()
		await _stroke(game.canvas, Vector2(50, 150), Vector2(900, 150))
		_expect(game.canvas.document.image.get_pixel(500, 150) != Color.WHITE, "Viewport touch uses fitted canvas coordinates")
		var before_undo: PackedByteArray = game.canvas.document.image.get_data()
		game.find_child("Undo", true, false).pressed.emit()
		game.find_child("Redo", true, false).pressed.emit()
		_expect(game.canvas.document.image.get_data() == before_undo, "Actual Undo/Redo controls preserve pixel content")
		game.find_child("ClearDrawing", true, false).pressed.emit()
		_expect(app.modal != null and game.canvas.document.image.get_data() == before_undo, "Clear requires a separate confirmation")
		app.close_modal()
		_expect(game.canvas.document.image.get_data() == before_undo, "Cancel clear leaves picture unchanged")
		game.request_clear()
		_confirm(app, "DRAW_CLEAR_CONFIRM")
		_expect(game.canvas.document.is_blank(), "Confirmed clear removes current pixels")
		game.undo()
		_expect(game.canvas.document.image.get_data() == before_undo, "Undo restores confirmed clear")
		game.save_picture()
		var saved_count: int = ArtworkManager.entries.size()
		game.save_picture()
		_expect(ArtworkManager.entries.size() == saved_count, "Rapid Save does not create duplicate identical copies")
		game.show_gallery()
		_expect(game.canvas.paused and game.gallery != null, "Child gallery pauses input and shows saved art")
		_expect(game.gallery.find_child("Delete_*", true, false) == null, "Child gallery does not expose deletion")
		var reopen_id: String = ArtworkManager.entries.back().id
		game.gallery.find_child("Open_" + reopen_id, true, false).pressed.emit()
		_expect(game.gallery == null and game.canvas.document.image.get_data() == ArtworkManager.load_artwork(reopen_id).get_data(), "Gallery Open restores the actual editable pixels")
		game.select_tool("eraser")
		await _stroke(game.canvas, Vector2(500, 150), Vector2(520, 150))
		_expect(game.canvas.document.image.get_pixel(510, 150) == Color.WHITE, "Eraser edits a reopened drawing through touch")
		_expect(ArtworkManager.load_artwork(reopen_id).get_data() == before_undo, "Editing never silently overwrites saved original")
		game.show_gallery()
		game.request_open(reopen_id)
		_expect(app.modal != null, "Replacing unsaved current edits needs confirmation")
		app.close_modal()
		_expect(game.handle_back() and game.gallery == null, "Back closes gallery before leaving drawing")
		game.select_tool("regular")
		game.select_color(4)
		var rect: Rect2 = game.canvas.image_rect()
		var down := InputEventScreenTouch.new()
		down.index = 0
		down.position = game.canvas.global_position + rect.position + Vector2(100, 300) / Vector2(PaintDocument.SIZE) * rect.size
		down.pressed = true
		get_viewport().push_input(down, true)
		var motion := InputEventScreenDrag.new()
		motion.index = 0
		motion.position = game.canvas.global_position + rect.position + Vector2(900, 300) / Vector2(PaintDocument.SIZE) * rect.size
		get_viewport().push_input(motion, true)
		game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_expect(game.canvas.pointer_owner == -2 and not game.canvas.document.active, "Focus loss terminates the active stroke")
		_expect(ArtworkManager.load_draft().get_pixel(500, 300) != Color.WHITE, "Interrupted visible stroke is preserved in the draft")
		game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		game.flush_draft()
		GameManager.return_home()
		await _frames()
		_expect(not GameManager.navigate("gallery"), "Parent gallery cannot be entered while locked")
		GameManager.parents_unlocked = true
		GameManager.navigate("settings")
		GameManager.navigate("gallery")
		await _frames()
		_expect(app.current_view.gallery.allow_delete, "Adult gallery has guarded delete controls")
		var saved_id: String = ArtworkManager.entries.back().id
		app.current_view.gallery.delete_requested.emit(saved_id)
		_expect(app.modal != null and ArtworkManager.load_artwork(saved_id) != null, "Delete asks before changing stored art")
		app.close_modal()
		GameManager.return_home()
		await _frames()
	_expect(not ProgressManager.document.games.has("drawing"), "Free drawing does not fabricate correct-answer scores")
	app.queue_free()
	await _frames()
	await AudioManager.shutdown()
	print("DRAWING TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure: String in failures:
		print("FAIL: " + failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func _confirm(app: Variant, key: String) -> void:
	for button: Node in app.modal.find_children("*", "Button", true, false):
		if button.text == LocalizationManager.text(key):
			button.pressed.emit()
			return
	_expect(false, "Confirmation action exists")

func _stroke(canvas: PaintCanvas, start: Vector2, end: Vector2) -> void:
	var rect := canvas.image_rect()
	var first := canvas.global_position + rect.position + start / Vector2(PaintDocument.SIZE) * rect.size
	var last := canvas.global_position + rect.position + end / Vector2(PaintDocument.SIZE) * rect.size
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.position = first
	down.pressed = true
	get_viewport().push_input(down, true)
	var other := InputEventScreenTouch.new()
	other.index = 1
	other.position = last
	get_viewport().push_input(other, true)
	_expect(canvas.pointer_owner == 0, "Unrelated finger cannot release active drawing")
	var move := InputEventScreenDrag.new()
	move.index = 0
	move.position = last
	get_viewport().push_input(move, true)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.position = last
	get_viewport().push_input(up, true)
	await _frames()

func _frames() -> void:
	for i: int in range(5):
		await get_tree().process_frame

func _expect(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures.append(description)
