class_name GuidedTrace
extends RefCounted
var points := PackedVector2Array()
var edge := 0
var fraction := 0.0
var last_input := Vector2.ZERO
var drawing := false
var complete := false
var off_path := false
func configure(path: Array) -> void:
	points.clear()
	for pair: Array in path:points.append(Vector2(pair[0],pair[1]))
	edge=0;fraction=0.0;drawing=false;complete=false;off_path=false
func current_point() -> Vector2:
	return points[-1] if complete else points[edge].lerp(points[edge+1],fraction)
func begin(point: Vector2,tolerance: float) -> bool:
	if complete or point.distance_to(current_point())>tolerance:return false
	drawing=true;off_path=false;last_input=point;return true
func move(point: Vector2,tolerance: float) -> void:
	if not drawing or complete:return
	# Closed contours can be traced in either direction from the green start.
	if edge==0 and fraction<.08 and points.size()>3 and points[0].is_equal_approx(points[-1]):
		var first_distance := point.distance_to(Geometry2D.get_closest_point_to_segment(point,points[0],points[1]))
		var reverse_distance := point.distance_to(Geometry2D.get_closest_point_to_segment(point,points[0],points[-2]))
		if reverse_distance+tolerance*.15<first_distance:points.reverse()
	var count := clampi(ceili(last_input.distance_to(point)/maxf(2.0,tolerance*.25)),1,512)
	for i: int in range(1,count+1):
		advance(last_input.lerp(point,i/float(count)),tolerance)
		if complete:break
	last_input=point
func advance(point: Vector2,tolerance: float) -> void:
	if off_path:
		if point.distance_to(current_point())>tolerance*.6:return
		off_path=false
	var start := points[edge];var end := points[edge+1];var direction := end-start
	var t := clampf((point-start).dot(direction)/direction.length_squared(),0.0,1.0)
	if point.distance_to(start+direction*t)>tolerance or (fraction-t)*direction.length()>tolerance*.7:
		off_path=true;return
	fraction=maxf(fraction,t)
	if point.distance_to(end)<=minf(tolerance*.65,direction.length()*.45):
		edge+=1;fraction=0.0
		if edge==points.size()-1:complete=true;drawing=false
func end() -> void:drawing=false
func ink() -> PackedVector2Array:
	if complete:return points
	var result := PackedVector2Array()
	for i: int in range(edge+1):result.append(points[i])
	result.append(current_point());return result
