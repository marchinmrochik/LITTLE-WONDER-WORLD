extends Control
var body := UiKit.column(12)
var area := Control.new()
var balloons: Array[PartyBalloon] = []
var popped := 0
var generation := 0
var overlay_paused := false
var focus_paused := false
var flights: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var age := 0.0

func _ready() -> void:
	rng.randomize()
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("BALLOONS_TITLE",38,UiKit.GREEN)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(title)
	var hint := UiKit.label("BALLOONS_HINT",26,UiKit.GREEN)
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(hint)
	area.size_flags_vertical=Control.SIZE_EXPAND_FILL
	area.custom_minimum_size=Vector2(600,300)
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
	var y := rng.randf_range(0.0,maxf(0.0,area.size.y-balloon.size.y)) if initial else area.size.y+rng.randf_range(10.0,90.0)
	flights[index]={"x":x,"y":y,"speed":rng.randf_range(58.5,99.0),"phase":rng.randf_range(0.0,TAU),"wait":0.0,"burst":0.0}
	balloon.position=Vector2(x,y)
	balloon.scale=Vector2.ONE
	balloon.modulate=Color.WHITE
	balloon.queue_redraw()

func new_set() -> void:
	generation+=1;popped=0
	for i: int in range(balloons.size()):spawn(i,true)

func layout_balloons() -> void:
	for i: int in range(balloons.size()):
		if flights[i].is_empty():continue
		flights[i].x=clampf(flights[i].x,0.0,maxf(0.0,area.size.x-balloons[i].size.x))
		flights[i].y=minf(flights[i].y,area.size.y+90.0)

func _process(delta: float) -> void:
	if overlay_paused or focus_paused:return
	age+=delta
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
		flight.y-=flight.speed*delta
		var sway := 0.0 if SettingsManager.values.reduced_motion else sin(age*1.1+flight.phase)*12.0
		balloon.position=Vector2(clampf(flight.x+sway,0.0,maxf(0.0,area.size.x-balloon.size.x)),flight.y)
		if balloon.position.y+balloon.size.y<0.0:spawn(i)

func pop(index: int) -> void:
	if overlay_paused or focus_paused or index<0 or index>=balloons.size() or balloons[index].popped: return
	balloons[index].popped=true;balloons[index].queue_redraw()
	popped+=1
	AudioManager.play_sfx("balloon_pop")
	balloons[index].burst_progress=0.0
	flights[index].wait=rng.randf_range(0.35,0.8)
	flights[index].burst=0.0

func get_idle_action() -> Dictionary:
	if overlay_paused or focus_paused: return {}
	for balloon: PartyBalloon in balloons:
		if not balloon.popped and area.get_global_rect().has_point(balloon.global_position+balloon.balloon_rect().get_center()): return {"from":balloon.global_position+balloon.balloon_rect().get_center()}
	return {}

func set_overlay_paused(value: bool) -> void:
	overlay_paused=value

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]: focus_paused=true
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]: focus_paused=false
	else: return

