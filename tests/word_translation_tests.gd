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
func caption() -> WordTranslationCaption:return app.header.find_child("WordTranslationCaption",true,false)
func run() -> void:
 var fixture := "user://test-runs/translations-"+str(Time.get_ticks_usec())
 SettingsManager.storage_path=fixture+"/settings.json";ProgressManager.storage_path=fixture+"/progress.json";ArtworkManager.directory=fixture+"/artwork";AssessmentHistory.storage_path=fixture+"/history.json"
 SettingsManager.reload();ProgressManager.reload();ArtworkManager.reload();AssessmentHistory.reload();SettingsManager.set_value("locale","en");SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("voice_volume",0.0)
 expect(not SettingsManager.values.english_ukrainian_translation,"Translations are opt-in")
 var legacy: Dictionary=SettingsManager.values.duplicate();legacy.erase("english_ukrainian_translation");expect(SettingsManager.is_valid_document(legacy),"Old version1 settings remain valid without the optional flag")
 expect(not SettingsManager.set_value("english_ukrainian_translation","yes"),"Invalid flag types cannot corrupt settings")
 app=preload("res://scenes/core/app_root.tscn").instantiate();add_child(app);await frames();GameManager.start_game("animals");await frames()
 AudioManager.say("WORD_CAT");await frames();expect(not caption().card.visible,"Caption is hidden by default")
 GameManager.parents_unlocked=true;GameManager.navigate("settings");await frames();app.current_view.find_child("english_ukrainian_translation",true,false).pressed.emit();await frames()
 expect(SettingsManager.values.english_ukrainian_translation,"Actual parent toggle enables captions")
 SettingsManager.reload();expect(SettingsManager.values.english_ukrainian_translation,"Preference survives settings reload")
 GameManager.start_game("animals");await frames();app.current_view._explore_animal("duck");await frames()
 expect(caption().card.visible and caption().english.text=="Duck" and caption().ukrainian.text=="Качка","Actual animal word displays its Ukrainian translation even with audio muted")
 SettingsManager.set_value("voice_volume",.6);AudioManager.say("COUNT_NUMBER_1");expect(AudioManager.voice.playing and AudioManager.voice.stream.resource_path.ends_with("/en/count_number_1.wav") and caption().ukrainian.text=="Один","Text translation keeps the actual voice English");SettingsManager.set_value("voice_volume",0.0)
 var key: String=caption().current_key;AudioManager.say("ANIMALS_CORRECT");expect(caption().current_key==key,"Generic praise cannot replace the learned word with unrelated text")
 AudioManager.say("ALPH_WORD_EN_14");expect(caption().ukrainian.text=="Апельсин","Alphabet orange picture translates the fruit rather than the color")
 AudioManager.say("WORD_CAT","uk");expect(not caption().card.visible,"An explicit Ukrainian utterance suppresses the English translation caption")
 for route: String in ["colors","feeding","shapes","puzzles","memory","counting","coloring","letters","syllables","world_topic","living_drawing"]:
  GameManager.navigate(route);await frames();var view: WordTranslationCaption=caption()
  for word: String in view.lookup:
   AudioManager.say(word,"en");expect(view.card.visible and not view.ukrainian.text.is_empty(),"Every authored vocabulary key resolves in "+route)
  view._process(6.1);expect(not view.card.visible,"Caption expires after a readable interval")
  AudioManager.say("WORD_DOG");app._show_confirmation("DRAW_CLEAR_TITLE","DRAW_CLEAR_HINT","CANCEL",func() -> void:pass);view._process(0);expect(not view.card.visible,"Caption does not overlap a parent modal");app.close_modal()
 SettingsManager.set_value("locale","uk");await frames();AudioManager.say("WORD_CAT");expect(not caption().card.visible,"Ukrainian mode has no redundant translation caption")
 SettingsManager.set_value("locale","en");await frames();SettingsManager.set_value("english_ukrainian_translation",false);AudioManager.say("WORD_CAT");expect(not caption().card.visible,"Disabling preference hides captions immediately")
 GameManager.return_home();await frames();expect(not caption().card.visible,"Changing route cannot leave a stale word caption")
 app.queue_free();await frames();await AudioManager.shutdown();print("WORD TRANSLATION TESTS: %d checks, %d failures"%[checks,failures.size()]);get_tree().quit(0 if failures.is_empty() else 1)
