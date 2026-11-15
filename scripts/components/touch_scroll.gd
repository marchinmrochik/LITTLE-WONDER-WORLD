class_name TouchScroll
extends ScrollContainer
# Own gestures before child controls. A stationary release is forwarded as one click;
# a pan never reaches the button underneath. Sliders retain horizontal gestures.
var interaction_enabled := true
var horizontal := false
var dragging := false
var pointer_owner := -2
var contacts: Dictionary={}
var origin := Vector2.ZERO
var last_point := Vector2.ZERO
var origin_scroll := 0.0
var offset := 0.0
var velocity := 0.0
var last_time := 0
var suppress_tap := false
var forwarding := false
var slider: HSlider
var sliding := false
var suspended := false
const DEADZONE := 10.0

func allowed() -> bool:
	if not interaction_enabled or suspended or not is_visible_in_tree():return false
	var app: Variant=get_tree().get_first_node_in_group("app_root")
	if app!=null and is_instance_valid(app.modal) and not app.modal.is_ancestor_of(self):return false
	return true
func slider_at(node: Node,point: Vector2) -> HSlider:
	if node is HSlider and node.is_visible_in_tree() and node.get_global_rect().has_point(point):return node
	for child: Node in node.get_children():
		var found := slider_at(child,point)
		if found!=null:return found
	return null
func _input(event: InputEvent) -> void:
	if forwarding:return
	if not allowed():cancel_gesture();return
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:
		if pointer_owner!=-2 or get_global_rect().has_point(event.position):get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and get_global_rect().has_point(event.position):
		velocity=0.0;write_offset(read_offset()+(80.0 if event.button_index==MOUSE_BUTTON_WHEEL_DOWN else -80.0)*event.factor);get_viewport().set_input_as_handled();return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:begin(-1,event.position)
		elif pointer_owner==-1:finish(-1,event.position,false)
	elif event is InputEventMouseMotion and pointer_owner==-1:move_pointer(event.position,0.0)
	elif event is InputEventScreenTouch:
		if event.pressed:
			if get_global_rect().has_point(event.position):
				contacts[event.index]=true
				if contacts.size()==1:begin(event.index,event.position)
				else:suppress_tap=true;velocity=0.0;get_viewport().set_input_as_handled()
		elif contacts.has(event.index):
			contacts.erase(event.index)
			if event.index==pointer_owner:finish(event.index,event.position,event.canceled)
			else:get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and contacts.has(event.index):
		if event.index==pointer_owner:move_pointer(event.position,-(event.velocity.x if horizontal else event.velocity.y))
		else:get_viewport().set_input_as_handled()
func begin(id: int,point: Vector2) -> void:
	if pointer_owner!=-2 or not get_global_rect().has_point(point):return
	# Keep native scrollbar thumbs available for desktop users.
	if id==-1 and active_bar().is_visible_in_tree() and active_bar().get_global_rect().has_point(point):return
	pointer_owner=id;origin=point;last_point=point;origin_scroll=read_offset();offset=origin_scroll
	suppress_tap=absf(velocity)>80.0;velocity=0.0;dragging=false;sliding=false;last_time=Time.get_ticks_msec();slider=slider_at(self,point)
	get_viewport().set_input_as_handled()
func move_pointer(point: Vector2,sample_velocity: float) -> void:
	get_viewport().set_input_as_handled()
	var distance := point-origin
	if not dragging and not sliding and distance.length()>DEADZONE:
		if not horizontal and is_instance_valid(slider) and absf(distance.x)>absf(distance.y)*1.25:
			sliding=true;forward_button(origin,true)
		else:dragging=true
	if sliding:forward_motion(point,point-last_point)
	elif dragging:
		var now := Time.get_ticks_msec()
		if sample_velocity==0.0:sample_velocity=(coordinate(last_point)-coordinate(point))/maxf((now-last_time)/1000.0,0.008)
		velocity=lerpf(velocity,clampf(sample_velocity,-2200.0,2200.0),0.55)
		write_offset(origin_scroll+coordinate(origin)-coordinate(point));last_time=now
	last_point=point
func finish(id: int,point: Vector2,canceled: bool) -> void:
	if id!=pointer_owner:return
	get_viewport().set_input_as_handled()
	if sliding:forward_button(point,false)
	elif not canceled and not dragging and not suppress_tap and contacts.is_empty() and get_global_rect().has_point(point):
		forward_button(point,true);forward_button(point,false)
	if canceled or sliding or Time.get_ticks_msec()-last_time>120:velocity=0.0
	pointer_owner=-2;dragging=false;sliding=false;slider=null
func forward_button(point: Vector2,pressed: bool) -> void:
	var click := InputEventMouseButton.new();click.device=InputEvent.DEVICE_ID_EMULATION;click.button_index=MOUSE_BUTTON_LEFT;click.button_mask=MOUSE_BUTTON_MASK_LEFT if pressed else 0;click.pressed=pressed;click.position=point;click.global_position=point
	forwarding=true;get_viewport().push_input(click,true);forwarding=false
func forward_motion(point: Vector2,relative: Vector2) -> void:
	var move := InputEventMouseMotion.new();move.device=InputEvent.DEVICE_ID_EMULATION;move.position=point;move.global_position=point;move.relative=relative;move.button_mask=MOUSE_BUTTON_MASK_LEFT
	forwarding=true;get_viewport().push_input(move,true);forwarding=false
func write_offset(value: float) -> void:
	var limit := maxf(0.0,active_bar().max_value-active_bar().page)
	offset=clampf(value,0.0,limit)
	if horizontal:scroll_horizontal=roundi(offset)
	else:scroll_vertical=roundi(offset)
	if offset!=value:velocity=0.0
func _process(delta: float) -> void:
	if not allowed():cancel_gesture();return
	if pointer_owner==-2 and contacts.is_empty() and absf(velocity)>8.0:
		var damping := exp(-5.5*delta)
		write_offset(offset+velocity*(1.0-damping)/5.5);velocity*=damping
func cancel_gesture() -> void:
	if sliding:forward_button(last_point,false)
	pointer_owner=-2;contacts.clear();velocity=0.0;dragging=false;sliding=false;slider=null
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]:suspended=true;cancel_gesture()
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_APPLICATION_RESUMED]:suspended=false

func read_offset() -> float:return scroll_horizontal if horizontal else scroll_vertical
func coordinate(point: Vector2) -> float:return point.x if horizontal else point.y
func active_bar() -> ScrollBar:return get_h_scroll_bar() if horizontal else get_v_scroll_bar()
