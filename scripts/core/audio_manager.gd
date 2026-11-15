extends Node
signal speech_requested(key: String,locale: String)

var music := AudioStreamPlayer.new()
var voice := AudioStreamPlayer.new()
var effects: Array[AudioStreamPlayer] = []
var effect_cursor := 0
var resting := false
var instrument_active := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus_name: String in ["Music", "Voice", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	music.bus = "Music"
	voice.bus = "Voice"
	add_child(music)
	add_child(voice)
	voice.finished.connect(_update_music_level)
	for index: int in range(6):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		effects.append(player)
	var stream := load(ContentManager.audio_path("music", "meadow")) as AudioStreamWAV
	if stream != null:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		music.stream = stream
	SettingsManager.changed.connect(_settings_changed)
	apply_settings()

func apply_settings() -> void:
	for pair: Array in [["Music", "music_volume"], ["Voice", "voice_volume"], ["SFX", "sfx_volume"]]:
		var volume: float = SettingsManager.values[pair[1]]
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(pair[0]), linear_to_db(maxf(volume, 0.0001)))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(pair[0]), volume <= 0)
	_update_music_level()
	if SettingsManager.values.music_enabled:
		if not music.playing and music.stream != null:
			music.play()
	else:
		music.stop()
	if SettingsManager.values.voice_volume == 0:
		stop_voice()
	elif not SettingsManager.values.system_voice_enabled and DisplayServer.get_name() != "headless":
		DisplayServer.tts_stop()

func play_sfx(id: String) -> void:
	var path := ContentManager.audio_path("sfx", id)
	if path.is_empty():
		return
	var player := effects[effect_cursor]
	effect_cursor = (effect_cursor + 1) % effects.size()
	player.stream = load(path) as AudioStream
	player.play()

func say(key: String, locale_override: String = "") -> bool:
	stop_voice()
	var locale: String = SettingsManager.values.locale if locale_override.is_empty() else locale_override
	speech_requested.emit(key,locale)
	if SettingsManager.values.voice_volume <= 0:
		return false
	var path := ContentManager.voice_path(key, locale)
	if not path.is_empty() and ResourceLoader.exists(path):
		voice.stream = load(path) as AudioStream
		voice.play()
		_update_music_level()
		return true
	if not SettingsManager.values.system_voice_enabled or DisplayServer.get_name() == "headless":
		return false
	var voices := DisplayServer.tts_get_voices_for_language(locale)
	if voices.is_empty():
		return false
	var text: String = LocalizationManager.messages.get(locale, {}).get(key, "")
	if text.is_empty():
		return false
	DisplayServer.tts_speak(text, voices[0], int(SettingsManager.values.voice_volume * 100), 1.0, 0.9, 0, true)
	return true

func stop_voice() -> void:
	voice.stop()
	_update_music_level()
	if DisplayServer.get_name() != "headless":
		DisplayServer.tts_stop()

func voice_available(locale: String) -> bool:
	return DisplayServer.get_name() != "headless" and not DisplayServer.tts_get_voices_for_language(locale).is_empty()

func local_voice_available(key: String, locale: String) -> bool:
	var path := ContentManager.voice_path(key, locale)
	return not path.is_empty() and ResourceLoader.exists(path)

func _update_music_level() -> void:
	music.volume_db = (-9.0 if resting else 0.0) - (8.0 if voice.playing else 0.0)
	# Free play has its own pitches: keep the meadow loop silent while playing.
	music.volume_db = -80.0 if instrument_active else music.volume_db

func set_instrument_active(value: bool) -> void:
	instrument_active = value
	_update_music_level()

func set_resting(value: bool) -> void:
	resting = value
	apply_settings()

func suspend() -> void:
	stop_voice()
	music.stream_paused = true
	for effect: AudioStreamPlayer in effects:
		effect.stop()

func resume() -> void:
	music.stream_paused = false
	apply_settings()

func shutdown() -> void:
	stop_voice()
	music.stop()
	for effect: AudioStreamPlayer in effects:
		effect.stop()
	# Allow the audio mixer to release queued playback references before exit.
	await get_tree().create_timer(0.15).timeout
	music.stream = null
	voice.stream = null
	for effect: AudioStreamPlayer in effects:
		effect.stream = null
	await get_tree().process_frame

func _settings_changed(_key: String) -> void:
	apply_settings()
