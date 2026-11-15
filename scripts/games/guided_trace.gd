class_name GuidedTrace
extends RefCounted
var points := PackedVector2Array()
var lengths := PackedFloat32Array()
var edge := 0
var fraction := 0.0
var last_input := Vector2.ZERO
var drawing := false
var complete := false
var off_path := false
var reversed_path := false

func configure(path: Array) -> void:
	points.clear()
	for pair: Array in path:
		var point := Vector2(pair[0],pair[1])
		if point.is_finite() and (points.is_empty() or point.distance_to(points[-1])>.001):points.append(point)
	_rebuild_lengths()
	edge=0;fraction=0.0;drawing=false;complete=false;off_path=false;reversed_path=false
func _rebuild_lengths() -> void:
	lengths=PackedFloat32Array([0.0])
	for i: int in range(1,points.size()):lengths.append(lengths[-1]+points[i-1].distance_to(points[i]))
func progress() -> float:
	return lengths[edge]+(lengths[edge+1]-lengths[edge])*fraction
func current_point() -> Vector2:
	if points.size()<2:return Vector2.ZERO
	return points[-1] if complete else points[edge].lerp(points[edge+1],fraction)
func _projection(point: Vector2,low: float,high: float) -> Dictionary:
	var best := {"distance":INF,"along":low}
	for i: int in range(points.size()-1):
		if lengths[i+1]<low or lengths[i]>high:continue
		var distance := lengths[i+1]-lengths[i]
		var t := clampf((point-points[i]).dot(points[i+1]-points[i])/(distance*distance),maxf(0,(low-lengths[i])/distance),minf(1,(high-lengths[i])/distance))
		var at := points[i].lerp(points[i+1],t)
		var away := point.distance_to(at)
		# Prefer the earlier branch at a crossing, rather than skipping the loop.
		if away<float(best.distance)-.01:
			best={"distance":away,"along":lengths[i]+distance*t}
	return best
func begin(point: Vector2,tolerance: float) -> bool:
	if complete or points.size()<2 or not point.is_finite() or tolerance<=0:return false
	var accepted := progress()
	var nearby := _projection(point,maxf(0,accepted-tolerance*.6),minf(lengths[-1],accepted+tolerance*1.25))
	if float(nearby.distance)>tolerance:return false
	drawing=true;off_path=false;last_input=point;return true
func move(point: Vector2,tolerance: float) -> void:
	if not drawing or complete or not point.is_finite() or tolerance<=0:return
	if point.distance_to(last_input)<.01:return
	if edge==0 and fraction<.08 and points.size()>3 and points[0].is_equal_approx(points[-1]):
		# Compare a neighborhood, not a tiny first edge or a decorative notch.
		var first_distance: float=_projection(point,0,minf(lengths[-1],tolerance*2)).distance
		points.reverse();_rebuild_lengths()
		var reverse_distance: float=_projection(point,0,minf(lengths[-1],tolerance*2)).distance
		if reverse_distance+tolerance*.25>=first_distance:points.reverse();_rebuild_lengths()
		else:reversed_path=not reversed_path
	var count := clampi(ceili(last_input.distance_to(point)/maxf(2.0,tolerance*.25)),1,512)
	var step := last_input.distance_to(point)/count
	for i: int in range(1,count+1):
		advance(last_input.lerp(point,i/float(count)),tolerance,step)
		if complete:break
	last_input=point
func advance(point: Vector2,tolerance: float,step: float=0.0) -> void:
	var accepted := progress()
	var ahead := tolerance*(1.5 if off_path else 2.0)
	var found := _projection(point,maxf(0,accepted-tolerance*.35),minf(lengths[-1],accepted+ahead))
	if float(found.distance)>tolerance:
		off_path=true;return
	if off_path:
		if float(found.along)-accepted>tolerance*1.5:return
		off_path=false
	var target := maxf(accepted,float(found.along))
	# Input distance bounds progress even on tightly folded or intersecting paths.
	if step>0:target=minf(target,accepted+step*1.8+tolerance*.08)
	while edge<points.size()-2 and target>=lengths[edge+1]-.001:edge+=1
	fraction=clampf((target-lengths[edge])/(lengths[edge+1]-lengths[edge]),0,1)
	var left := lengths[-1]-target
	if left<=minf(tolerance*.35,(lengths[-1]-lengths[-2])*.4) and point.distance_to(points[-1])<=tolerance*.7:
		complete=true;drawing=false
func end() -> void:drawing=false
func ink() -> PackedVector2Array:
	if complete:return points
	var result := PackedVector2Array()
	for i: int in range(edge+1):result.append(points[i])
	result.append(current_point());return result
