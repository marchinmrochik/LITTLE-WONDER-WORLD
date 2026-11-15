extends Node
func _ready() -> void:
 get_window().title="Little Wonder World 0.26 - Play improvements"
 var fixture := "user://test-runs/play-review-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json";BalloonRecords.storage_path=fixture+"/balloons.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("locale","uk");SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("difficulty","normal")
 var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);GameManager.navigate("activities")
