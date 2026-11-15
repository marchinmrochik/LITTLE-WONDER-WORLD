extends Node
func _ready() -> void:call_deferred("run")
func run() -> void:
	get_window().title="Little Wonder World - PNG export review"
	var fixture := "user://test-runs/export-native-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("locale","en")
	var reference := ColoringDocument.reference_image("fox")
	var id := ArtworkManager.save_artwork(reference)
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	GameManager.parents_unlocked=true;GameManager.navigate("gallery")
	await get_tree().create_timer(1.0).timeout
	app.current_view.request_export(id)
	print("EXPORT DIALOG: ",app.current_view.export_dialog.visible," ",app.current_view.export_dialog.current_dir," ",DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE))
