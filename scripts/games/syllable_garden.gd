extends Control
enum State { BUILDING, COMPLETE }
var chosen_word := ""
var state := State.BUILDING
var body := UiKit.column(16)
var alphabet := "uk"
var targets: Array = []
var round_index := 0
var filled := 0
var choices: Array[String] = []
var overlay_paused := false
var focus_paused := false
var session_awarded := false
var next_button: ChildButton
var options: HFlowContainer
var used: Array[int]=[]

func _ready() -> void:
	alphabet=SettingsManager.values.locale
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_session()

func start_session() -> void:
	CompletionCelebration.clear(self)
	state=State.BUILDING
	session_awarded=false
	var previous: String="" if targets.is_empty() else str(target().id)
	targets=WordCatalog.items(alphabet)
	if not chosen_word.is_empty():targets=targets.filter(func(e: Dictionary) -> bool:return e.id==chosen_word)
	targets.shuffle()
	if chosen_word.is_empty() and targets.size()>1 and str(targets[0].id)==previous:targets.push_back(targets.pop_front())
	targets=targets.slice(0,5)
	round_index=0;filled=0;prepare_tiles()
	show_question()
	repeat_prompt()

func target() -> Dictionary: return targets[round_index]

func choose_alphabet(mode: String) -> void:
	if mode!=SettingsManager.values.locale:return
	alphabet=mode;start_session()

func prepare_tiles() -> void:
	used.clear();choices.assign(target().letters);choices.shuffle()

func show_question() -> void:
	for child: Node in body.get_children():body.remove_child(child);child.queue_free()
	var top := UiKit.row(14);body.add_child(top)
	top.add_child(UiKit.label("BLEND_TITLE",32,UiKit.GREEN));top.add_child(UiKit.spacer());top.add_child(UiKit.button("MATERIAL_CHOOSE",choose_material,UiKit.MINT))
	top.add_child(UiKit.button("",repeat_prompt,UiKit.MINT,"speaker"))
	var hint := UiKit.label("BLEND_HINT",22,UiKit.GREEN);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(hint)
	var picture := TextureRect.new();picture.name="WordPicture";picture.texture=load(target().illustration);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.size_flags_vertical=Control.SIZE_EXPAND_FILL;picture.custom_minimum_size=Vector2(160,135);body.add_child(picture)
	if not target().get("art_region",[]).is_empty():
		var region: Array=target().art_region
		var atlas := AtlasTexture.new();atlas.atlas=picture.texture;atlas.region=Rect2(region[0],region[1],region[2],region[3]);picture.texture=atlas
	picture.gui_input.connect(func(event: InputEvent) -> void:
		if overlay_paused or focus_paused:return
		if event is InputEventScreenTouch and event.pressed and not event.canceled:repeat_prompt()
		elif event is InputEventMouseButton and event.device!=InputEvent.DEVICE_ID_EMULATION and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:repeat_prompt())
	var slots := HFlowContainer.new();slots.alignment=FlowContainer.ALIGNMENT_CENTER;slots.add_theme_constant_override("h_separation",5);body.add_child(slots)
	var letter_index := 0
	for i: int in range(target().text.length()):
		var glyph: String=target().text.substr(i,1).to_upper()
		var actual_letter: bool=glyph in target().letters
		var label := UiKit.label("",32,UiKit.GREEN if letter_index<filled else UiKit.MUTED)
		label.name="Slot_"+str(i);label.custom_minimum_size=Vector2(52 if actual_letter else 20,58);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		label.add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if letter_index<filled else UiKit.CREAM,12,4))
		label.text=glyph if not actual_letter or letter_index<filled or SettingsManager.values.difficulty=="easy" else "·"
		slots.add_child(label)
		if actual_letter:letter_index+=1
	options=HFlowContainer.new();options.alignment=FlowContainer.ALIGNMENT_CENTER;options.add_theme_constant_override("h_separation",7);options.add_theme_constant_override("v_separation",7);body.add_child(options)
	for i: int in range(choices.size()):
		var button := UiKit.button("",choose_tile.bind(i),UiKit.CREAM);button.name="Choice_"+str(i);button.text=choices[i];button.disabled=i in used;button.custom_minimum_size=Vector2(62,66);button.add_theme_font_size_override("font_size",34);options.add_child(button)
	var footer := UiKit.row(16);footer.alignment=BoxContainer.ALIGNMENT_CENTER;body.add_child(footer)
	var progress := UiKit.label("",23,UiKit.GREEN);progress.text=LocalizationManager.text("BLEND_PROGRESS").format({"current":round_index+1,"total":targets.size()});footer.add_child(progress)
	next_button=UiKit.button("BLEND_NEXT",advance,UiKit.MINT,"next");next_button.name="NextSyllable";next_button.disabled=filled!=target().letters.size();footer.add_child(next_button)

func choose_tile(index: int) -> void:
	if index<0 or index>=choices.size() or index in used:return
	choose(choices[index],index)

func repeat_prompt() -> void: AudioManager.say(target().word_key,alphabet)

func choose(glyph: String,index: int=-1) -> void:
	if state!=State.BUILDING or overlay_paused or focus_paused or filled>=target().letters.size() or glyph not in choices: return
	if index<0:
		for i: int in range(choices.size()):
			if choices[i]==glyph and i not in used:index=i;break
	if index<0 or index in used:return
	var correct: bool=glyph==target().letters[filled]
	ProgressManager.record_answer("syllables",target().id,correct,correct and filled+1==target().letters.size())
	if correct:
		used.append(index)
		filled+=1
		AudioManager.play_sfx("sparkle")
		show_question()
		if filled==target().letters.size(): repeat_prompt()
	else: AudioManager.say("ANIMALS_TRY_AGAIN")

func advance() -> void:
	if state!=State.BUILDING or overlay_paused or focus_paused or filled!=target().letters.size(): return
	if round_index+1==targets.size():
		_show_complete()
	else:
		round_index+=1;filled=0;prepare_tiles()
		show_question();repeat_prompt()

func _show_complete() -> void:
	if session_awarded: return
	state=State.COMPLETE;session_awarded=true
	ProgressManager.record_session_completed("syllables")
	for child: Node in body.get_children(): body.remove_child(child);child.queue_free()
	body.add_child(UiKit.label("PARTY_TITLE",38,UiKit.GREEN))
	var replay := UiKit.button("ANIMALS_REPLAY",start_session,UiKit.MINT,"replay")
	replay.name="Replay"
	var actions := UiKit.row(12);body.add_child(actions);actions.add_child(replay);actions.add_child(UiKit.button("MATERIAL_CHOOSE",choose_material,UiKit.CREAM))
	CompletionCelebration.mount(self)

func get_idle_action() -> Dictionary:
	if state!=State.BUILDING or overlay_paused or focus_paused: return {}
	if filled==target().letters.size(): return {"from":next_button.get_global_rect().get_center()}
	var index := 0
	for i: int in range(choices.size()):
		if i not in used and choices[i]==target().letters[filled]:index=i;break
	var button := options.find_child("Choice_"+str(index),true,false) as Control
	return {"from":button.get_global_rect().get_center()}

func set_overlay_paused(value: bool) -> void: overlay_paused=value
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]: focus_paused=true
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]: focus_paused=false

func choose_material() -> void:
	MaterialPicker.show_for(self,WordCatalog.items(alphabet),func(ids: Array) -> void:
		chosen_word="" if ids.is_empty() else str(ids[0]);start_session()
	)
