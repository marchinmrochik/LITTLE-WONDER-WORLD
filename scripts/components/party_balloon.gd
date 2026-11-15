class_name PartyBalloon
extends Control

signal pop_requested
var color := Color("e5a0bb")
var popped := false
# Free-flight game opts into a short burst; completion balloons keep their existing behavior.
var burst_progress := 1.0

func balloon_rect() -> Rect2:
	var radius := minf(size.x*0.34,size.y*0.34)
	return Rect2(Vector2(size.x*0.5-radius,size.y*0.43-radius),Vector2(radius*2,radius*2.15))

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)

func _has_point(point: Vector2) -> bool:
	if popped:return false
	var rect := balloon_rect()
	return ((point-rect.get_center())/(rect.size*0.5)).length_squared()<=1.0

func _draw() -> void:
	if popped:
		if burst_progress<1.0:
			var center := balloon_rect().get_center()
			for i: int in range(8):
				var direction := Vector2.from_angle(TAU*i/8.0)
				draw_line(center+direction*(14.0+burst_progress*25.0),center+direction*(25.0+burst_progress*40.0),Color(color,1.0-burst_progress),4.0,true)
		return
	var rect := balloon_rect()
	var points := PackedVector2Array()
	for i: int in range(64):
		var angle := TAU*i/64.0
		points.append(rect.get_center()+Vector2(cos(angle)*rect.size.x/2,sin(angle)*rect.size.y/2))
	draw_colored_polygon(points,color)
	points.append(points[0])
	draw_polyline(points,Color("496557"),2,true)
	var bottom := Vector2(rect.get_center().x,rect.end.y)
	draw_colored_polygon(PackedVector2Array([bottom,bottom+Vector2(-8,10),bottom+Vector2(8,10)]),color.darkened(0.1))
	draw_polyline(PackedVector2Array([bottom+Vector2(0,10),bottom+Vector2(-5,20),bottom+Vector2(4,30),bottom+Vector2(0,40)]),Color("78927b"),2,true)
	draw_arc(rect.get_center()-Vector2(rect.size.x*0.16,rect.size.y*0.12),rect.size.x*0.24,PI,PI*1.5,16,Color(1,1,1,0.65),6,true)

func _gui_input(event: InputEvent) -> void:
	if popped: return
	var point := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed and not event.canceled:
		point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		point=event.position
	else: return
	var rect := balloon_rect()
	if ((point-rect.get_center())/(rect.size*0.5)).length_squared() <= 1:
		pop_requested.emit()
		accept_event()
