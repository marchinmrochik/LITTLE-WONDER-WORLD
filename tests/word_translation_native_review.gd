extends Node
func _ready() -> void:call_deferred("_run")
func _run() -> void:
	get_window().title="Little Wonder World - 0.25 - Ukrainian Word Translations"
	var fixture := "user://test-runs/translations-native-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
	SettingsManager.set_value("locale","en");SettingsManager.set_value("english_ukrainian_translation",true);SettingsManager.set_value("music_enabled",false)
	var app := preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	GameManager.start_game("animals")
	await get_tree().process_frame
	app.current_view._explore_animal("cat")
