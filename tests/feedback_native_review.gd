extends Node
func _ready() -> void:call_deferred("_run")
func _run() -> void:
	get_window().title="Little Wonder World - New Activities"
	var fixture := "user://test-runs/feedback-native-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("locale","uk");SettingsManager.set_value("music_enabled",false)
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	GameManager.navigate("activities")
	for i: int in range(5):await get_tree().process_frame
	app.current_view.ensure_activity("letters")
