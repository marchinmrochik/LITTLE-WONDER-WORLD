extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/seasons"
func _ready() -> void:call_deferred("_run")
func frames() -> void:
 for i: int in range(5):await get_tree().process_frame
func capture(label: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 if get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(output+"/"+label+".png"))!=OK:issues.append("Capture failed: "+label)
 check(app,label,false);captures+=1
func check(node: Node,label: String,scrolling: bool) -> void:
 if node is ScrollContainer:scrolling=true
 if node is BaseButton and node.is_visible_in_tree() and not scrolling:
  if not get_viewport().get_visible_rect().grow(1).encloses(node.get_global_rect()):issues.append(label+":"+str(node.name))
 for child: Node in node.get_children():check(child,label,scrolling)
func _run() -> void:
 get_window().title="Little Wonder World - Seasons QA"
 var fixture := "user://test-runs/seasons-render-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload()
 SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app)
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
 for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
  get_window().size=resolution
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);GameManager.return_home();await frames()
   var suffix := "%s_%dx%d"%[locale,resolution.x,resolution.y]
   GameManager.navigate("activities");await capture("categories_"+suffix)
   GameManager.navigate("living_gallery");await capture("gallery_"+suffix)
   var gallery: Variant=app.current_view
   for card_name: String in ["HouseStory","SpringStory","AutumnStory","WinterStory"]:
    var card := gallery.find_child(card_name,true,false) as Control
    if not gallery.scroll.get_global_rect().encloses(card.get_global_rect()):issues.append("Gallery card outside visible scroll: "+suffix+card_name)
   for story: String in ["spring","autumn","winter"]:
    GameManager.living_story=story;GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false;game.restart()
    await capture(story+"_start_"+suffix)
    game.zoom_part();await get_tree().create_timer(.13).timeout;await capture(story+"_trace_"+suffix)
    game.restart()
    for i: int in range(game.parts.size()):game.completed[i]=true
    game.state=game.State.PLAY;game.update_labels();await capture(story+"_day_"+suffix)
    game.board.play_object("cloud");game.board.play_object("tree" if story!="winter" else "snowman");await get_tree().create_timer(.3).timeout;await capture(story+"_weather_"+suffix)
    game.board.play_object("moon" if story=="winter" else "sun");await capture(story+"_night_"+suffix)
    GameManager.navigate("living_gallery");await frames()
 app.queue_free();await frames();await AudioManager.shutdown();print("SEASONAL RENDER: %d screenshots, %d issues"%[captures,issues.size()])
 for issue: String in issues:print("LAYOUT: "+issue)
 get_tree().quit(0 if issues.is_empty() else 1)
