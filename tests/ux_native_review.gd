extends Node
var app: Variant
func _ready() -> void:
	get_window().title="Little Wonder World - UX Review"
	var fixture := "user://test-runs/ux-native-"+str(Time.get_ticks_usec())
	SettingsManager.storage_path=fixture+"/settings.json"
	ProgressManager.storage_path=fixture+"/progress.json"
	ArtworkManager.directory=fixture+"/artwork"
	SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload()
	SettingsManager.set_value("locale","uk")
	SettingsManager.set_value("music_enabled",false)
	app=preload("res://scenes/core/app_root.tscn").instantiate()
	add_child(app)
	GameManager.navigate("activities")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("REVIEW MOUSE device=%d down=%s point=%s route=%s" % [event.device,event.pressed,event.position,GameManager.current_route])
