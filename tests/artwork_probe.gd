extends Node

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[1].begins_with("user://test-runs/artwork-probe-") or ".." in args[1]:
		get_tree().quit(1)
		return
	# This probe exercises storage only, with its own settings and no music.
	SettingsManager.storage_path = args[1] + "/settings.json"
	SettingsManager.reload()
	SettingsManager.set_value("music_enabled", false)
	AudioManager.apply_settings()
	await get_tree().create_timer(0.2).timeout
	ArtworkManager.directory = args[1]
	ArtworkManager.reload()
	var paint := PaintDocument.new()
	paint.begin(Vector2(80, 100))
	paint.move(Vector2(940, 100))
	paint.finish()
	var success := false
	if args[0] == "write":
		success = not ArtworkManager.save_artwork(paint.image).is_empty() and ArtworkManager.save_draft(paint.image)
	elif args[0] == "read" and ArtworkManager.entries.size() == 1:
		var saved := ArtworkManager.load_artwork(ArtworkManager.entries[0].id)
		var draft := ArtworkManager.load_draft()
		success = saved != null and draft != null and saved.get_data() == paint.image.get_data() and draft.get_data() == paint.image.get_data()
	print("ARTWORK PERSISTENCE %s: %s" % [args[0].to_upper(), "PASS" if success else "FAIL"])
	await AudioManager.shutdown()
	get_tree().quit(0 if success else 1)
