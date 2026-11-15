extends Node
var app: Variant
var captures := 0
var issues: PackedStringArray = []
var output := "res://.local/qa/translations"
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
 var fixture := "user://test-runs/translations-render-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0);SettingsManager.set_value("english_ukrainian_translation",true)
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);app.idle_guide.set_process(false);DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output));await frames()
 var samples := {"animals":["WORD_DUCK","FIND_ELEPHANT"],"letters":["ALPH_WORD_EN_08","ALPH_WORD_EN_14"],"counting":["COUNT_PUT_STRAWBERRIES_10","COUNT_NUMBER_7"],"world_topic":["WORLD_BODY_EYEBROW_WORD","WORD_DOG"],"feeding":["FOOD_GIVE_STRAWBERRY","FOOD_WORD_WATERMELON"],"living_drawing":["LIVE_CHIMNEY","LIVE_LEFT_WINDOW"],"coloring":["BOOK_WORD_DOG","WORD_DUCK"]}
 for resolution: Vector2i in [Vector2i(1280,800),Vector2i(1440,810),Vector2i(1024,768)]:
  get_window().size=resolution;SettingsManager.set_value("locale","en");GameManager.return_home();await frames()
  var suffix := "%dx%d"%[resolution.x,resolution.y]
  for route: String in samples:
   GameManager.navigate(route);await frames()
   for key: String in samples[route]:
    AudioManager.say(key,"en");await capture(route+"_"+key+"_"+suffix)
    var caption: WordTranslationCaption=app.header.find_child("WordTranslationCaption",true,false)
    if not caption.card.visible:issues.append("Missing caption "+key)
    if not app.header.get_global_rect().encloses(caption.card.get_global_rect()):issues.append("Caption outside header "+key)
    var back: Control=app.find_child("BackButton",true,false)
    if caption.card.get_global_rect().intersects(back.get_global_rect()) or caption.card.get_global_rect().intersects(app.hold_button.get_global_rect()):issues.append("Caption overlaps navigation "+key)
  for locale: String in ["en","uk"]:
   SettingsManager.set_value("locale",locale);GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames();await capture("settings_"+locale+"_"+suffix)
   GameManager.start_game("animals");await frames();AudioManager.say("WORD_DUCK");if locale=="uk":await capture("uk_no_caption_"+suffix)
 app.queue_free();await frames();await AudioManager.shutdown();print("WORD TRANSLATION RENDER: %d screenshots, %d issues"%[captures,issues.size()])
 for issue: String in issues:print("LAYOUT: "+issue)
 get_tree().quit(0 if issues.is_empty() else 1)
