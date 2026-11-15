extends Node
func _ready() -> void:call_deferred("run")
func run() -> void:
	get_window().title="Little Wonder World 0.30 - Body exploration"
	get_window().size=Vector2i(1280,800)
	var fixture := "user://test-runs/desktop030-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json";BalloonRecords.storage_path=fixture+"/balloons.json"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("locale","uk")
	var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
	GameManager.world_topic="body";GameManager.navigate("world_topic")
	app.current_view.selected="belly";app.current_view.show_explore()
