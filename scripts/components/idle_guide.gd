class_name IdleGuide
extends Control

const WAIT_SECONDS := 10.0
var app: Control
var idle := 0.0
var age := 0.0
var action: Dictionary = {}
var contacts: Dictionary = {}
var finger: Texture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	finger = preload("res://assets/ui/finger.svg")

func reset() -> void:
	idle = 0
	age = 0
	action.clear()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed: contacts[event.index] = true
		else: contacts.erase(event.index)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: contacts[-1] = true
		else: contacts.erase(-1)
	if event is InputEventMouseMotion and event.relative.length() < 1:
		return
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventKey or event is InputEventPanGesture:
		reset()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]:
		contacts.clear()
		reset()

func _process(delta: float) -> void:
	if app == null or app.suspended or is_instance_valid(app.modal) or not contacts.is_empty() or AudioManager.voice.playing:
		reset()
		return
	if not action.is_empty():
		age += delta
		if age >= 3.0: reset()
		queue_redraw()
		return
	idle += delta
	if idle >= WAIT_SECONDS:
		action = next_action()
		if not action.is_empty() and is_instance_valid(app.current_view) and app.current_view.has_method("on_idle_hint_shown"):
			app.current_view.on_idle_hint_shown()
		idle = 0
		age = 0
		queue_redraw()

func tap(node: Control) -> Dictionary:
	if not is_instance_valid(node) or not node.is_visible_in_tree() or (node is BaseButton and node.disabled):
		return {}
	var point := node.get_global_rect().get_center()
	return {"from":point} if get_viewport_rect().has_point(point) else {}

func drag_action(source: Control, target: Control) -> Dictionary:
	var result := tap(source)
	var end := tap(target)
	if result.is_empty() or end.is_empty(): return {}
	result["to"] = end.from
	return result

func next_action() -> Dictionary:
	var v: Variant = app.current_view
	if not is_instance_valid(v): return {}
	var party: Node = v.get_node_or_null("CompletionParty")
	if party != null: return party.get_idle_action()
	if v.has_method("tracing_idle_action") and v.get("tracing_mode")==true:return v.tracing_idle_action()
	if v.has_method("get_idle_action"): return v.get_idle_action()
	if v.get("overlay_paused") == true or v.get("focus_paused") == true: return {}
	var route: String = GameManager.current_route
	if route == "home": return tap(v.find_child("PlayButton",true,false))
	if route in ["settings","gallery"]: return {}
	if route == "drawing":
		if is_instance_valid(v.gallery): return {}
		var rect: Rect2 = v.canvas.get_global_rect()
		return {"from":rect.get_center()-Vector2(70,0),"to":rect.get_center()+Vector2(70,0)}
	if route == "coloring":
		if is_instance_valid(v.gallery): return {}
		for region: Dictionary in v.document().page.regions:
			if v.document().colors[region.id] == "ffffff":
				var rect: Rect2 = v.canvas.image_rect()
				return {"from":v.canvas.global_position+rect.position+region.tap/Vector2(1024,640)*rect.size}
		return tap(v.next)
	if route == "xylophone": return {"from":v.keyboard.global_position+v.keyboard.key_rect(0).get_center()}
	if route == "meadow": return tap(v.find_child("SAY_HELLO",true,false))
	if route in ["animals","colors"]:
		if v.state == v.State.EXPLORE:
			var cards: Array[Node] = v.body.find_children("Animal_*","Button",true,false)
			return tap(cards[0]) if not cards.is_empty() else {}
		if v.state == v.State.QUESTION: return tap(v.body.find_child("Animal_"+v.model.target,true,false))
	elif route == "feeding" and v.state == v.State.QUESTION:
		return drag_action(v.body.find_child("Food_"+v.model.target,true,false),v.drop_zone)
	elif route == "shapes" and v.state == v.State.SORTING:
		for id: String in v.model.sources:
			if id not in v.model.placed: return drag_action(v.source_cards[id],v.slots[id])
	elif route == "puzzles":
		if v.state == v.State.BUILDING:
			for piece: int in v.model.tray_order:
				if piece not in v.model.placed: return drag_action(v.source_cards[piece],v.slots[piece])
		elif v.state == v.State.PICTURE_DONE: return tap(v.next_button)
	elif route == "memory" and v.state == v.State.CHOOSING:
		for index: int in range(v.cards.size()):
			if index not in v.model.matched and index != v.model.first: return tap(v.cards[index])
	elif route == "counting" and v.state == v.State.QUESTION:
		if v.model.mode == "choice": return tap(v.body.find_child("Number_"+str(v.model.target),true,false))
		if v.model.in_basket.size() == v.model.target: return tap(v.body.find_child("CheckBasket",true,false))
		if v.model.in_basket.size() > v.model.target: return tap(v.body.find_child("Stored_"+str(v.model.in_basket.back()),true,false))
		for id: int in v.source_cards:
			if id not in v.model.in_basket: return drag_action(v.source_cards[id],v.drop_zone)
	return tap(v.find_child("Replay",true,false))

func _draw() -> void:
	if action.is_empty() or finger == null: return
	var start: Vector2 = action.from
	var end: Vector2 = action.get("to",start)
	var progress := 0.0 if SettingsManager.values.reduced_motion else clampf((age-0.4)/1.8,0,1)
	if start != end:
		draw_line(start,end,Color(1,0.96,0.8,0.7),7,true)
		draw_circle(end,13,Color("e8b04d"),false,4,true)
	var point := start.lerp(end,progress)
	draw_circle(point,24,Color(1,0.88,0.5,0.7),false,4,true)
	draw_texture_rect(finger,Rect2(point-Vector2(29,13),Vector2(76,76)),false)
