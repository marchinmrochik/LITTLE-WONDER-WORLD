extends Control
enum State { READY, ZOOMING, TRACE, REVEAL, RETURNING, PLAY }
var state := State.READY
var parts: Array=[]
var completed: Array[bool]=[]
var part_index := 0
var stroke_index := 0
var trace := GuidedTrace.new()
var board: LivingHouseBoard
var column := UiKit.column(8)
var hint: Label
var counter: Label
var motion: Tween
var fill_reveal := 1.0
var overlay_paused := false
var focus_paused := false
var full_view := Rect2(0,-100,1000,850)
var base_parts := 6
var story_id := "house"
func _ready() -> void:
	story_id=GameManager.living_story
	board=LivingHouseBoard.new() if story_id=="house" else SeasonalDrawingBoard.new()
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/game_content/living_"+story_id+".json"));parts=data.parts
	base_parts=int(data.get("base_parts",6))
	add_child(column);column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := UiKit.row(12);column.add_child(top)
	top.add_child(UiKit.label("LIVE_TITLE",32,UiKit.GREEN));top.add_child(UiKit.spacer())
	counter=UiKit.label("",23,UiKit.GREEN);top.add_child(counter)
	var repeat := UiKit.tool_button("VOICE_TEST",repeat_prompt,"speaker");repeat.name="RepeatPrompt";top.add_child(repeat)
	var replay := UiKit.tool_button("LIVE_REPLAY",restart,"replay");replay.name="Replay";top.add_child(replay)
	hint=UiKit.paragraph("LIVE_TAP",25);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(hint)
	board.game=self;board.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(board)
	board.marker_pressed.connect(zoom_part);board.stroke_finished.connect(finish_stroke);board.progress_changed.connect(board.queue_redraw);board.object_pressed.connect(board.play_object)
	var saved: Dictionary=GameManager.living_drafts.get(story_id,{}).duplicate(true)
	restart()
	if not saved.is_empty():restore_scene(saved)
func part() -> Dictionary:return parts[part_index]
func restart() -> void:
	if overlay_paused or focus_paused:return
	GameManager.living_drafts.erase(story_id)
	if motion!=null:motion.kill()
	board.cancel_pointer();board.effects.clear();board.lit.clear();board.night=false;board.smoke_color=0;board.bark.stop();completed.clear()
	for entry: Dictionary in parts:completed.append(false)
	part_index=0;stroke_index=0;state=State.READY;board.view=full_view;update_labels();repeat_prompt()
func update_labels() -> void:
	if state==State.PLAY:
		hint.text=LocalizationManager.text("LIVE_PLAY" if story_id=="house" else "SEASON_PLAY");counter.text=""
	else:
		hint.text=LocalizationManager.text(part_prompt() if state==State.TRACE else "LIVE_TAP")
		counter.text=""
		if state==State.READY and house_ready():hint.text=LocalizationManager.text("LIVE_EXPLORE")
	board.queue_redraw()
func part_prompt() -> String:return str(part().get("prompt","LIVE_"+str(part().id).to_upper()))
func repeat_prompt() -> void:
	AudioManager.say("LIVE_DONE" if state==State.PLAY else part_prompt() if state==State.TRACE else "LIVE_EXPLORE" if house_ready() else "LIVE_TAP")
func house_ready() -> bool:
	for i: int in range(base_parts):
		if not completed[i]:return false
	return true
func available_parts() -> Array[int]:
	var result: Array[int]=[]
	if not house_ready():
		for i: int in range(base_parts):
			if not completed[i]:result.append(i);break
	else:
		for i: int in range(base_parts,parts.size()):
			if not completed[i]:result.append(i)
	return result
func zoom_part(index: int=-1) -> void:
	if state!=State.READY or overlay_paused or focus_paused:return
	if index>=0:
		if not index in available_parts():return
		part_index=index
	state=State.ZOOMING;board.cancel_pointer();AudioManager.stop_voice()
	var box: Array=part().zoom
	animate_camera(Rect2(box[0],box[1],box[2],box[3]),begin_trace)
func animate_camera(target: Rect2,callback: Callable) -> void:
	if motion!=null:motion.kill()
	motion=create_tween();motion.tween_property(board,"view",target,.08 if SettingsManager.values.reduced_motion else .42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);motion.tween_callback(callback)
func begin_trace() -> void:
	state=State.TRACE;stroke_index=0;configure_stroke();AudioManager.say(part_prompt())
func configure_stroke() -> void:
	trace.configure(part().strokes[stroke_index]);update_labels()
func finish_stroke() -> void:
	if state!=State.TRACE or not trace.complete:return
	if stroke_index+1<part().strokes.size():stroke_index+=1;configure_stroke();AudioManager.play_sfx("tap");return
	state=State.REVEAL;completed[part_index]=true;fill_reveal=0.0;AudioManager.play_sfx("sparkle")
	if motion!=null:motion.kill()
	motion=create_tween();motion.tween_property(self,"fill_reveal",1.0,.12 if SettingsManager.values.reduced_motion else .45);motion.tween_callback(return_to_scene)
func return_to_scene() -> void:
	state=State.RETURNING;animate_camera(full_view,advance_part)
func advance_part() -> void:
	var offered := available_parts()
	if offered.is_empty():finish_house()
	else:
		part_index=offered[0];state=State.READY;update_labels();repeat_prompt()
func finish_house() -> void:
	# This is an open-ended scene, with no task result or completion overlay.
	state=State.PLAY;update_labels();AudioManager.say("LIVE_DONE")
func get_idle_action() -> Dictionary:
	if overlay_paused or focus_paused:return {}
	if state==State.READY:
		var pair: Array=part().marker;return {"from":board.global_position+board.from_world(Vector2(pair[0],pair[1]))}
	if state==State.TRACE:
		return {"from":board.global_position+board.from_world(trace.current_point()),"to":board.global_position+board.from_world(trace.points[trace.edge+1])}
	if state==State.PLAY:return {"from":board.global_position+board.from_world(Vector2(parts[0].marker[0],parts[0].marker[1]))}
	return {}
func set_overlay_paused(value: bool) -> void:overlay_paused=value;sync_pause()
func sync_pause() -> void:
	board.cancel_pointer()
	board.bark.stream_paused=overlay_paused or focus_paused
	if motion!=null and motion.is_valid():
		if overlay_paused or focus_paused:motion.pause()
		else:motion.play()
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]:focus_paused=true
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_APPLICATION_RESUMED]:focus_paused=false
	else:return
	if is_instance_valid(board):sync_pause()
func _exit_tree() -> void:
	if motion!=null:motion.kill()
	board.cancel_pointer()
	GameManager.living_drafts[story_id]={"completed":completed.duplicate(),"part":part_index,"stroke":stroke_index,"edge":trace.edge,"fraction":trace.fraction,"tracing":state==State.TRACE,"night":board.night,"smoke":board.smoke_color,"lit":board.lit.duplicate()}

func restore_scene(saved: Dictionary) -> void:
	completed.assign(saved.completed);part_index=saved.part;board.night=saved.night;board.smoke_color=saved.smoke;board.lit=saved.lit.duplicate()
	if saved.tracing and not completed[part_index]:
		state=State.TRACE;stroke_index=saved.stroke;configure_stroke();trace.edge=mini(saved.edge,trace.points.size()-2);trace.fraction=saved.fraction
		var box: Array=part().zoom;board.view=Rect2(box[0],box[1],box[2],box[3]);update_labels();repeat_prompt()
	else:advance_part()

func handle_back() -> bool:
	GameManager.navigate("living_gallery");return true
