extends Node
var checks := 0
var failures: PackedStringArray=[]
var app: Variant
var captures := 0
func _ready() -> void:call_deferred("run")
func expect(ok: bool,label: String) -> void:
 checks+=1
 if not ok:failures.append(label);print("FAIL: "+label)
func frames() -> void:
 for i: int in range(5):await get_tree().process_frame
func capture(name: String) -> void:
 if DisplayServer.get_name()=="headless":return
 await frames();await RenderingServer.frame_post_draw
 var out := "res://.local/qa/draw-word/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
 get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(out+name+".png"));captures+=1
func confirm() -> void:
 var buttons: Array=app.modal.find_children("*","Button",true,false)
 for button: Button in buttons:
  if button.text==LocalizationManager.text("CROC_SAVE_NEXT"):button.pressed.emit();return
 expect(false,"Save-next button exists")
func ink(game: Variant) -> void:
 game.editor.canvas.document.begin(Vector2(180,180));game.editor.canvas.document.move(Vector2(300,260));game.editor.canvas.document.finish();game.editor.canvas.refresh();game.editor._changed()
func run() -> void:
 var fixture := "user://test-runs/draw-word-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("sfx_volume",0.0);SettingsManager.set_value("reduced_motion",true)
 var original := Image.create(1024,640,false,Image.FORMAT_RGBA8);original.fill(Color("d3a4be"));ArtworkManager.save_draft(original)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);await frames()
 var sizes := [Vector2i(1280,800)] if DisplayServer.get_name()=="headless" else [Vector2i(1280,800),Vector2i(1024,768)]
 for size: Vector2i in sizes:
  get_window().size=size;await frames()
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);SettingsManager.set_value("difficulty","normal");await frames();GameManager.navigate("activities");await frames();GameManager.start_game("draw_word");await frames()
   var game: Variant=app.current_view;game.focus_paused=false;game.editor.focus_paused=false;game.update_pause()
   var prefix := locale+"_"+str(size.x)
   game.show_setup();expect(game.editor.canvas.paused,"Setup pauses drawing");await capture(prefix+"_setup")
   game.family=false;game.deck.configure(locale,"normal","all");game.task=game.deck.next();game.begin_task();await frames()
   expect(game.phase=="drawing" and not game.editor.canvas.paused,"Child task starts with canvas enabled")
   for entry: Dictionary in game.task:expect(not ContentManager.voice_path(entry.word_key,locale).is_empty(),"Task reuses an existing localized voice")
   await capture(prefix+"_child");var task_id: String=game.task[0].id;ink(game);expect(not game.editor.canvas.document.is_blank(),"Prompted canvas accepts ink")
   game.next_task();expect(is_instance_valid(app.modal),"Next task asks to save unpublished ink");app._back();await frames();expect(game.task[0].id==task_id and not game.editor.canvas.document.is_blank(),"Cancel preserves task and drawing")
   var count := ArtworkManager.entries.size();game.next_task();confirm();await frames()
   expect(ArtworkManager.entries.size()==count+1 and game.editor.canvas.document.is_blank(),"Save-next publishes image before blank page")
   expect(game.task[0].id!=task_id,"Random task does not immediately repeat")
   expect(ArtworkManager.load_draft().get_data()==original.get_data(),"Free drawing draft stays untouched")
   var current_id: String=game.task[0].id;GameManager.navigate("activities");await frames();GameManager.start_game("draw_word");await frames();game=app.current_view;game.focus_paused=false;game.editor.focus_paused=false;game.update_pause()
   expect(game.task[0].id==current_id,"Task context resumes with its separate draft")
   game.family=true;game.private_prompt();expect(game.editor.canvas.paused and game.phase=="private","Family task is privately shown before drawing");await capture(prefix+"_private")
   game.start_drawing();SettingsManager.set_value("english_ukrainian_translation",true);AudioManager.say("WORD_CAT");await frames()
   expect(not app.header.find_child("WordTranslationCaption",true,false).card.visible,"Family mode cannot leak words through English translation captions")
   expect(game.clue.get_children().all(func(node: Node) -> bool:return not node is Label or node.text!=game.task[0].text),"Family drawing header hides the answer")
   game.choose_task();await frames();expect(not app.modal.speak_selection,"Family picker does not voice the secret word");app.close_modal()
   await capture(prefix+"_secret");game.show_answer();expect(game.phase=="answer","Reveal is a human action");await capture(prefix+"_answer");game.start_drawing()
   game.family=false;game.deck.configure(locale,"advanced","all");game.task=game.deck.next();game.begin_task();await frames();expect(game.task.size()==2 and game.task[0].id!=game.task[1].id,"Advanced task combines two distinct familiar words");await capture(prefix+"_advanced")
   expect(not ProgressManager.document.games.has("draw_word"),"No invented drawing recognition or knowledge scores")
   var saved_entries: Array=ArtworkManager.entries.duplicate(true);ArtworkManager.entries=[]
   for i: int in range(ArtworkManager.MAX_ENTRIES):ArtworkManager.entries.append({"id":"1_"+str(i),"created":0})
   ink(game);current_id=game.task[0].id;game.next_task();confirm();await frames()
   expect(not game.editor.canvas.document.is_blank() and game.task[0].id==current_id,"Full gallery never clears the active drawing")
   app.close_modal();ArtworkManager.entries=saved_entries;game.editor.unpublished=false
 var deck := DrawWordDeck.new()
 for locale: String in ["en","uk"]:
  for level: String in ["easy","normal","advanced"]:
   for group: String in DrawWordDeck.CATEGORIES:
    deck.configure(locale,level,group)
    if not deck.available():expect(deck.next().is_empty(),"Empty category fails safely");continue
    var seen := {};var previous := ""
    for i: int in range(deck.pool.size()):
     var task := deck.next();expect(task.size()==deck.count_required(),"Task has required word count");expect(not seen.has(task[0].id),"Bag covers every primary word before repeating");seen[task[0].id]=true;previous=task[0].id
    if deck.pool.size()>1:expect(deck.next()[0].id!=previous,"Bag boundary avoids an immediate repeat")
 expect(not ArtworkManager.save_draft(original,"../outside"),"Draft slot path is whitelisted")
 GameManager.navigate("activities");await frames();app.queue_free();await frames();await AudioManager.shutdown()
 print("DRAW WORD TESTS: %d checks, %d failures, %d captures"%[checks,failures.size(),captures]);get_tree().quit(0 if failures.is_empty() else 1)
