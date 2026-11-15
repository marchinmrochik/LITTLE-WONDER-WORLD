extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/symbols"
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
 var fixture := "user://test-runs/symbols-render-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);app.idle_guide.reset();DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output));await frames()
 for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
  get_window().size=resolution
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);GameManager.return_home();await frames();GameManager.start_game("letters");await frames();var game: Variant=app.current_view;game.focus_paused=false;game.set_tracing_mode();await frames();var lesson: Variant=game.tracing;lesson.focus_paused=false
   var suffix := "%s_%dx%d"%[locale,resolution.x,resolution.y]
   for mode: String in ["letters","digits"]:
    if mode=="digits":
     GameManager.start_game("counting");await frames();game=app.current_view;game.focus_paused=false;game.show_tracing();await frames();lesson=game.tracing;lesson.focus_paused=false
    lesson.choose_mode(mode)
    for index: int in range(lesson.pool.size()):
     lesson.current_index=index;lesson.restart_symbol()
     for stroke: Array in lesson.entry().strokes:
      for pair: Array in stroke:
       var at: Vector2=lesson.board.global_position+lesson.board.from_world(Vector2(pair[0],pair[1]))
       if not lesson.board.get_global_rect().grow(-13).has_point(at):issues.append("Clipped glyph "+lesson.entry().glyph+suffix)
     if resolution==Vector2i(1280,800) or index in [0,4,12,29,30,32]:await capture(mode+"_%d_"%index+suffix)
    lesson.current_index=0;lesson.restart_symbol();lesson.celebrating=true;lesson.celebration_age=.7;await capture(mode+"_fireworks_"+suffix)
 app.queue_free();await frames();await AudioManager.shutdown();print("SYMBOL RENDER: %d screenshots, %d issues"%[captures,issues.size()])
 for issue: String in issues:print("LAYOUT: "+issue)
 get_tree().quit(0 if issues.is_empty() else 1)
