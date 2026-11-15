extends Control
enum State { EXPLORE, QUESTION, FEEDBACK, COMPLETE }
var state := State.EXPLORE
var body := UiKit.column(12)
var topic: Dictionary
var entries: Array[Dictionary] = []
var questions: Array[String] = []
var index := 0
var attempts := 0
var first_correct := false
var assisted := false
var session_id := ""
var session_awarded := false
var overlay_paused := false
var focus_paused := false
var options: Array[String] = []
var feedback_timer := Timer.new()
var board: WorldBodyBoard
var message: Label
var selected := ""
var explore_face := false
var explore_hand := false

func _ready() -> void:
	topic=WorldCatalog.topic(GameManager.world_topic)
	if topic.is_empty():GameManager.world_topic="animals";topic=WorldCatalog.topic("animals")
	entries=WorldCatalog.items(GameManager.world_topic)
	add_child(body);body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_timer.one_shot=true;feedback_timer.wait_time=0.45;add_child(feedback_timer)
	feedback_timer.timeout.connect(next_question)
	show_explore()

func _clear_body() -> void:
	CompletionCelebration.clear(self)
	feedback_timer.stop()
	for child: Node in body.get_children():body.remove_child(child);child.queue_free()
	board=null;message=null

func controls() -> void:
	var top := UiKit.row(12);body.add_child(top)
	var explore := UiKit.button("WORLD_EXPLORE",show_explore,UiKit.CREAM,"wave")
	explore.name="ExploreMode";top.add_child(explore)
	var check := UiKit.button("WORLD_CHECK",start_check,UiKit.MINT,"search")
	check.name="CheckMode";top.add_child(check)
	if state==State.EXPLORE and topic.kind=="body":
		for id: String in ["boy","girl"]:
			var person := UiKit.button("",select_character.bind(id),UiKit.MINT if SettingsManager.values.body_character==id else UiKit.CREAM)
			var definition := BodyCharacterCatalog.definition(id)
			var crop: Array=definition.face
			var portrait := AtlasTexture.new();portrait.atlas=load(definition.texture);portrait.region=Rect2(crop[0],crop[1],crop[2],crop[3])
			person.icon=portrait;person.expand_icon=true;person.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;person.add_theme_constant_override("icon_max_width",54);person.custom_minimum_size=Vector2(84,64)
			person.tooltip_text=LocalizationManager.text("BODY_"+id.to_upper())
			person.name="Character_"+id;top.add_child(person)
	if state==State.EXPLORE and not selected.is_empty():
		var entry := WorldCatalog.item(topic.id,selected)
		var repeat := UiKit.button("",AudioManager.say.bind(entry.word_key),UiKit.MINT,"speaker")
		repeat.name="RepeatWord";repeat.tooltip_text=LocalizationManager.object_name(entry);top.add_child(repeat)
	top.add_child(UiKit.spacer());top.add_child(UiKit.label(topic.title_key,30,UiKit.GREEN))

func show_explore() -> void:
	interrupt_check()
	AudioManager.stop_voice();state=State.EXPLORE
	_clear_body();controls()
	var hint := UiKit.paragraph("WORLD_BODY_TAP" if topic.kind=="body" else "WORLD_TAP",24)
	if topic.kind=="body" and not selected.is_empty():hint.text=LocalizationManager.object_name(WorldCatalog.item(topic.id,selected))
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(hint)
	options.clear()
	if topic.kind=="body":
		show_body(explore_face,true)
		board.zoom_hand=explore_hand
		var zoom := UiKit.button("WORLD_ZOOM",toggle_zoom,UiKit.MINT,"search")
		var zooms := UiKit.row(12);body.add_child(zooms)
		zoom.name="ZoomBody";zooms.add_child(zoom)
		var hand_zoom := UiKit.button("WORLD_HAND_ZOOM",toggle_hand_zoom,UiKit.MINT,"search")
		hand_zoom.name="ZoomHands";zooms.add_child(hand_zoom)
	else:show_cards(entries,4)

func select_character(id: String) -> void:
	if state!=State.EXPLORE or overlay_paused or focus_paused or id not in ["boy","girl"]:return
	SettingsManager.set_value("body_character",id);entries=WorldCatalog.items("body");selected="";show_explore()
func toggle_zoom() -> void:
	explore_face=not explore_face;explore_hand=false;selected="";show_explore()
func toggle_hand_zoom() -> void:
	explore_hand=not explore_hand;explore_face=false;selected="";show_explore()
func show_body(face: bool,mark: bool) -> void:
	board=WorldBodyBoard.new();board.entries=entries;board.selected_id=selected if state==State.EXPLORE else "";board.zoom_face=face;board.markers=mark;board.active_ids=options.duplicate()
	board.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(board)
	board.part_pressed.connect(choose)

func show_cards(items: Array[Dictionary],columns: int) -> void:
	var center := CenterContainer.new();center.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(center)
	var grid := GridContainer.new();grid.columns=columns
	grid.add_theme_constant_override("h_separation",14);grid.add_theme_constant_override("v_separation",10);center.add_child(grid)
	for entry: Dictionary in items:
		var button := UiKit.button("",choose.bind(entry.id),UiKit.CREAM)
		button.name="WorldItem_"+entry.id;button.custom_minimum_size=Vector2(200,130)
		grid.add_child(button)
		var column := UiKit.column(4);button.add_child(column);column.mouse_filter=Control.MOUSE_FILTER_IGNORE
		column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);column.offset_top=8;column.offset_bottom=-8;column.offset_left=8;column.offset_right=-8
		var picture := TextureRect.new();picture.texture=load(entry.illustration);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.custom_minimum_size=Vector2(120,74);picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
		column.add_child(picture)
		var label := UiKit.label("",23);label.text=LocalizationManager.object_name(entry);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(label)

func start_check() -> void:
	interrupt_check();session_awarded=false;index=0
	questions.assign(topic.check_items);questions.shuffle()
	session_id=AssessmentHistory.begin_check(topic.id,int(topic.revision),SettingsManager.values.locale,SettingsManager.values.difficulty,questions)
	show_question()

func target() -> Dictionary:return WorldCatalog.item(topic.id,questions[index])
func show_question() -> void:
	state=State.QUESTION;attempts=0;first_correct=false;assisted=false
	_clear_body();controls()
	var prompt := UiKit.row(12);prompt.alignment=BoxContainer.ALIGNMENT_CENTER;body.add_child(prompt)
	message=UiKit.label(target().prompt_key,32,UiKit.GREEN);prompt.add_child(message)
	var repeat := UiKit.button("",repeat_prompt,UiKit.MINT,"speaker");repeat.name="RepeatPrompt";prompt.add_child(repeat)
	options=[target().id]
	var candidates := entries.duplicate();candidates.shuffle()
	var count: int={"easy":2,"normal":3,"advanced":4}[SettingsManager.values.difficulty]
	for entry: Dictionary in candidates:
		if options.size()>=count:break
		if entry.id in options:continue
		if topic.kind=="body" and entry.view!=target().view:continue
		options.append(entry.id)
	options.shuffle()
	if topic.kind=="body":show_body(target().view=="face",true)
	else:
		var cards: Array[Dictionary]=[]
		for id: String in options:cards.append(WorldCatalog.item(topic.id,id))
		show_cards(cards,count)
	var progress := UiKit.label("",24,UiKit.GREEN)
	progress.text=LocalizationManager.text("WORLD_PROGRESS").format({"current":index+1,"total":5});progress.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;body.add_child(progress)
	repeat_prompt()

func repeat_prompt() -> void:
	if state==State.QUESTION:AudioManager.say(target().prompt_key)
func choose(id: String) -> void:
	if overlay_paused or focus_paused:return
	if WorldCatalog.item(topic.id,id).is_empty():return
	if state==State.EXPLORE:
		selected=id
		var entry := WorldCatalog.item(topic.id,id)
		if topic.kind=="body":
			if entry.view=="face":explore_face=true;explore_hand=false
			elif id in ["hand","finger"]:explore_hand=true;explore_face=false
			else:explore_face=false;explore_hand=false
		show_explore();AudioManager.say(entry.word_key);return
	if state!=State.QUESTION or id not in options:return
	attempts+=1
	var correct: bool=id==target().id
	if attempts==1:first_correct=correct
	AssessmentHistory.record(session_id,target().id,first_correct,assisted,attempts,correct)
	if correct:
		if index==4:AssessmentHistory.finish(session_id,true)
		state=State.FEEDBACK
		AudioManager.play_sfx("sparkle");AudioManager.say("ANIMALS_CORRECT")
		feedback_timer.start()
	else:AudioManager.say("ANIMALS_TRY_AGAIN")

func on_idle_hint_shown() -> void:
	if state!=State.QUESTION:return
	assisted=true
	if attempts>0:AssessmentHistory.record(session_id,target().id,first_correct,true,attempts,false)

func next_question() -> void:
	if state!=State.FEEDBACK:return
	feedback_timer.stop()
	if index==4:_show_complete()
	else:index+=1;show_question()

func _show_complete() -> void:
	if session_awarded:return
	state=State.COMPLETE;session_awarded=true
	AssessmentHistory.finish(session_id,true);session_id=""
	_clear_body()
	body.add_child(UiKit.label("PARTY_TITLE",38,UiKit.GREEN))
	var replay := UiKit.button("WORLD_CHECK",start_check,UiKit.MINT,"replay");replay.name="Replay";body.add_child(replay)
	body.add_child(UiKit.button("WORLD_EXPLORE",show_explore,UiKit.CREAM,"wave"))
	CompletionCelebration.mount(self)

func interrupt_check() -> void:
	if not session_id.is_empty():AssessmentHistory.finish(session_id,false);session_id=""
func get_idle_action() -> Dictionary:
	if overlay_paused or focus_paused:return {}
	if state==State.EXPLORE:
		if board!=null:return {"from":board.anchor("finger" if explore_hand else "nose" if explore_face else "head")}
		return {"from":find_child("WorldItem_"+entries[0].id,true,false).get_global_rect().get_center()}
	if state==State.QUESTION:
		if board!=null:return {"from":board.anchor(target().id)}
		return {"from":find_child("WorldItem_"+target().id,true,false).get_global_rect().get_center()}
	return {}
func set_overlay_paused(value: bool) -> void:
	overlay_paused=value;feedback_timer.paused=overlay_paused or focus_paused
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:focus_paused=true
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]:focus_paused=false
	else:return
	if is_instance_valid(feedback_timer):feedback_timer.paused=overlay_paused or focus_paused
func _exit_tree() -> void:interrupt_check()
