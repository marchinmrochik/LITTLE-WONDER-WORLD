class_name SymbolTraceBoard
extends Control
signal stroke_finished
var lesson: Variant
var pointer_owner := -2
var age := 0.0
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP;clip_contents=true;custom_minimum_size=Vector2(600,300)
func camera_scale() -> float:return minf(size.x/600.0,size.y/660.0)
func from_world(at: Vector2) -> Vector2:return (size-Vector2(400,640)*camera_scale())*.5+Vector2(0,120)*camera_scale()+at*camera_scale()
func to_world(at: Vector2) -> Vector2:return (at-(size-Vector2(400,640)*camera_scale())*.5-Vector2(0,120)*camera_scale())/camera_scale()
func tolerance() -> float:return {"easy":44.0,"normal":34.0,"advanced":26.0}[SettingsManager.values.difficulty]/camera_scale()
func _process(delta: float) -> void:
 if lesson==null or lesson.paused():return
 age+=delta;queue_redraw()
func path_for(index: int) -> PackedVector2Array:
 var path := PackedVector2Array()
 for pair: Array in lesson.entry().strokes[index]:path.append(Vector2(pair[0],pair[1]))
 return path
func line(path: PackedVector2Array,color: Color,width: float) -> void:
 var transformed := PackedVector2Array()
 for point: Vector2 in path:transformed.append(from_world(point))
 draw_polyline(transformed,color,width,true)
 for point: Vector2 in [transformed[0],transformed[-1]]:draw_circle(point,width*.5,color)
func _draw() -> void:
 if lesson==null or lesson.pool.is_empty():return
 draw_style_box(UiKit.panel(Color("fffaf0"),28,0),Rect2(Vector2.ZERO,size))
 for i: int in range(lesson.entry().strokes.size()):
  line(path_for(i),Color("e2e8d5"),30)
  if i<lesson.stroke_index or lesson.celebrating:line(path_for(i),UiKit.GREEN,22)
 if not lesson.celebrating:
  var path: PackedVector2Array=lesson.trace.points
  for edge: int in range(lesson.trace.edge,path.size()-1):
   var count := maxi(1,ceili(path[edge].distance_to(path[edge+1])*camera_scale()/36))
   for dot: int in range(count):
    var t := dot/float(count)
    if edge==lesson.trace.edge and t<lesson.trace.fraction:continue
    draw_circle(from_world(path[edge].lerp(path[edge+1],t)),3,Color("bf9d5b"))
  var ink: PackedVector2Array=lesson.trace.ink()
  if ink.size()>1:line(ink,UiKit.GREEN,22)
  var at := from_world(lesson.trace.current_point());draw_circle(at,22,Color(.45,.72,.55,.23));draw_circle(at,13,UiKit.GREEN);draw_circle(at,4,Color.WHITE)
 else:draw_fireworks()
func draw_fireworks() -> void:
 var t: float=lesson.celebration_age
 var colors := [Color("e6af62"),Color("c897c7"),Color("86bfc9")]
 for i: int in range(3):
  var center := size*Vector2(.2+i*.3,.26 if i%2==0 else .65)
  var radius := 27.0 if SettingsManager.values.reduced_motion else minf(80,t*70)
  var color: Color=colors[i];color.a=clampf(1.4-t*.5,0,1)
  for ray: int in range(10):
   var direction := Vector2.from_angle(ray*TAU/10+i);draw_line(center+direction*radius*.65,center+direction*radius,color,4,true)
func begin(at: Vector2,owner: int) -> void:
 if lesson.paused() or lesson.celebrating or pointer_owner!=-2:return
 if lesson.trace.begin(to_world(at),tolerance()):
  pointer_owner=owner
  # Dot accents (Ї) are deliberately tappable, not microscopic circular drags.
  if lesson.trace.points.size()==2 and lesson.trace.points[0].distance_to(lesson.trace.points[1])*camera_scale()<8:
   lesson.trace.move(lesson.trace.points[-1],tolerance());cancel_pointer();stroke_finished.emit()
func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:begin(event.position,-1);accept_event()
 elif event is InputEventScreenTouch and event.pressed and not event.canceled:begin(event.position,event.index);accept_event()
func _input(event: InputEvent) -> void:
 if pointer_owner==-2:return
 if lesson.paused():cancel_pointer();return
 var point := Vector2.ZERO;var moved := false;var ended := false
 if event is InputEventScreenDrag and event.index==pointer_owner:point=event.position;moved=true
 elif event is InputEventScreenTouch and event.index==pointer_owner and not event.pressed:ended=true
 elif event is InputEventMouseMotion and pointer_owner==-1:point=event.position;moved=true
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and pointer_owner==-1 and not event.pressed:ended=true
 else:return
 if moved:
  lesson.trace.move(to_world(get_global_transform_with_canvas().affine_inverse()*point),tolerance())
  if lesson.trace.complete:cancel_pointer();stroke_finished.emit()
 if ended:cancel_pointer()
 get_viewport().set_input_as_handled()
func cancel_pointer() -> void:
 pointer_owner=-2
 if lesson!=null:lesson.trace.end()
