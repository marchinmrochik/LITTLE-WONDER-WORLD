extends "res://tests/seasonal_tests.gd"
func run() -> void:
 var fixture := "user://test-runs/mouse-circles-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("reduced_motion",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames();GameManager.living_story="spring";GameManager.start_game("living_drawing");await frames();var game: Variant=app.current_view;game.focus_paused=false
 for level: String in ["easy","normal","advanced"]:
  SettingsManager.set_value("difficulty",level)
  for direction: float in [1.0,-1.0]:
   game.restart();game.completed[0]=true;game.advance_part();game.zoom_part(1);await get_tree().create_timer(.13).timeout;await frames()
   var path: PackedVector2Array=game.trace.points;var center := Vector2(game.part().marker[0],game.part().marker[1]);var radius: float=center.distance_to(path[0]);mouse(screen(game,path[0]),true)
   for i: int in range(1,181):
    var angle: float=direction*i*TAU/180;move(screen(game,center+Vector2(cos(angle),sin(angle))*(radius+sin(i*1.9)*2)))
   mouse(screen(game,path[0]),false);await get_tree().create_timer(.25).timeout;await frames()
   expect(game.completed[1],"Actual imperfect mouse circle finishes clockwise/counterclockwise at "+level)
   expect(game.state==game.State.READY,"Mouse circle returns to drawing selection without getting stuck")
 app.queue_free();await frames();await AudioManager.shutdown();print("MOUSE CIRCLE TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
