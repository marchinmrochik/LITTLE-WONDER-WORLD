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
func anchor(id: String) -> Vector2:
	for entry: Dictionary in entries:
		if entry.id==id:
			var box: Array=entry.areas[0]
			return global_position+from_image(Vector2(box[0]+box[2]*0.5,box[1]+box[3]*0.5))
	return global_position
func part_at(point: Vector2) -> String:
	if not image_rect().has_point(point):return ""
	var position := to_local_image(point)
	for entry: Dictionary in entries:
		if not active_ids.is_empty() and entry.id not in active_ids:continue
		for box: Array in entry.areas:
			if Rect2(box[0],box[1],box[2],box[3]).has_point(position):return entry.id
	return ""
func _draw() -> void:
	if texture==null:return
	draw_texture_rect_region(texture,image_rect(),source_rect())
	if markers:
		for id: String in active_ids:
			var point := anchor(id)-global_position
			draw_circle(point,22,Color(1,0.89,0.48,0.35))
			draw_circle(point,22,Color("d7ab5e"),false,2,true)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
	var point := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed and not event.canceled:point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:point=event.position
	else:return
	var id := part_at(point)
	if not id.is_empty():part_pressed.emit(id)
	accept_event()
