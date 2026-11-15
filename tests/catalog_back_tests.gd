extends Node
var app: Variant
var checks := 0
var failures: PackedStringArray=[]
func _ready() -> void:call_deferred("run")
func frames() -> void:
 for i: int in range(5):await get_tree().process_frame
func expect(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);print("FAIL: "+message)
func back() -> void:
 var button := app.find_child("BackButton",true,false) as Button
 expect(button!=null and button.text==LocalizationManager.text("BACK") and button.icon.resource_path.ends_with("back.svg"),"Header provides localized Back and arrow")
 button.pressed.emit();await frames()
func run() -> void:
 var fixture := "user://test-runs/catalog-back-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("reduced_motion",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
 for locale: String in ["en","uk"]:
  SettingsManager.set_value("locale",locale);GameManager.return_home();await frames();GameManager.navigate("activities");await frames()
  app.current_view.ensure_activity("counting");await frames();var offset: int=app.current_view.scroll.scroll_vertical
  for id: String in GameManager.games:
   if id=="living_drawing":continue
   GameManager.start_game(id);await frames();await back();expect(GameManager.current_route=="activities","Game returns to catalog: "+id)
   expect(app.current_view.scroll.scroll_vertical==offset,"Catalog keeps its scrolling position")
  GameManager.navigate("living_gallery");await frames();app.current_view.open_story("house");await frames();app.current_view.completed[0]=true;await back();expect(GameManager.current_route=="living_gallery","Scene returns to story gallery")
  app.current_view.open_story("house");await frames();expect(app.current_view.completed[0],"Back preserves scene draft");await back();await back();expect(GameManager.current_route=="activities","Story gallery returns to categories")
  GameManager.navigate("world");await frames();GameManager.navigate("world_topic");await frames();await back();expect(GameManager.current_route=="world","World topic returns to its category hub");await back();expect(GameManager.current_route=="activities","World hub returns to categories")
  GameManager.start_game("drawing");await frames();var game: Variant=app.current_view;game.show_gallery();await frames();await back();expect(GameManager.current_route=="drawing" and not is_instance_valid(game.gallery),"Back first closes an embedded artwork gallery")
  app._show_confirmation("DRAW_CLEAR_TITLE","DRAW_CLEAR_HINT","DRAW_CLEAR_CONFIRM",func() -> void:pass);await frames();await back();expect(GameManager.current_route=="drawing" and not is_instance_valid(app.modal),"Back dismisses modal before leaving activity")
  app._back();await frames();expect(GameManager.current_route=="activities","Keyboard/system Back uses same catalog destination")
  GameManager.navigate("meadow");await frames();await back();expect(GameManager.current_route=="activities","Companion opened from catalog returns there")
  GameManager.return_home();await frames();GameManager.navigate("meadow");await frames();await back();expect(GameManager.current_route=="home","Companion opened from home returns home")
  GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames();GameManager.navigate("gallery");await frames();await back();expect(GameManager.current_route=="settings","Protected artwork gallery returns to settings");await back();expect(GameManager.current_route=="home","Settings returns home")
 app.queue_free();await frames();await AudioManager.shutdown();print("CATALOG BACK TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
