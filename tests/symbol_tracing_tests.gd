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
func touch(at: Vector2,pressed: bool,index: int=7) -> void:
 var e := InputEventScreenTouch.new();e.position=at;e.pressed=pressed;e.index=index;get_viewport().push_input(e,true)
func drag(at: Vector2,index: int=7) -> void:
 var e := InputEventScreenDrag.new();e.position=at;e.index=index;get_viewport().push_input(e,true)
func screen(lesson: Variant,at: Vector2) -> Vector2:return lesson.board.global_position+lesson.board.from_world(at)
func trace_symbol(lesson: Variant) -> void:
 while not lesson.celebrating:
  var previous: int=lesson.stroke_index;var path: PackedVector2Array=lesson.trace.points.duplicate()
  touch(screen(lesson,path[0]),true)
  if lesson.stroke_index==previous and not lesson.celebrating:
   for i: int in range(1,path.size()):drag(screen(lesson,path[i]))
  touch(screen(lesson,path[-1]),false)
  if lesson.stroke_index==previous and not lesson.celebrating:expect(false,"Gesture should finish the actual ordered stroke");return
func run() -> void:
 var fixture := "user://test-runs/symbol-tracing-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("music_enabled",false)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames()
 for locale: String in ["en","uk"]:
  SettingsManager.set_value("locale",locale);GameManager.return_home();await frames();GameManager.start_game("letters");await frames();var game: Variant=app.current_view;game.focus_paused=false
  game.find_child("TraceTab",true,false).pressed.emit();await frames();var lesson: Variant=game.tracing;lesson.focus_paused=false
  expect(lesson.pool.size()==(26 if locale=="en" else 33),"Tracing tab uses only the selected language alphabet")
  expect(lesson.fixed_mode=="letters" and lesson.find_child("TraceDigits",true,false)==null,"Alphabet tracing offers only letters")
  lesson.choose_mode("digits");expect(lesson.mode=="letters","An alphabet lesson cannot be switched into digits")
  for mode: String in ["letters","digits"]:
   if mode=="digits":
    GameManager.start_game("counting");await frames();game=app.current_view;game.focus_paused=false;game.find_child("TraceDigitsTab",true,false).pressed.emit();await frames();lesson=game.tracing;lesson.focus_paused=false
    expect(lesson.mode=="digits" and lesson.pool.size()==10 and lesson.find_child("TraceLetters",true,false)==null,"Numbers category contains its own digit tracing tab")
   lesson.choose_mode(mode)
   for difficulty: String in ["easy","normal","advanced"]:
    SettingsManager.set_value("difficulty",difficulty)
    for index: int in range(lesson.pool.size()):
     lesson.current_index=index;lesson.restart_symbol();var key: String=lesson.entry().word_key
     expect(AudioManager.local_voice_available(key,locale),"Each displayed symbol has local language speech")
     var start: Vector2=lesson.trace.current_point();expect(screen(lesson,start).y>lesson.board.global_position.y,"Leading point fits board even for upper accents")
     game.set_overlay_paused(true);touch(screen(lesson,start),true);drag(screen(lesson,lesson.trace.points[1]));touch(screen(lesson,start),false);expect(lesson.trace.edge==0 and lesson.trace.fraction==0,"Paused practice rejects drawing");game.set_overlay_paused(false)
     trace_symbol(lesson);expect(lesson.celebrating and lesson.spoken_key==key,"Completing a glyph speaks that exact symbol and starts small fireworks")
     var age: float=lesson.celebration_age;game.set_overlay_paused(true);lesson._process(2);expect(lesson.celebration_age==age and lesson.current_index==index,"Pause freezes fireworks and next-symbol timer");game.set_overlay_paused(false)
     lesson.bag.clear();lesson._process(2);expect(not lesson.celebrating and lesson.current_index!=index,"Practice automatically continues without an immediate repeat or ending")
  game.start_session("basket");await frames();expect(not game.tracing_mode and game.basket_grid!=null,"Basket tab returns from tracing to actual counting")
  game.show_tracing();await frames();game.state=game.State.FEEDBACK;game._finish_feedback();expect(game.tracing_mode and game.tracing!=null,"A stale counting feedback callback cannot replace digit tracing")
  game.start_session("choice");await frames();expect(not game.tracing_mode and game.find_child("ChoiceMode",true,false)!=null,"How-many tab restores its counting activity")
  game.show_tracing();await frames()
  expect(app.idle_guide.next_action().has("to"),"Parent alphabet delegates the single-stroke idle hint")
  GameManager.start_game("letters");await frames();game=app.current_view;game.focus_paused=false
  game.set_picture_mode(true);await frames();expect(game.find_child("CardPicture",true,false)!=null,"Existing picture alphabet remains available")
  game.set_tracing_mode();await frames();expect(game.tracing!=null,"Tracing can be reopened after picture browsing")
 GameManager.start_game("counting");await frames();app.current_view.focus_paused=false;app.current_view.show_tracing();await frames()
 var active: Variant=app.current_view.tracing;active.focus_paused=false;active.choose_mode("digits");active.current_index=0;active.restart_symbol();SettingsManager.set_value("voice_volume",.7);trace_symbol(active)
 expect(AudioManager.voice.playing and AudioManager.voice.stream.resource_path.ends_with("trace_number_zero.wav"),"The completed zero actually plays its localized name")
 active.celebration_age=1.6;active._process(0);expect(active.celebrating and active.current_index==0,"Automatic advance waits for spoken name to finish")
 app.current_view.set_overlay_paused(true);AudioManager.stop_voice();app.current_view.set_overlay_paused(false);expect(AudioManager.voice.playing,"Returning from parent pause repeats the interrupted symbol name")
 AudioManager.stop_voice();active._process(0);expect(not active.celebrating,"Practice advances after both speech and fireworks finish")
 expect(not ProgressManager.document.games.has("symbol_tracing"),"Infinite repetition creates no fake knowledge score or completed session")
 app.queue_free();await frames();await AudioManager.shutdown();print("SYMBOL TRACING TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
