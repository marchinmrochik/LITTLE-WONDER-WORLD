class_name CompletionCelebration
extends Control

const COLORS := [Color("d85e63"),Color("e8b94e"),Color("80b280"),Color("67adba"),Color("9980bc"),Color("d893b6")]
var game: Control
var balloons: Array[PartyBalloon] = []
var popped: Dictionary = {}
var area := Control.new()
var counter: Label
var elapsed := 0.0
var finished := false
var covered: Array[Control] = []
var pops: Array[Dictionary] = []

static func mount(view: Control) -> void:
	if view.has_node("CompletionParty"): return
	var party := CompletionCelebration.new()
	party.name="CompletionParty"
	party.game=view
	for child: Node in view.get_children():
		if child is Control and child.visible:
			party.covered.append(child)
			child.hide()
	view.add_child(party)
	party.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

static func clear(view: Control) -> void:
	var party := view.get_node_or_null("CompletionParty")
	if party != null:
		party.restore_controls()
		view.remove_child(party)
		party.queue_free()

func restore_controls() -> void:
	for control: Control in covered:
		if is_instance_valid(control): control.show()

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_STOP
	z_index=10
	var background := Panel.new()
	background.add_theme_stylebox_override("panel",UiKit.panel(Color("f8f7e5"),30,0))
	background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Draw bursts above the background but behind the touch targets.
	var burst := BurstCanvas.new()
	burst.party=self
	burst.z_index=2
	burst.clip_contents=true
	add_child(burst)
	burst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := UiKit.column(8)
	add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("PARTY_TITLE",40,UiKit.GREEN)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var hint := UiKit.label("PARTY_HINT",26,UiKit.INK)
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
	area.size_flags_vertical=Control.SIZE_EXPAND_FILL
	area.custom_minimum_size=Vector2(600,300)
	column.add_child(area)
	counter=UiKit.label("",25,UiKit.GREEN)
	counter.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(counter)
	for index: int in range(COLORS.size()):
		var balloon := PartyBalloon.new()
		balloon.name="Balloon_"+str(index)
		balloon.color=COLORS[index]
		balloon.pop_requested.connect(pop_balloon.bind(index))
		area.add_child(balloon)
		balloons.append(balloon)
	area.resized.connect(_layout_balloons)
	_layout_balloons()
	_update_counter()
	AudioManager.say("PARTY_INTRO")

func paused() -> bool:
	var app := get_tree().get_first_node_in_group("app_root")
	return game.get("overlay_paused")==true or game.get("focus_paused")==true or (app != null and app.suspended)

func _layout_balloons() -> void:
	var cell := area.size/Vector2(3,2)
	for index: int in range(balloons.size()):
		balloons[index].position=Vector2(index%3,index/3)*cell
		balloons[index].size=cell

func _process(delta: float) -> void:
	if paused(): return
	var had_pops := not pops.is_empty()
	for i: int in range(pops.size()-1,-1,-1):
		pops[i].age += delta
		if pops[i].age >= 0.35: pops.remove_at(i)
	if elapsed < 2.4:
		elapsed += delta
		get_child(1).queue_redraw()
	elif had_pops: get_child(1).queue_redraw()

func pop_balloon(index: int) -> void:
	if finished or paused() or index<0 or index>=balloons.size() or popped.has(index): return
	popped[index]=true
	balloons[index].popped=true
	balloons[index].queue_redraw()
	pops.append({"point":balloons[index].global_position+balloons[index].balloon_rect().get_center()-global_position,"age":0.0,"color":COLORS[index]})
	get_child(1).queue_redraw()
	AudioManager.play_sfx("balloon_pop")
	_update_counter()
	if popped.size()==balloons.size():
		finished=true
		AudioManager.say("FOX_HAPPY")
		# The existing result screen and replay controls appear only after all six.
		restore_controls()
		get_parent().remove_child(self)
		queue_free()

func _update_counter() -> void:
	counter.text=LocalizationManager.text("PARTY_REMAINING").format({"count":balloons.size()-popped.size()})

func get_idle_action() -> Dictionary:
	for index: int in range(balloons.size()):
		if not popped.has(index):
			return {"from":balloons[index].global_position+balloons[index].balloon_rect().get_center()}
	return {}

class BurstCanvas extends Control:
	var party: CompletionCelebration
	func _ready() -> void:
		mouse_filter=Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var reduced: bool=SettingsManager.values.reduced_motion
		for pop: Dictionary in party.pops:
			var progress: float=pop.age/0.35
			var color: Color=pop.color
			color.a=1-progress
			for ray: int in range(8):
				var direction := Vector2.from_angle(TAU*ray/8.0)
				var radius := 20.0 if reduced else 15+progress*55
				draw_line(pop.point+direction*radius*0.6,pop.point+direction*radius,color,4,true)
		if not reduced and party.elapsed>=2.4: return
		for burst: int in range(3):
			var t := 0.6 if reduced else clampf((party.elapsed-burst*0.25)/1.5,0,1)
			if t<=0 or t>=1: continue
			var center := size*Vector2([0.18,0.5,0.82][burst],0.3 if burst%2==0 else 0.6)
			var radius := 25+t*105
			for ray: int in range(12):
				var direction := Vector2.from_angle(TAU*ray/12.0)
				var color: Color=CompletionCelebration.COLORS[(ray+burst)%6]
				color.a=0.55 if reduced else (1-t)*0.8
				draw_line(center+direction*radius*0.65,center+direction*radius,color,5,true)
