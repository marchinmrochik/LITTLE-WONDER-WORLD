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
var learning := false
var lesson := MelodyPractice.new()
var practice_controls: Control
var practice_label: Label
var demonstration := false
var demo_index := 0
var demo_wait := 0.0
var mode_hint: Label
var mode_buttons: Dictionary={}
var melody_title: Label

func _ready() -> void:
	var column := UiKit.column(10)
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("XYLO_TITLE",38,UiKit.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	mode_hint=UiKit.label("XYLO_HINT",26,UiKit.GREEN)
	mode_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(mode_hint)
	var modes := UiKit.row(10);modes.alignment=BoxContainer.ALIGNMENT_CENTER;column.add_child(modes)
	mode_buttons[false]=UiKit.button("MUSIC_FREE",set_learning.bind(false),UiKit.MINT);mode_buttons[true]=UiKit.button("MUSIC_LEARN",set_learning.bind(true),UiKit.CREAM)
	modes.add_child(mode_buttons[false]);modes.add_child(mode_buttons[true])
	practice_controls=UiKit.row(8);practice_controls.alignment=BoxContainer.ALIGNMENT_CENTER;column.add_child(practice_controls)
	var previous := UiKit.compact_tool_button("BACK",change_melody.bind(-1),"previous");previous.name="PreviousMelody";practice_controls.add_child(previous)
	melody_title=UiKit.label("",22,UiKit.GREEN);melody_title.custom_minimum_size.x=260;melody_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;practice_controls.add_child(melody_title)
	var next := UiKit.compact_tool_button("NEXT",change_melody.bind(1),"next");next.name="NextMelody";practice_controls.add_child(next)
	practice_controls.add_child(UiKit.button("MUSIC_LISTEN",start_demo,UiKit.MINT,"speaker"));practice_controls.add_child(UiKit.button("ANIMALS_REPLAY",func() -> void:choose_melody(lesson.melody),UiKit.CREAM,"replay"))
	practice_label=UiKit.label("",25,UiKit.GREEN);practice_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(practice_label)
	column.add_child(keyboard)
	keyboard.custom_minimum_size.y=300
	keyboard.size_flags_vertical = Control.SIZE_EXPAND_FILL
	keyboard.note_struck.connect(on_key)
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
	set_learning(false)

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
	keyboard.set_paused(overlay_paused or focus_paused or demonstration)
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

func set_learning(value: bool) -> void:
	if overlay_paused or focus_paused:return
	learning=value;demonstration=false;stop_notes();practice_controls.visible=value;choose_melody(lesson.melody)
	mode_hint.text=LocalizationManager.text("MUSIC_HINT_LEARN" if learning else "XYLO_HINT")
	for mode: bool in mode_buttons:mode_buttons[mode].add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if mode==learning else UiKit.CREAM,18,12))
func choose_melody(index: int) -> void:
	if overlay_paused or focus_paused:return
	demonstration=false;stop_notes();lesson.restart(index);update_practice();_update_pause()
	melody_title.text=str(lesson.melody+1)+" / "+str(MelodyPractice.MELODIES.size())+" · "+LocalizationManager.text("MUSIC_MELODY_"+str(lesson.melody))
func change_melody(delta: int) -> void:
	choose_melody(posmod(lesson.melody+delta,MelodyPractice.MELODIES.size()))

func update_practice() -> void:
	keyboard.highlighted=lesson.expected() if learning else -1;keyboard.queue_redraw()
	if not learning:practice_label.text="";return
	if lesson.done():practice_label.text=LocalizationManager.text("MUSIC_DONE");return
	practice_label.text=LocalizationManager.text("MUSIC_NEXT").format({"note":XylophoneKeyboard.NAMES[lesson.expected()],"current":lesson.index+1,"total":MelodyPractice.MELODIES[lesson.melody].size()})
func on_key(index: int) -> void:
	if overlay_paused or focus_paused or demonstration:return
	play_note(index)
	if not learning or lesson.done():return
	if lesson.submit(index):
		update_practice()
		if lesson.done():AudioManager.play_sfx("sparkle")
	else:practice_label.text=LocalizationManager.text("MUSIC_TRY");keyboard.queue_redraw()
func start_demo() -> void:
	if overlay_paused or focus_paused or not learning:return
	demonstration=not demonstration;demo_index=0;demo_wait=0;stop_notes();_update_pause()
	if not demonstration:update_practice()
func _process(delta: float) -> void:
	if not demonstration or overlay_paused or focus_paused:return
	demo_wait-=delta
	if demo_wait>0:return
	var notes: Array=MelodyPractice.MELODIES[lesson.melody]
	if demo_index>=notes.size():demonstration=false;update_practice();_update_pause();return
	var note: int=notes[demo_index];play_note(note);keyboard.highlighted=note;keyboard.queue_redraw();demo_index+=1;demo_wait=.6
func get_idle_action() -> Dictionary:
	if overlay_paused or focus_paused or demonstration or (learning and lesson.done()):return {}
	return {"from":keyboard.global_position+keyboard.key_rect(lesson.expected() if learning else 0).get_center()}
