extends Node
var app: Variant
var checks := 0
var failures: PackedStringArray=[]
var captures := 0
func _ready() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);print("FAIL: "+message)
func frames() -> void:
 for i: int in range(5):await get_tree().process_frame
func capture(label: String) -> void:
 if DisplayServer.get_name()=="headless":return
 await frames();await RenderingServer.frame_post_draw
 var path := "res://.local/qa/play-improvements/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
 get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path+label+".png"));captures+=1
func go(route: String) -> Variant:
 GameManager.navigate(route);await frames();app.suspended=false
 if app.current_view.get("focus_paused")!=null:app.current_view.focus_paused=false
 return app.current_view
func touch(point: Vector2,pressed: bool) -> void:
 var event := InputEventScreenTouch.new();event.index=7;event.position=point;event.pressed=pressed;Input.parse_input_event(event)
func run() -> void:
 var fixture := "user://test-runs/play-improvements-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json";BalloonRecords.storage_path=fixture+"/balloons.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("sfx_volume",0.0);SettingsManager.set_value("reduced_motion",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);await frames()
 var sizes := [Vector2i(1280,800)] if DisplayServer.get_name()=="headless" else [Vector2i(1280,800),Vector2i(1024,768)]
 for size: Vector2i in sizes:
  get_window().size=size;await frames()
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);await frames();var prefix := locale+"_"+str(size.x)
   var menu: Variant=await go("activities");var strip: DifficultyStrip=menu.find_child("DifficultyStrip",true,false)
   expect(strip!=null and strip.visible,"Difficulty is visible in catalog")
   strip.choose("advanced");SettingsManager.reload();expect(SettingsManager.values.difficulty=="advanced","Difficulty choice persists")
   strip.choose("normal");await capture(prefix+"_difficulty")
   var puzzle: Variant=await go("puzzles");puzzle.choose_material();await frames()
   var picker: MaterialPicker=app.modal;expect(puzzle.overlay_paused,"Material picker pauses gameplay")
   expect(picker.play_button.disabled,"Choice is required")
   var picture_id: String=ContentManager.puzzles[0].id
   var at: Vector2=picker.cells[0].get_global_rect().get_center();touch(at,true);await frames();touch(at,false);await frames()
   expect(picture_id in picker.chosen,"Actual touch selects a material card")
   if picture_id not in picker.chosen:picker.select(picture_id)
   expect(not picker.play_button.disabled,"Selected picture can start")
   await capture(prefix+"_picker");picker.finish([picture_id]);await frames()
   expect(puzzle.model.pictures.size()==1 and puzzle.model.picture_id()==picture_id,"Puzzle uses exact chosen image")
   expect(not puzzle.overlay_paused,"Picker resumes gameplay")
   for i: int in range(puzzle.model.piece_count()):puzzle.model.submit(i,i)
   puzzle.state=puzzle.State.FEEDBACK;puzzle._finish_feedback()
   expect(puzzle.state==puzzle.State.COMPLETE and puzzle.model.completed,"Single chosen puzzle completes without phantom rounds")
   var memory: Variant=await go("memory");memory.choose_material();await frames();picker=app.modal
   var ids: Array[String]=[]
   for i: int in range(3):ids.append(ContentManager.memory[i].id);picker.select(ids[-1])
   picker.finish(ids);await frames()
   expect(memory.model.deck.size()==6 and memory.model.deck.all(func(id: String) -> bool:return id in ids),"Memory deck uses exact selected pairs")
   await capture(prefix+"_memory")
   var words: Variant=await go("syllables");words.choose_material();await frames();picker=app.modal
   var word_id: String=WordCatalog.items(locale)[0].id;picker.select(word_id);picker.finish([word_id]);await frames()
   expect(words.targets.size()==1 and words.target().id==word_id,"Word builder uses selected word")
   while words.filled<words.target().letters.size():words.choose(words.target().letters[words.filled])
   words.advance();expect(words.state==words.State.COMPLETE,"Chosen word finishes after one word")
   var balloons: Variant=await go("balloons");balloons.start_mode(true);await frames()
   expect(balloons.flights.filter(func(f: Dictionary) -> bool:return not f.is_empty()).size()==4,"Challenge starts with four balloons")
   balloons.pop(0);balloons.pop(0);balloons.pop(11);expect(balloons.popped==1,"One balloon scores only once")
   var saved_remaining: float=balloons.remaining;balloons.set_overlay_paused(true);balloons._process(2);expect(balloons.remaining==saved_remaining,"Overlay pauses challenge timer");balloons.set_overlay_paused(false)
   balloons._process(30);expect(balloons.flights.filter(func(f: Dictionary) -> bool:return not f.is_empty()).size()>=8,"Density increases gradually")
   await capture(prefix+"_balloons")
   var previous_runs := BalloonRecords.top("normal").size();balloons._process(31)
   expect(balloons.round_over and BalloonRecords.top("normal").size()==mini(10,previous_runs+1),"Timed result is saved")
   var rows := BalloonRecords.top("normal").size();balloons.finish_challenge();expect(BalloonRecords.top("normal").size()==rows,"Result cannot be saved twice")
   await capture(prefix+"_records");balloons.start_mode(false);expect(not balloons.round_over and not balloons.timed and balloons.popped==0,"Free play remains available")
   var music: Variant=await go("xylophone");music.set_learning(true);music.choose_melody(1)
   var expected: int=music.lesson.expected();music.on_key((expected+1)%8);expect(music.lesson.index==0 and music.lesson.mistakes==1,"Wrong note gives a hint without advancing")
   music.on_key(expected);expect(music.lesson.index==1 and music.keyboard.highlighted==music.lesson.expected(),"Correct note advances highlight")
   var index: int=music.lesson.index;music.start_demo();music._process(.7);expect(music.lesson.index==index and music.demonstration,"Demo does not complete the child's notes")
   music.set_overlay_paused(true);var demo_index: int=music.demo_index;music._process(3);expect(music.demo_index==demo_index,"Demo pauses with overlay");music.set_overlay_paused(false)
   music.choose_melody(2);await capture(prefix+"_melody")
   for note: int in MelodyPractice.MELODIES[2]:music.on_key(note)
   expect(music.lesson.done() and music.keyboard.highlighted==-1,"All melody notes complete positively")
   await frames();var keyboard_size: Vector2=music.keyboard.size
   expect(MelodyPractice.MELODIES.size()==5,"Five authored melodies available")
   for melody: int in range(MelodyPractice.MELODIES.size()):
    music.choose_melody(melody);await frames()
    expect(music.keyboard.size==keyboard_size,"Melody choice keeps keyboard size unchanged")
    expect(music.get_global_rect().encloses(music.practice_controls.get_global_rect()),"Single-row melody selector fits game")
    expect(music.melody_title.text.contains(LocalizationManager.text("MUSIC_MELODY_"+str(melody))),"Current localized melody shown")
    for note: int in MelodyPractice.MELODIES[melody]:music.on_key(note)
    expect(music.lesson.done(),"Every melody can be completed")
   music.find_child("NextMelody",true,false).pressed.emit();expect(music.lesson.melody==0 and music.lesson.index==0,"Next wraps and resets practice")
   music.find_child("PreviousMelody",true,false).pressed.emit();expect(music.lesson.melody==4,"Previous wraps to fifth melody")
   await capture(prefix+"_melody_expanded")
   music.set_learning(false);expect(not music.practice_controls.visible,"Free instrument mode retained")
 var many: Array=[]
 for i: int in range(1000):
  var entry: Dictionary=ContentManager.puzzles[0].duplicate();entry.id="fixture_"+str(i);many.append(entry)
 var large := MaterialPicker.show_for(app.current_view,many,func(_ids: Array) -> void:pass)
 await frames();large.scroll.scroll_vertical=1000000;await frames()
 expect(large.cells.size()<=32,"Material list stays virtualized for1000 items")
 expect(large.cells.any(func(cell: ChildButton) -> bool:return cell.visible and cell.get_meta("entry_id")=="fixture_999"),"Virtualized picker reaches last item")
 app.close_modal();await frames()
 var puzzle_ids: Array[String]=[]
 for entry: Dictionary in ContentManager.puzzles:puzzle_ids.append(entry.id)
 var rounds := PuzzleRound.new(puzzle_ids);rounds.begin("normal",123);var previous := rounds.picture_id();rounds.begin("normal",123);expect(rounds.picture_id()!=previous,"Random replay avoids an immediate repeated picture")
 var trace := GuidedTrace.new();trace.configure([[0,0],[100,0]]);trace.begin(Vector2.ZERO,20);trace.move(Vector2(20,0),20);trace.move(Vector2(20,80),20)
 expect(trace.off_path,"Off-path movement is rejected");trace.move(Vector2(30,0),20);expect(not trace.off_path,"Nearby re-entry resumes without exact dot targeting");trace.move(Vector2(100,0),20);expect(trace.complete,"Resumed trace finishes")
 for score: int in range(15):expect(BalloonRecords.record(score,"easy"),"Record saves")
 expect(BalloonRecords.top("easy").size()==10 and BalloonRecords.top("easy")[0].score==14,"Top ten sorted and bounded per difficulty")
 expect(not BalloonRecords.record(-1,"normal"),"Invalid record cannot overwrite history")
 app.queue_free();await frames();await AudioManager.shutdown()
 print("PLAY IMPROVEMENTS: %d checks, %d failures, %d captures"%[checks,failures.size(),captures]);get_tree().quit(0 if failures.is_empty() else 1)
