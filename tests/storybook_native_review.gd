extends Node
func _ready() -> void:call_deferred("run")
func run() -> void:
 get_window().title="Little Wonder World 0.27 - Storybook and Draw a word"
 var fixture := "user://test-runs/storybook-review-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json";BalloonRecords.storage_path=fixture+"/balloons.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("locale","uk");SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("difficulty","normal")
 var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
 GameManager.living_story="autumn";GameManager.start_game("living_drawing")
 var game: Variant=app.current_view
 for i: int in range(game.parts.size()):game.completed[i]=true
 game.state=game.State.PLAY;game.update_labels();AudioManager.stop_voice()
