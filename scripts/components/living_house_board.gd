class_name LivingHouseBoard
extends Control
signal marker_pressed(index: int)
signal stroke_finished
signal progress_changed
signal object_pressed(id: String)
var game: Variant
var view := Rect2(150,25,700,600)
var pointer_owner := -2
var age := 0.0
var effects: Dictionary={}
var lit: Dictionary={}
var effect_count := 0
var friend: Texture2D
var night := false
var smoke_color := 0
var bark := AudioStreamPlayer.new()
const SMOKE_COLORS := [Color("e9e1d0"),Color("f2adbc"),Color("b0d9ed"),Color("c1dfa7"),Color("d3b6ed")]
func is_done(id: String) -> bool:
	for i: int in range(game.parts.size()):
		if game.parts[i].id==id:return game.completed[i]
	return false
func marker_indices() -> Array[int]:return game.available_parts() if game.state==game.State.READY else []
func guide_dot_count(path: PackedVector2Array) -> int:
	var count := 0
	for i: int in range(path.size()-1):count+=maxi(1,ceili(path[i].distance_to(path[i+1])*camera_scale()/36.0))
	return count
func dog_position() -> Vector2:
	if effects.has("dog") and not SettingsManager.values.reduced_motion:
		var elapsed: float=4.0-effects.dog
		return Vector2(145+sin(elapsed*PI/4.0)*500,570-absf(sin(elapsed*11))*12)
	return Vector2(145,570)
func _ready() -> void:
	clip_contents=true;mouse_filter=Control.MOUSE_FILTER_STOP;custom_minimum_size=Vector2(600,360)
	bark.bus="SFX";bark.stream=preload("res://assets/audio/sfx/yard_bark.wav");add_child(bark)
	friend=load(CompanionCatalog.illustration(SettingsManager.values.companion));resized.connect(queue_redraw)
func camera_scale() -> float:return minf(size.x/view.size.x,size.y/view.size.y)
func image_rect() -> Rect2:
	var fitted := view.size*camera_scale();return Rect2((size-fitted)*.5,fitted)
func from_world(point: Vector2) -> Vector2:return image_rect().position+(point-view.position)*camera_scale()
func to_world(point: Vector2) -> Vector2:return view.position+(point-image_rect().position)/camera_scale()
func tolerance() -> float:return {"easy":44.0,"normal":34.0,"advanced":26.0}[SettingsManager.values.difficulty]/camera_scale()
func paused() -> bool:return game.overlay_paused or game.focus_paused
func _process(delta: float) -> void:
	if paused() or not is_visible_in_tree():return
	age+=delta
	for key: String in effects.keys():
		effects[key]-=delta
		if effects[key]<=0.0:effects.erase(key)
	queue_redraw()
func path_for(part: Dictionary,index: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	for pair: Array in part.strokes[index]:result.append(Vector2(pair[0],pair[1]))
	return result
func outline(path: PackedVector2Array,color: Color,width: float=4.0) -> void:
	draw_polyline(path,color,width/camera_scale(),true)
func part_rect(part: Dictionary) -> Rect2:
	var result := Rect2(path_for(part,0)[0],Vector2.ZERO)
	for point: Vector2 in path_for(part,0):result=result.expand(point)
	return result
func _draw() -> void:
	if game==null:return
	var scale_factor := camera_scale();var shift := image_rect().position-view.position*scale_factor
	if effects.has("walls") and not SettingsManager.values.reduced_motion:shift.y-=sin((2.0-effects.walls)*PI*2)*6.0
	# The scene owns its sky so day/night affects the entire drawing area.
	draw_rect(Rect2(Vector2.ZERO,size),Color("243951") if night else Color("e5f3ee"))
	draw_set_transform(shift,0,Vector2.ONE*scale_factor)
	if night:
		for star: Vector2 in [Vector2(250,-35),Vector2(380,10),Vector2(690,-15),Vector2(920,175),Vector2(75,240),Vector2(800,300)]:
			draw_circle(star,2.5,Color("fff0bd"))
	paint_ellipse(Rect2(-300,555,1600,650),Color("405e63") if night else Color("c4dcae"))
	# Soft original scenery anchors the finished illustration.
	paint_ellipse(Rect2(240,563,520,55),Color("b6d09d"))
	draw_line(Vector2(210,584),Vector2(790,584),Color("83ad83"),3,true)
	for index: int in [0,5,1,2,3,4,6,7,8,9]:draw_part(index)
	if game.state==game.State.READY:
		for index: int in marker_indices():
			var pair: Array=game.parts[index].marker;var at := Vector2(pair[0],pair[1]);var pulse := 1.0 if SettingsManager.values.reduced_motion else 1.0+sin(age*3+index)*.12
			draw_circle(at,25.0*pulse/scale_factor,Color(1,.86,.42,.32));draw_circle(at,15.0/scale_factor,Color("efc65c"));draw_circle(at,15.0/scale_factor,UiKit.GREEN,false,3.0/scale_factor,true)
	elif game.state==game.State.TRACE:draw_guide()
	if is_done("chimney"):draw_smoke(age)
	if effects.has("cloud"):draw_rain()
	if effects.has("flowers"):draw_butterflies()
	if effects.has("roof"):draw_bird(2.0-effects.roof)
	draw_set_transform(Vector2.ZERO)
func paint_ellipse(rect: Rect2,color: Color) -> void:
	var polygon := PackedVector2Array()
	for i: int in range(64):polygon.append(rect.get_center()+Vector2(cos(i*TAU/64),sin(i*TAU/64))*rect.size*.5)
	draw_colored_polygon(polygon,color)
func draw_part(index: int) -> void:
	var part: Dictionary=game.parts[index];var done: bool=game.completed[index]
	var active: bool=index==game.part_index and game.state in [game.State.ZOOMING,game.State.TRACE]
	if not done and not active:return
	if done and part.id in ["sun","cloud","dog","flowers"]:
		match part.id:
			"sun":draw_sun()
			"cloud":draw_cloud()
			"dog":draw_dog()
			"flowers":draw_flowers()
		return
	var path := path_for(part,0)
	var fill := Color(part.color) if done else Color(part.color)
	if not done:fill.a=.12
	if done and game.state==game.State.REVEAL and index==game.part_index:fill.a=game.fill_reveal
	var polygon := path.duplicate();polygon.remove_at(polygon.size()-1)
	draw_colored_polygon(polygon,fill)
	outline(path,Color("496557") if done else Color(part.color),4.0 if done else 2.0)
	if done:
		match part.id:
			"walls":
				draw_line(Vector2(297,569),Vector2(702,569),Color("d7af80"),5,true)
			"roof":
				for y: int in [190,220,250]:
					var half := (y-105)/180.0*265.0
					draw_line(Vector2(500-half+20,y),Vector2(500+half-20,y),Color("c46d67"),2,true)
			"door":draw_door()
			"left_window","right_window":draw_window(part)
			"chimney":
				draw_style_box(UiKit.panel(Color("d3a18a"),3,0),Rect2(579,70,74,16))
				for y: int in [100,127,154]:draw_line(Vector2(590,y),Vector2(642,y),Color("a97966"),2,true)
func draw_door() -> void:
	var openness := sin((2.0-float(effects.get("door",0.0)))*PI/2.0) if effects.has("door") else 0.0
	if openness>.03:
		draw_rect(Rect2(463,404,79,176),Color("526e65"))
		var bob := 0.0 if SettingsManager.values.reduced_motion else sin(age*8)*4
		var fitted := friend.get_size()*minf(70.0/friend.get_width(),110.0/friend.get_height())
		draw_texture_rect(friend,Rect2(Vector2(503,535+bob)-fitted*.5,fitted),false)
	var width := 85.0*(1.0-openness*.85)
	var door := PackedVector2Array([Vector2(460,400),Vector2(460+width,400+openness*12),Vector2(460+width,580-openness*12),Vector2(460,580),Vector2(460,400)])
	var polygon := door.duplicate();polygon.remove_at(polygon.size()-1)
	draw_colored_polygon(polygon,Color("86b5b6"));outline(door,UiKit.GREEN)
	draw_circle(Vector2(460+width*.82,491),5,Color("f5d782"))
func draw_window(part: Dictionary) -> void:
	var rect := part_rect(part)
	draw_rect(rect.grow(-5),Color("f7d97b") if lit.get(part.id,false) else Color("bde5e8"))
	draw_line(Vector2(rect.get_center().x,rect.position.y),Vector2(rect.get_center().x,rect.end.y),Color("fff5dc"),7,true)
	draw_line(Vector2(rect.position.x,rect.get_center().y),Vector2(rect.end.x,rect.get_center().y),Color("fff5dc"),7,true)
	draw_rect(Rect2(rect.position+Vector2(-7,rect.size.y+2),Vector2(rect.size.x+14,10)),Color("d49e76"))
	if effects.has(part.id):
		var radius := 10.0 if SettingsManager.values.reduced_motion else 8.0+sin(age*7)*4
		var center := rect.get_center()
		for ray: int in range(8):
			var direction := Vector2.from_angle(ray*TAU/8);draw_line(center+direction*radius*.45,center+direction*radius,Color("fff8dc"),3,true)
func draw_guide() -> void:
	for stroke: int in range(game.stroke_index):outline(path_for(game.part(),stroke),UiKit.GREEN,8.0)
	var ink: PackedVector2Array=game.trace.ink()
	if ink.size()>1:outline(ink,UiKit.GREEN,9.0)
	var path: PackedVector2Array=game.trace.points;var scale_factor := camera_scale()
	for edge: int in range(game.trace.edge,path.size()-1):
		var length: float=path[edge].distance_to(path[edge+1]);var count := maxi(1,ceili(length*scale_factor/36.0))
		for dot: int in range(count):
			var t := dot/float(count)
			if edge==game.trace.edge and t<game.trace.fraction:continue
			draw_circle(path[edge].lerp(path[edge+1],t),3.0/scale_factor,Color("d6ac5f"))
	var start: Vector2=game.trace.current_point()
	draw_circle(start,19.0/scale_factor,Color(0.5,.75,.56,.25));draw_circle(start,12.0/scale_factor,UiKit.GREEN);draw_circle(start,4.0/scale_factor,Color.WHITE)
	draw_circle(path[-1],6.0/scale_factor,Color("d6ac5f"))
func draw_smoke(elapsed: float) -> void:
	for i: int in range(4):
		var t := fmod(elapsed*.65+i*.22,1.0)
		draw_circle(Vector2(616+sin(t*5+i)*16,67-t*105),10+t*13,Color(SMOKE_COLORS[smoke_color],(1-t)*.7))
func draw_bird(elapsed: float) -> void:
	var t := .5 if SettingsManager.values.reduced_motion else clampf(elapsed/2.0,0.0,1.0);var at := Vector2(250+t*510,185-sin(t*PI)*95)
	paint_ellipse(Rect2(at-Vector2(17,10),Vector2(34,20)),Color("ebbf63"));draw_circle(at+Vector2(14,-8),9,Color("ebbf63"));draw_line(at,at+Vector2(-8,-12-absf(sin(age*12))*15),Color("b58d53"),5,true)
func play_object(id: String) -> void:
	effects[id]=4.0 if id in ["dog","cloud","flowers"] else 2.0;effect_count+=1
	if id=="chimney":smoke_color=(smoke_color+1)%SMOKE_COLORS.size()
	if id=="sun":
		night=not night
		for window: String in ["left_window","right_window"]:
			if is_done(window):lit[window]=night
	if id=="dog":bark.play()
	if id in ["left_window","right_window"]:lit[id]=not lit.get(id,false)
	AudioManager.play_sfx("tap");queue_redraw()
func object_at(point: Vector2) -> String:
	if is_done("dog") and Rect2(dog_position()-Vector2(80,85),Vector2(160,145)).has_point(point):return "dog"
	for index: int in [6,7,9,3,4,2,5,1,0]:
		if not game.completed[index]:continue
		if part_rect(game.parts[index]).has_point(point):return game.parts[index].id
	return ""
func _gui_input(event: InputEvent) -> void:
	if paused() or pointer_owner!=-2:return
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
	var point := Vector2.ZERO;var pointer := -2
	if event is InputEventScreenTouch and event.pressed and not event.canceled:point=event.position;pointer=event.index
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:point=event.position;pointer=-1
	else:return
	var world := to_world(point)
	match game.state:
		game.State.READY:
			var selected := false
			for index: int in marker_indices():
				var pair: Array=game.parts[index].marker
				if world.distance_to(Vector2(pair[0],pair[1]))<=40.0/camera_scale():marker_pressed.emit(index);selected=true;break
			if not selected:
				var id := object_at(world)
				if not id.is_empty():object_pressed.emit(id)
		game.State.TRACE:
			if game.trace.begin(world,tolerance()):pointer_owner=pointer
		game.State.PLAY:
			var id := object_at(world)
			if not id.is_empty():object_pressed.emit(id)
	accept_event()
func _input(event: InputEvent) -> void:
	if pointer_owner==-2:return
	if paused():cancel_pointer();return
	var point := Vector2.ZERO;var moved := false;var ended := false
	if event is InputEventScreenDrag and event.index==pointer_owner:point=event.position;moved=true
	elif event is InputEventScreenTouch and event.index==pointer_owner and not event.pressed:point=event.position;ended=true
	elif event is InputEventMouseMotion and pointer_owner==-1:point=event.position;moved=true
	elif event is InputEventMouseButton and pointer_owner==-1 and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed:point=event.position;ended=true
	else:return
	if moved:
		game.trace.move(to_world(get_global_transform_with_canvas().affine_inverse()*point),tolerance());progress_changed.emit()
		if game.trace.complete:cancel_pointer();stroke_finished.emit()
	if ended:cancel_pointer()
	get_viewport().set_input_as_handled()
func cancel_pointer() -> void:
	pointer_owner=-2
	if game!=null:game.trace.end()

func draw_sun() -> void:
	var at := Vector2(135,35)
	if night:
		draw_circle(at,48,Color("ffe8b0"));draw_circle(at+Vector2(21,-13),41,Color("243951"))
	else:
		for i: int in range(12):
			var direction := Vector2.from_angle(i*TAU/12+(.0 if SettingsManager.values.reduced_motion else age*.03))
			draw_line(at+direction*60,at+direction*73,Color("e9b750"),5,true)
		draw_circle(at,48,Color("f5ce65"))
		for x: int in [-15,15]:draw_circle(at+Vector2(x,-3),3,UiKit.GREEN)
		draw_arc(at+Vector2(0,6),13,0,PI,16,UiKit.GREEN,3,true)
func draw_cloud() -> void:
	var color := Color("c4d7e3") if effects.has("cloud") else Color("eaf2fa") if night else Color("ffffff")
	for circle: Vector3 in [Vector3(777,47,34),Vector3(827,30,44),Vector3(876,51,32),Vector3(911,54,25)]:draw_circle(Vector2(circle.x,circle.y),circle.z,color)
	draw_rect(Rect2(776,43,135,34),color)
func draw_rain() -> void:
	for i: int in range(18):
		var t := fmod(age*.8+i*.13,1.0);var at := Vector2(755+(i%7)*28,90+t*420)
		draw_line(at,at+Vector2(-6,16),Color("7dbde2"),3,true)
	if is_done("flowers"):draw_circle(Vector2(845,650),50,Color(.45,.7,.8,.16))
func draw_dog() -> void:
	var at := dog_position();var moving: bool=effects.has("dog")
	var fur := Color("d6a06e");var dark := Color("946141")
	paint_ellipse(Rect2(at+Vector2(-43,-18),Vector2(90,58)),fur)
	for x: int in [-29,27]:
		var stride := sin(age*16+x)*10 if moving and not SettingsManager.values.reduced_motion else 0.0
		draw_line(at+Vector2(x,22),at+Vector2(x+stride,53),dark,12,true)
	var tail := at+Vector2(47,-5);draw_line(tail,tail+Vector2(15,-23+sin(age*12)*7),dark,10,true)
	draw_circle(at+Vector2(-13,-48),35,fur)
	paint_ellipse(Rect2(at+Vector2(-50,-73),Vector2(19,48)),dark);paint_ellipse(Rect2(at+Vector2(9,-73),Vector2(19,48)),dark)
	for x: int in [-25,-2]:draw_circle(at+Vector2(x,-52),4,UiKit.GREEN)
	paint_ellipse(Rect2(at+Vector2(-34,-40),Vector2(43,24)),Color("fff0d7"));draw_circle(at+Vector2(-13,-36),6,UiKit.GREEN)
	if moving:
		paint_ellipse(Rect2(at+Vector2(-19,-27),Vector2(12,16)),Color("e69095"))
		for i: int in range(2):draw_arc(at+Vector2(30,-42),15+i*10,-.65,.65,12,Color("e8bf5d"),3,true)
func draw_flowers() -> void:
	for flower: Vector3 in [Vector3(805,590,.65),Vector3(845,545,1),Vector3(890,600,.7)]:
		var at := Vector2(flower.x,flower.y);var radius := 21*flower.z
		draw_line(at,Vector2(at.x,649),Color("60966d"),5,true)
		paint_ellipse(Rect2(at+Vector2(0,45),Vector2(25,12)),Color("80b47b"))
		for i: int in range(5):draw_circle(at+Vector2.from_angle(i*TAU/5)*radius,radius*.7,Color("e9a3b5"))
		draw_circle(at,radius*.6,Color("f4d074"))
func draw_butterflies() -> void:
	for i: int in range(3):
		var t := age*1.6+i*2;var at := Vector2(845+sin(t)*70,455+cos(t*.7)*45)
		var spread := 12.0 if SettingsManager.values.reduced_motion else 5+absf(sin(age*12))*9
		paint_ellipse(Rect2(at-Vector2(spread,9),Vector2(spread,18)),Color("f2bb68"));paint_ellipse(Rect2(at-Vector2(0,9),Vector2(spread,18)),Color("c2a1d8"));draw_line(at-Vector2(0,7),at+Vector2(0,7),UiKit.GREEN,2,true)
