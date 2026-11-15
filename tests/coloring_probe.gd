extends Node

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[1].begins_with("user://test-runs/coloring-probe-") or ".." in args[1]:
		get_tree().quit(1)
		return
	SettingsManager.storage_path = args[1] + "/settings.json"
	SettingsManager.reload()
	SettingsManager.set_value("music_enabled",false)
	AudioManager.apply_settings()
	await get_tree().create_timer(0.2).timeout
	ArtworkManager.directory = args[1]
	ArtworkManager.reload()
	var doc := ColoringDocument.new("fox")
	doc.fill_at(doc.page.regions[0].tap,PaintDocument.COLORS[0])
	doc.fill_at(doc.page.regions[1].tap,PaintDocument.COLORS[4])
	var valid := false
	if args[0] == "write":
		valid = not ArtworkManager.save_artwork(doc.render_image(),doc.state()).is_empty() and ArtworkManager.save_color_draft({"version":1,"last_page":"fox","pages":{"fox":doc.state()}})
	elif args[0] == "read" and ArtworkManager.entries.size() == 1:
		var restored := ColoringDocument.new()
		var id: String = ArtworkManager.entries[0].id
		valid = restored.restore(ArtworkManager.coloring_state(id))
		valid = valid and restored.colors == doc.colors and restored.render_image().get_data() == ArtworkManager.load_artwork(id).get_data()
		var draft := ColoringDocument.new()
		valid = valid and draft.restore(ArtworkManager.load_color_draft().pages.fox) and draft.colors == doc.colors
	print("COLORING PERSISTENCE %s: %s" % [args[0].to_upper(),"PASS" if valid else "FAIL"])
	await AudioManager.shutdown()
	get_tree().quit(0 if valid else 1)
