extends Control
var body := UiKit.column(6)
var area := Control.new()
var balloons: Array[PartyBalloon] = []
var popped := 0
var generation := 0
var overlay_paused := false
var focus_paused := false
var flights: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var age := 0.0
var timed := false
var round_over := false
var remaining := 60.0
var run_difficulty := "normal"
var counter: Label
var result_panel: Control
var status_elapsed := 0.0
var mode_hint: Label
var mode_buttons: Dictionary={}

func _ready() -> void:
	rng.randomize()
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := UiKit.row(12);body.add_child(top)
	var title := UiKit.label("BALLOONS_TITLE",28,UiKit.GREEN);top.add_child(title);top.add_child(UiKit.spacer())
	mode_buttons[false]=UiKit.button("BALLOON_FREE",start_mode.bind(false),UiKit.MINT);mode_buttons[true]=UiKit.button("BALLOON_CHALLENGE",start_mode.bind(true),UiKit.CREAM)
	for button: ChildButton in mode_buttons.values():button.custom_minimum_size.y=52;button.add_theme_font_size_override("font_size",21);top.add_child(button)
	var info := UiKit.row(8);body.add_child(info)
	mode_hint=UiKit.label("BALLOONS_HINT",20,UiKit.MUTED);mode_hint.size_flags_horizontal=Control.SIZE_EXPAND_FILL;mode_hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;info.add_child(mode_hint)
	counter=UiKit.label("",22,UiKit.GREEN);counter.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;info.add_child(counter)
	area.size_flags_vertical=Control.SIZE_EXPAND_FILL
	area.custom_minimum_size=Vector2(600,240)
	area.clip_contents=true
	body.add_child(area)
	for i: int in range(12):
		var balloon := PartyBalloon.new()
		balloon.name="FreeBalloon_"+str(i)
		balloon.pop_requested.connect(pop.bind(i))
		area.add_child(balloon)
		balloons.append(balloon)
		flights.append({})
	area.resized.connect(layout_balloons)
	# Containers must finish sizing before distributing the initial flights.
	await get_tree().process_frame
	new_set()

func spawn(index: int,initial: bool=false) -> void:
	var balloon := balloons[index]
	balloon.size=Vector2.ONE*rng.randf_range(145.0,185.0)
	balloon.popped=false
	balloon.visible=true
	balloon.color=CompletionCelebration.COLORS[rng.randi_range(0,5)]
	var x := rng.randf_range(0.0,maxf(0.0,area.size.x-balloon.size.x))
	var y := rng.randf_range(area.size.y*.45,maxf(area.size.y*.45,area.size.y-balloon.size.y*.6)) if initial else area.size.y+rng.randf_range(10.0,90.0)
	flights[index]={"x":x,"y":y,"speed":rng.randf_range(58.5,99.0),"phase":rng.randf_range(0.0,TAU),"wait":0.0,"burst":0.0}
	balloon.position=Vector2(x,y)
	balloon.scale=Vector2.ONE
	balloon.modulate=Color.WHITE
	balloon.queue_redraw()

func new_set() -> void:
	generation+=1;popped=0;remaining=60;age=0;round_over=false;run_difficulty=SettingsManager.values.difficulty
	if is_instance_valid(result_panel):result_panel.queue_free()
	for i: int in range(balloons.size()):
		if not timed or i<4:spawn(i,true)
		else:flights[i]={};balloons[i].hide()
	update_counter()

func layout_balloons() -> void:
	for i: int in range(balloons.size()):
		if flights[i].is_empty():continue
		flights[i].x=clampf(flights[i].x,0.0,maxf(0.0,area.size.x-balloons[i].size.x))
		flights[i].y=minf(flights[i].y,area.size.y+90.0)

func _process(delta: float) -> void:
	if overlay_paused or focus_paused or round_over:return
	age+=delta
	if timed:
		remaining=maxf(0,remaining-delta)
		if remaining<=0:finish_challenge();return
		var wanted := mini(12,4+int(age/7.5))
		for i: int in range(wanted):
			if flights[i].is_empty():spawn(i)
	status_elapsed+=delta
	if status_elapsed>.15:status_elapsed=0;update_counter()
	for i: int in range(balloons.size()):
		var balloon := balloons[i]
		var flight := flights[i]
		if flight.is_empty():continue
		if balloon.popped:
			flight.wait-=delta
			flight.burst+=delta
			balloon.burst_progress=clampf(flight.burst/0.25,0.0,1.0)
			balloon.queue_redraw()
			if flight.wait<=0.0:spawn(i)
			continue
		var pace: float=1.0 if not timed else (.85+minf(1.0,age/60.0)*.65)*{"easy":.85,"normal":1.0,"advanced":1.15}[run_difficulty]
		flight.y-=flight.speed*delta*pace
		var sway := 0.0 if SettingsManager.values.reduced_motion else sin(age*1.1+flight.phase)*12.0
		balloon.position=Vector2(clampf(flight.x+sway,0.0,maxf(0.0,area.size.x-balloon.size.x)),flight.y)
		if balloon.position.y+balloon.size.y<0.0:spawn(i)

func pop(index: int) -> void:
	if round_over or overlay_paused or focus_paused or index<0 or index>=balloons.size() or not balloons[index].visible or balloons[index].popped: return
	balloons[index].popped=true;balloons[index].queue_redraw()
	popped+=1
	AudioManager.play_sfx("balloon_pop")
	balloons[index].burst_progress=0.0
	flights[index].wait=rng.randf_range(0.35,0.8) if not timed else lerpf(.65,.15,minf(1.0,age/60.0))
	update_counter()
	flights[index].burst=0.0

func get_idle_action() -> Dictionary:
	if round_over or overlay_paused or focus_paused: return {}
	for balloon: PartyBalloon in balloons:
		if balloon.visible and not balloon.popped and area.get_global_rect().has_point(balloon.global_position+balloon.balloon_rect().get_center()): return {"from":balloon.global_position+balloon.balloon_rect().get_center()}
	return {}

func set_overlay_paused(value: bool) -> void:
	overlay_paused=value

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]: focus_paused=true
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]: focus_paused=false
	else: return


func start_mode(challenge: bool) -> void:
	if overlay_paused or focus_paused:return
	timed=challenge
	mode_hint.text=LocalizationManager.text("BALLOON_HINT_CHALLENGE" if timed else "BALLOONS_HINT")
	for mode: bool in mode_buttons:mode_buttons[mode].add_theme_stylebox_override("normal",UiKit.panel(UiKit.MINT if mode==timed else UiKit.CREAM,18,12))
	new_set()
func update_counter() -> void:
	counter.text="● "+str(popped)
	counter.tooltip_text=LocalizationManager.text("BALLOON_SCORE").format({"score":popped})
	if timed:counter.text+="  ·  "+str(ceili(remaining))+" "+LocalizationManager.text("SECONDS_SHORT")
func finish_challenge() -> void:
	if round_over or not timed:return
	round_over=true;remaining=0;update_counter()
	for balloon: PartyBalloon in balloons:balloon.hide()
	var saved := BalloonRecords.record(popped,run_difficulty)
	result_panel=UiKit.card();area.add_child(result_panel);result_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);result_panel.offset_left=150;result_panel.offset_right=-150;result_panel.offset_top=8;result_panel.offset_bottom=-8
	var column := UiKit.column(6);result_panel.add_child(column)
	column.add_child(UiKit.label("BALLOON_RESULT",28,UiKit.GREEN));column.add_child(UiKit.label(counter.text,25))
	column.add_child(UiKit.label("BALLOON_RECORDS",22,UiKit.GREEN))
	var rows := BalloonRecords.top(run_difficulty)
	var table_scroll := TouchScroll.new();table_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;table_scroll.custom_minimum_size.y=65;column.add_child(table_scroll)
	var table := UiKit.column(4);table.size_flags_horizontal=Control.SIZE_EXPAND_FILL;table_scroll.add_child(table)
	for i: int in range(rows.size()):table.add_child(UiKit.label(str(i+1)+".  "+str(int(rows[i].score)),22))
	if not saved:column.add_child(UiKit.label("BALLOON_SAVE_ERROR",19))
	var actions := UiKit.row(10);column.add_child(actions);actions.add_child(UiKit.button("ANIMALS_REPLAY",new_set,UiKit.MINT,"replay"));actions.add_child(UiKit.button("BALLOON_FREE",start_mode.bind(false),UiKit.CREAM))
	AudioManager.play_sfx("sparkle")
