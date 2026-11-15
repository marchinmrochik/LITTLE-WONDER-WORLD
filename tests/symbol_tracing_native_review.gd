extends Node
func _ready() -> void:call_deferred("_run")
func _run() -> void:
	get_window().title="Little Wonder World - 0.23 - Letters and Numbers"
	var fixture := "user://test-runs/symbols-native-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("locale","uk");SettingsManager.set_value("music_enabled",false)
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	GameManager.start_game("letters")
	await get_tree().process_frame
	app.current_view.set_tracing_mode()
