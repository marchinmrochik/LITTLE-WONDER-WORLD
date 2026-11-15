extends Control

const NOTES := ["c","d","e","f","g","a","b","c2"]
const VOICES := 16
var keyboard := XylophoneKeyboard.new()
var players: Array[AudioStreamPlayer] = []
var streams: Array[AudioStream] = []
var cursor := 0
var strikes := 0
var overlay_paused := false
var focus_paused := false

func _ready() -> void:
	var column := UiKit.column(18)
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("XYLO_TITLE",38,UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var hint := UiKit.label("XYLO_HINT",26,UiKit.GREEN)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hint)
	column.add_child(keyboard)
	keyboard.size_flags_vertical = Control.SIZE_EXPAND_FILL
	keyboard.note_struck.connect(play_note)
	var volume := UiKit.label("XYLO_VOLUME",20,UiKit.MUTED)
	volume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(volume)
	for note: String in NOTES:
		streams.append(load("res://assets/audio/instrument/"+note+".wav"))
	for index: int in range(VOICES):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		# Sixteen simultaneous peaks remain bounded below full-scale.
		player.volume_db = linear_to_db(0.095)
		add_child(player)
		players.append(player)
	AudioManager.set_instrument_active(true)

func play_note(index: int) -> void:
	if index < 0 or index >= 8 or overlay_paused or focus_paused or SettingsManager.values.sfx_volume <= 0:
		return
	var target := cursor
	for offset: int in range(VOICES):
		var candidate := (cursor + offset) % VOICES
		if not players[candidate].playing:
			target = candidate
			break
	var player := players[target]
	player.stop()
	player.stream = streams[index]
	player.play()
	cursor = (target+1) % VOICES
	strikes += 1

func stop_notes() -> void:
	for player: AudioStreamPlayer in players:
		player.stop()

func set_overlay_paused(value: bool) -> void:
	overlay_paused = value
	_update_pause()

func _update_pause() -> void:
	keyboard.set_paused(overlay_paused or focus_paused)
	if keyboard.paused:
		stop_notes()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:
		focus_paused = true
		_update_pause()
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]:
		focus_paused = false
		_update_pause()

func _exit_tree() -> void:
	stop_notes()
	AudioManager.set_instrument_active(false)
