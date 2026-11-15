class_name WorldBodyBoard
extends Control
signal part_pressed(id: String)
var entries: Array[Dictionary] = []
var active_ids: Array[String] = []
var zoom_face := false
var zoom_hand := false
var markers := false
var texture: Texture2D
var character: Dictionary
var selected_id := ""
var marker_layout: Dictionary={}
var layout_signature := ""
const MARKER_RADIUS := 22.0
const BODY_MARKERS := ["head","neck","shoulder","arm","elbow","hand","torso","belly","knee","leg","foot"]

func _ready() -> void:
	custom_minimum_size=Vector2(480,340)
	mouse_filter=Control.MOUSE_FILTER_STOP
	character=BodyCharacterCatalog.definition()
	texture=load(character.texture)
	resized.connect(queue_redraw)

func source_rect() -> Rect2:
	var box: Array=character.hand if zoom_hand else character.face if zoom_face else character.bounds
	return Rect2(box[0],box[1],box[2],box[3])
func image_rect() -> Rect2:
	var source := source_rect()
	var fitted := source.size*minf(size.x/source.size.x,size.y/source.size.y)
	return Rect2((size-fitted)*0.5,fitted)
func to_local_image(point: Vector2) -> Vector2:
	var rect := image_rect()
	return source_rect().position+(point-rect.position)/rect.size*source_rect().size
func from_image(point: Vector2) -> Vector2:
	var rect := image_rect()
	return rect.position+(point-source_rect().position)/source_rect().size*rect.size
func anatomical_point(id: String) -> Vector2:
	for entry: Dictionary in entries:
		if entry.id==id:
			var box: Array=entry.areas[0]
			return from_image(Vector2(box[0]+box[2]*.5,box[1]+box[3]*.5))
	return Vector2.ZERO
func marker_ids() -> Array[String]:
	var ids: Array[String]=[]
	for entry: Dictionary in entries:
		if not active_ids.is_empty():
			if entry.id in active_ids:ids.append(entry.id)
		elif zoom_hand:
			if entry.id in ["hand","finger"]:ids.append(entry.id)
		elif zoom_face:
			if entry.view=="face":ids.append(entry.id)
		elif entry.id in BODY_MARKERS:ids.append(entry.id)
	return ids
func layout_markers() -> Dictionary:
	var signature := str([size,zoom_face,zoom_hand,active_ids,entries.size()])
	if signature==layout_signature:return marker_layout
	layout_signature=signature;marker_layout={}
	var safe := Rect2(Vector2.ONE*(MARKER_RADIUS+4),size-Vector2.ONE*(MARKER_RADIUS+4)*2)
	for id: String in marker_ids():
		var origin := anatomical_point(id)
		if id=="head" and not zoom_face:origin=from_image(Vector2(512,220))
		var placed := false
		for ring: int in range(26):
			for ray: int in range(1 if ring==0 else 20):
				var point := origin+Vector2.from_angle(ray*TAU/20)*ring*8
				if not safe.has_point(point):continue
				var occupied := false
				for other: Vector2 in marker_layout.values():
					if point.distance_to(other)<MARKER_RADIUS*2+7:occupied=true;break
				if occupied:continue
				marker_layout[id]=point;placed=true;break
			if placed:break
	return marker_layout
func anchor(id: String) -> Vector2:
	return global_position+layout_markers().get(id,anatomical_point(id)) if markers else global_position+anatomical_point(id)
func part_at(point: Vector2) -> String:
	if markers:
		for id: String in layout_markers():
			if point.distance_to(marker_layout[id])<=MARKER_RADIUS+2:return id
		return ""
	if not image_rect().has_point(point):return ""
	var position := to_local_image(point)
	var chosen := "";var smallest := INF
	for entry: Dictionary in entries:
		if not active_ids.is_empty() and entry.id not in active_ids:continue
		for box: Array in entry.areas:
			var rect := Rect2(box[0],box[1],box[2],box[3])
			if rect.has_point(position) and rect.get_area()<smallest:chosen=entry.id;smallest=rect.get_area()
	return chosen
func _draw() -> void:
	if texture==null:return
	draw_texture_rect_region(texture,image_rect(),source_rect())
	if markers:
		for id: String in layout_markers():
			var point: Vector2=marker_layout[id];var source := anatomical_point(id)
			if id=="head" and not zoom_face:source=from_image(Vector2(512,220))
			if point.distance_to(source)>4:draw_line(source,point,Color(.25,.46,.37,.55),2,true);draw_circle(source,3,UiKit.GREEN)
			var active := id==selected_id
			var color := UiKit.GREEN if active else Color("eacb77")
			draw_circle(point,MARKER_RADIUS,Color(color,.7 if active else .5))
			draw_circle(point,MARKER_RADIUS,UiKit.GREEN if active else Color("b0914a"),false,3 if active else 1.5,true)
			if active:draw_circle(point,5,Color.WHITE)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
	var point := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed and not event.canceled:point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:point=event.position
	else:return
	var id := part_at(point)
	if not id.is_empty():part_pressed.emit(id)
	accept_event()
