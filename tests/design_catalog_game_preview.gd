extends Node
func _ready() -> void:call_deferred("run")
func run() -> void:
 get_window().title="Little Wonder World - Design Preview"
 var request: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://.local/design-catalog/preview-request.json"))
 var fixture := "user://test-runs/design-preview-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("locale",request.get("locale","uk"));SettingsManager.set_value("music_enabled",false)
 var app := preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
 var route: String=request.get("route","animals")
 if route=="world":GameManager.navigate("world")
 elif GameManager.games.has(route):
  GameManager.living_story=request.get("story","house");GameManager.start_game(route)
  if route=="living_drawing":
   for i: int in range(app.current_view.parts.size()):app.current_view.completed[i]=true
   app.current_view.state=app.current_view.State.PLAY;app.current_view.update_labels()
