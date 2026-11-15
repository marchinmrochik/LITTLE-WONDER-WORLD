extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/drawing-rails"
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
 var fixture := "user://test-runs/drawing-rails-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
 for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768),Vector2i(1152,664)]:
  get_window().size=resolution
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);GameManager.return_home();await frames();GameManager.start_game("drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false;game._update_pause()
   var suffix := "%s_%dx%d"%[locale,resolution.x,resolution.y]
   var paper: Rect2=game.canvas.image_rect();paper.position+=game.canvas.global_position
   if not get_viewport().get_visible_rect().grow(-20).encloses(paper):issues.append("Paper outside viewport "+suffix)
   if paper.position.y<app.header.get_global_rect().end.y+30:issues.append("No breathing room above paper "+suffix)
   var palette_box: Rect2=game.palette.get_global_rect()
   if palette_box.position.x<paper.end.x:issues.append("Palette is not beside paper "+suffix)
   await capture("drawing_"+suffix)
   game.palette.open_picker();await capture("palette_"+suffix);app.close_modal()
   print("PAPER ",suffix," ",paper)
   GameManager.return_home();await frames()
 app.queue_free();await frames();await AudioManager.shutdown();print("DRAWING RAIL RENDER: %d screenshots, %d issues"%[captures,issues.size()])
 for issue: String in issues:print("LAYOUT: "+issue)
 get_tree().quit(0 if issues.is_empty() else 1)
