extends Node
var app: Variant
var checks := 0
var failures: PackedStringArray=[]
func _ready() -> void:call_deferred("run")
func frames() -> void:
 for i: int in range(4):await get_tree().process_frame
func expect(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);print("FAIL: "+message)
func mouse(point: Vector2,pressed: bool) -> void:
 var e := InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=point;e.pressed=pressed;get_viewport().push_input(e,true)
func move(point: Vector2) -> void:
 var e := InputEventMouseMotion.new();e.position=point;e.button_mask=MOUSE_BUTTON_MASK_LEFT;get_viewport().push_input(e,true)
func screen(game: Variant,at: Vector2) -> Vector2:return game.board.global_position+game.board.from_world(at)
func click(game: Variant,at: Vector2) -> void:mouse(screen(game,at),true);mouse(screen(game,at),false)
func run() -> void:
 # Approximate circles deliberately never pass exactly through polygon vertices.
 var circle: Array=[]
 for i: int in range(21):circle.append([cos(i*TAU/20)*50,sin(i*TAU/20)*50])
 for sign_value: float in [1.0,-1.0]:
  var model := GuidedTrace.new();model.configure(circle);model.begin(Vector2(50,0),12)
  for i: int in range(1,151):
   var angle: float=sign_value*i*TAU/150;model.move(Vector2(cos(angle),sin(angle))*(52+sin(i*1.7)),12)
  expect(model.complete,"Imperfect circle completes in either direction without exact vertex hits")
 var fixture := "user://test-runs/seasons-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
 GameManager.navigate("activities");await frames();var menu: Variant=app.current_view
 expect(menu.COLUMNS==4,"Activity categories are four per row")
 expect(is_equal_approx(menu.cells[0].position.y,menu.cells[3].position.y) and menu.cells[4].position.y>menu.cells[0].position.y,"Four actual category cards share a row")
 for locale: String in ["en","uk"]:
  SettingsManager.set_value("locale",locale);await frames()
  for story: String in ["spring","autumn","winter"]:
   for difficulty: String in ["easy","normal","advanced"]:
    SettingsManager.set_value("difficulty",difficulty);GameManager.navigate("living_gallery");await frames()
    var node_name: String=story.capitalize()+"Story";app.current_view.find_child(node_name,true,false).pressed.emit();await frames();var game: Variant=app.current_view;game.focus_paused=false;game.restart()
    expect(game.story_id==story and game.board is SeasonalDrawingBoard and game.parts.size()==12,"Gallery opens its distinct twelve-element story")
    expect(game.available_parts().size()==1,"One anchor starts the seasonal story")
    for i: int in range(12):
     var pair: Array=game.part().marker;click(game,Vector2(pair[0],pair[1]));await get_tree().create_timer(.12).timeout;await frames()
     expect(game.state==game.State.TRACE,"Mouse chooses marker and reaches enlarged guide")
     expect(AudioManager.local_voice_available(game.part_prompt(),locale),"Every seasonal actor has local language speech")
     var path: PackedVector2Array=game.trace.points.duplicate();mouse(screen(game,path[0]),true)
     for n: int in range(1,path.size()):move(screen(game,path[n]))
     mouse(screen(game,path[-1]),false);await get_tree().create_timer(.24).timeout;await frames()
     expect(game.completed[i],"Actual mouse tracing reveals the chosen actor")
     if i==0:expect(game.available_parts().size()==11,"Anchor unlocks eleven independently selectable markers")
    expect(game.state==game.State.PLAY and not game.has_node("CompletionParty"),"Season remains open ended after all elements are drawn")
    for part: Dictionary in game.parts:
     var count: int=game.board.effect_count;click(game,Vector2(part.marker[0],part.marker[1]));expect(game.board.effect_count==count+1,"Every drawn actor responds to its actual mouse hit target")
    var sky_id := "moon" if story=="winter" else "sun";game.board.night=false;game.board.play_object(sky_id);expect(game.board.night,"Each season supports a night sky")
    game.handle_back();await frames();app.current_view.find_child("HouseStory",true,false).pressed.emit();await frames();expect(app.current_view.story_id=="house","House remains a separate selectable story")
    app.current_view.handle_back();await frames();app.current_view.find_child(node_name,true,false).pressed.emit();await frames();game=app.current_view;game.focus_paused=false
    expect(game.completed.count(true)==12 and game.board.night,"Season keeps its own drawing and night state across story switches")
    game.restart()
 GameManager.return_home();await frames();GameManager.start_game("balloons");await frames();var balloons: Variant=app.current_view;balloons.focus_paused=false
 expect(balloons.balloons.size()==12,"Faster balloons retain twelve independent flights")
 for flight: Dictionary in balloons.flights:expect(flight.speed>=58.5 and flight.speed<=99,"Balloon speed is fifty percent higher than previous build")
 var first_y: float=balloons.flights[0].y;var speed: float=balloons.flights[0].speed;balloons._process(.1);expect(is_equal_approx(first_y-balloons.flights[0].y,speed*.1),"Balloon movement uses the increased speed")
 app.queue_free();await frames();await AudioManager.shutdown();print("SEASONAL TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
