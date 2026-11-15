extends Node
var checks := 0
var failures: PackedStringArray=[]
func _ready() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);print("FAIL: "+message)
func run() -> void:
 SettingsManager.storage_path="user://test-runs/voice-routing-"+str(Time.get_ticks_usec())+"/settings.json"
 SettingsManager.reload();SettingsManager.set_value("music_enabled",false);SettingsManager.set_value("system_voice_enabled",false);SettingsManager.set_value("voice_volume",.6)
 # Exercise real playback selection without emitting 710 short clips to the room.
 AudioServer.set_bus_mute(AudioServer.get_bus_index("Voice"),true)
 var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/voice/manifest.json"))
 var played := 0
 for clip: Dictionary in manifest.clips:
  SettingsManager.values.locale=clip.locale
  var expected: String="res://"+clip.file
  expect(ContentManager.voice_path(clip.key,clip.locale)==expected,"Manifest route "+clip.locale+":"+clip.key)
  expect(AudioManager.say(clip.key),"Playback starts "+clip.locale+":"+clip.key)
  expect(AudioManager.voice.playing and AudioManager.voice.stream.resource_path==expected,"Actual stream "+clip.locale+":"+clip.key)
  expect(AudioManager.voice.pitch_scale==1.0,"No pitch alteration "+clip.key)
  expect(AudioManager.voice.stream.get_length()>.15,"Nonempty imported stream "+clip.key)
  played+=1
  if played%40==0:
   AudioManager.stop_voice();await get_tree().create_timer(.08).timeout
 AudioManager.say("WORD_CAT","en")
 expect(AudioManager.voice.stream.resource_path.ends_with("/en/word_cat.wav"),"Explicit English override")
 AudioManager.say("WORD_SHEEP","uk")
 expect(AudioManager.voice.stream.resource_path.ends_with("/uk/word_sheep.wav"),"Immediate locale switch replaces previous stream")
 expect(not AudioManager.say("NOT_A_REAL_VOICE_KEY"),"Missing cue cannot play unrelated fallback")
 expect(not AudioManager.voice.playing,"Missing cue stops previous voice")
 SettingsManager.values.locale="uk";AudioManager.say("WORLD_BODY_FOOT_WORD")
 expect(AudioManager.voice.stream.resource_path.ends_with("/uk/world_body_foot_word.wav"),"Foot uses Ukrainian cue")
 AudioManager.stop_voice();expect(not AudioManager.voice.playing,"Stop ends playback")
 await get_tree().create_timer(.35).timeout
 await AudioManager.shutdown()
 print("VOICE ROUTING TESTS: %d checks, %d failures"%[checks,failures.size()])
 get_tree().quit(0 if failures.is_empty() else 1)
